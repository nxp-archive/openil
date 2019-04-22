/*
 * Copyright (C) 2018 NXP
 *
 * Description:
 * Inter-core communication with baremetal cores
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <time.h>

#include "inter-core-comm.h"

#define MEMDEVICE "/dev/mem"
#define SHD_MEMDEVICE "/dev/ipi_bm"

int memfd;

void usage(char *name)
{
	printf("icc show				- Show all icc rings status at this core\n");
	printf("icc get					- Waiting to receive icc at this core\n");
	printf("icc perf <core_mask> <counts>		- ICC performance to cores <core_mask> with <counts> bytes\n");
	printf("icc send <core_mask> <data> <counts>	- Send <counts> <data> to cores <core_mask>\n");
	printf("icc irq <core_mask> <irq>		- Send SGI <irq> ID[0 - 15] to <core_mask>\n");
	printf("icc read <addr> <counts>		- Read <counts> 32bit register from <addr>\n");
	printf("icc write <addr> <data>			- Write <data> to a register <addr>\n");
}

static void do_icc_show(void)
{
	icc_show();
}

static void do_icc_irq_handle(int src_coreid, unsigned long block, unsigned int counts)
{
	if ((*(char *)ICC_PHY2VIRT(block)) != 0x5a)
		printf("Get the ICC from core %d; block: 0x%lx, bytes: %d, value: 0x%x\n",
			src_coreid, block, counts, (*(char *)ICC_PHY2VIRT(block)));
}

static void do_icc_irq_register(void)
{
	int coreid = CONFIG_MAX_CPUS;

	if (icc_irq_register(coreid, do_icc_irq_handle))
		printf("ICC register irq handler failed, src_coreid: %d, max_cores: %d\n",
			coreid, CONFIG_MAX_CPUS);
}

static void do_icc_receive(void)
{
	do_icc_irq_register();
	while(1) {
		usleep(1000);
	}
}

static int do_icc_perf(int argc, char * const argv[])
{
	unsigned long core_mask, dest_core;
	unsigned long block;
	char *endp;
	unsigned long long counts, bytes;
	unsigned long data;
	struct timespec time_start={0},time_end={0};
	unsigned long long nstime;
	int i, k, ret;

	core_mask = strtoul(argv[2], &endp, 16);
	if ((*endp != 0) || (!core_mask)) {
		printf ("core_mask: 0x%lx is not valid\n", core_mask);
		return -1;
	};

	counts = (unsigned int)strtoul(argv[3], &endp, 0);
	if ((*endp != 0) || (!counts)) {
		printf ("counts: %lu is not valid\n", counts);
		return -1;
	};

	for (i = 0; i < CONFIG_MAX_CPUS; i++) {
		if (((core_mask >> i) & 0x1) && (i != 0))
			dest_core |= 0x1 << i;
	}

	if (counts > ICC_CORE_BLOCK_COUNT * ICC_BLOCK_UNIT_SIZE) {
		printf("ICC send error! Max bytes: %d, input bytes: %ld",
			ICC_CORE_BLOCK_COUNT * ICC_BLOCK_UNIT_SIZE, counts);
		return -1;
	}

	bytes = counts;

	/* for performance test, set all share blocks to 0x5a */
	memset((void *)ICC_CORE_BLOCK_BASE(mycoreid), 0x5a, (ICC_CORE_MEM_SPACE - ICC_RING_DESC_SPACE));

	printf("ICC performance testing ...\n");
	printf("Target cores: 0x%x, bytes: %ld, ", dest_core, counts);

	clock_gettime(CLOCK_REALTIME, &time_start);
	while (bytes >= ICC_BLOCK_UNIT_SIZE) {
		block = icc_block_request();
		if (!block) {
			printf("No available block! sent %ld bytes\n",
				(counts - bytes));
			continue;
		} else {
			/* Process data to delay a few time to send data */
			data = 0x5a;
			data /= 3;
			data *= 3;
			memset((void *)ICC_PHY2VIRT(block), data,
				ICC_BLOCK_UNIT_SIZE);
			ret = icc_set_block(dest_core, ICC_BLOCK_UNIT_SIZE, block);
			if (ret) {
				icc_block_free(block);
				continue;
			}
		}
		bytes -= ICC_BLOCK_UNIT_SIZE;
	}

	while (bytes) {
		block = icc_block_request();
		if (!block) {
			printf("No available block! sent %ld bytes\n",
				(counts - bytes));
			continue;
		} else {
			ret = icc_set_block(dest_core, bytes, block);
			if (ret) {
				icc_block_free(block);
				continue;
			}
		}
		bytes = 0;
	}

	while (1) {
		k = 0;
		for (i = 0; i < CONFIG_MAX_CPUS; i++) {
			if (((dest_core >> i) & 0x1) && (i != mycoreid)) {
				if (icc_ring_state(i))
					k++;
			}
		}
		if (!k)
			break;
	}

	clock_gettime(CLOCK_REALTIME, &time_end);
	nstime = time_end.tv_nsec-time_start.tv_nsec;

	printf("ICC performance: %lld bytes to 0x%x cores in %lld us with %lld KB/s\n",
		counts, dest_core, nstime/1000, (counts * 1000000)/nstime);

	printf("\n");
	icc_show();
	return 0;
}

static int do_icc_send(int argc, char * const argv[])
{
	unsigned long core_mask, dest_core = 0;
	unsigned long block;
	unsigned long counts, bytes;
	unsigned long data;
	char *endp;
	int i, k, ret;

	core_mask = strtoul(argv[2], &endp, 16);
	if ((*endp != 0) || (!core_mask)) {
		printf ("core_mask: 0x%lx is not valid\n", core_mask);
		return -1;
	};

	data = (unsigned int)strtoul(argv[3], &endp, 0);
	if (*endp != 0) {
		printf ("get data failed\n");
		return -1;
	};

	counts = (unsigned int)strtoul(argv[4], &endp, 0);
	if ((*endp != 0) || (!counts)) {
		printf ("counts: %lu is not valid\n", counts);
		return -1;
	};

	for (i = 0; i < CONFIG_MAX_CPUS; i++) {
		if (((core_mask >> i) & 0x1) && (i != 0))
			dest_core |= 0x1 << i;
	}

	if (counts > ICC_CORE_BLOCK_COUNT * ICC_BLOCK_UNIT_SIZE) {
		printf("ICC send error! Max bytes: %d, input bytes: %ld",
			ICC_CORE_BLOCK_COUNT * ICC_BLOCK_UNIT_SIZE, counts);
		return -1;
	}

	bytes = counts;

	printf("ICC send testing ...\n");
	printf("Target cores: 0x%x, bytes: %ld\n", dest_core, counts);

	while (bytes >= ICC_BLOCK_UNIT_SIZE) {
		block = icc_block_request();
		if (!block) {
			printf("No available block! sent %ld bytes\n",
				(counts - bytes));
			continue;
		} else {
			memset((void *)ICC_PHY2VIRT(block), data, ICC_BLOCK_UNIT_SIZE);
			ret = icc_set_block(dest_core, ICC_BLOCK_UNIT_SIZE, block);
			if (ret) {
				printf("The ring is full! sent %ld bytes\n",
					(counts - bytes));
				icc_block_free(block);
				continue;
			}
		}
		bytes -= ICC_BLOCK_UNIT_SIZE;
	}

	while (bytes) {
		block = icc_block_request();
		if (!block) {
			printf("No available block! sent %ld bytes\n",
				(counts - bytes));
			continue;
		} else {
			memset((void *)ICC_PHY2VIRT(block), data,
				bytes / 8 * 8);
			for (int i = bytes / 8 * 8; i < bytes; i++)
				*((char *)ICC_PHY2VIRT(block) + i) = data;
			ret = icc_set_block(dest_core, bytes, block);
			if (ret) {
				printf("The ring is full! sent %ld bytes\n",
					(counts - bytes));
				icc_block_free(block);
				continue;
			}
		}
		bytes = 0;
	}

	while (1) {
		k = 0;
		for (i = 0; i < CONFIG_MAX_CPUS; i++) {
			if (((dest_core >> i) & 0x1) && (i != mycoreid)) {
				if (icc_ring_state(i))
					k++;
			}
		}
		if (!k)
			break;
	}

	printf("ICC send: %ld bytes to 0x%x cores success\n",
		counts, dest_core);

	printf("\n");
	icc_show();
	return 0;
}

static int do_icc_read_register(int argc, char * const argv[])
{
	unsigned long phy_addr;
	unsigned int counts;
	unsigned int offset;
	char *endp;
	unsigned long val;
	void *ptr;
	int i;

	phy_addr = strtoul(argv[2], &endp, 16);
	if ((*endp != 0) || (!phy_addr)) {
		printf ("Addr: %lu is not valid\n", phy_addr);
		return -1;
	};

	counts = (unsigned int)strtoul(argv[3], &endp, 0);
	if ((*endp != 0) || (!counts)) {
		printf ("Counts: %lu is not valid\n", counts);
		return -1;
	};

	offset = phy_addr & 0xfff;

	/* map physical memory space into process memory space */
	ptr = (void *)mmap(NULL, GICD_SIZE, PROT_WRITE | PROT_READ, MAP_SHARED,
			memfd, (phy_addr & ~0xfff));

	if (ptr == (void *) -1) {
		perror("mmap");
		goto exit;
	}

	printf("The ptr from mmap: %p, offset: 0x%x\n", ptr, offset);
	for (i = 0; i < counts; i++)
		printf("0x%08lx: 0x%08x\n", phy_addr + i * 4,
			*((volatile unsigned int *)((void *)ptr + offset + i * 4)));
exit:
	return 0;
}

static int do_icc_write_register(int argc, char * const argv[])
{
	unsigned long phy_addr;
	unsigned int data;
	unsigned int offset;
	char *endp;
	void *ptr;

	phy_addr = strtoul(argv[2], &endp, 16);
	if ((*endp != 0) || (!phy_addr)) {
		printf ("Addr: %lu is not valid\n", phy_addr);
		return -1;
	};

	data = (unsigned int)strtoul(argv[3], &endp, 0);
	if (*endp != 0) {
		printf ("data: %lu is not valid\n", data);
		return -1;
	};

	offset = phy_addr & 0xfff;

	/* map physical memory space into process memory space */
	ptr = (void *)mmap(NULL, GICD_SIZE, PROT_WRITE | PROT_READ, MAP_SHARED,
			memfd, (phy_addr & ~0xfff));

	if (ptr == (void *) -1) {
		perror("mmap");
		goto exit;
	}

	*((volatile unsigned int *)((void *)ptr + offset)) = data;
	printf("The ptr from mmap: %p, offset: 0x%x, data: 0x%x, readback: 0x%x\n",
		ptr, offset, data, *((volatile unsigned int *)((void *)ptr + offset)));
exit:
	return 0;
}

static int do_icc_irq_cores(int argc, char * const argv[])
{
	unsigned int core_mask, hw_irq;
	char *endp;

	core_mask = strtoul(argv[2], &endp, 0);
	if ((*endp != 0) && (core_mask > 0xf)) {
		printf ("core_mask: %lu is not valid\n", core_mask);
		return -1;
	};

	hw_irq = strtoul(argv[3], &endp, 0);
	if ((*endp != 0) && (hw_irq > 15)) {
		printf ("Interrupt id num: %lu is not valid, SGI[0 - 15]\n", hw_irq);
		return -1;
	};

	icc_set_sgi(core_mask, hw_irq);

	return 0;
}

int main(int argc, char **argv)
{
	size_t gic_addr = (size_t)GICD_BASE;
	size_t share_addr = (size_t)CONFIG_SYS_DDR_SDRAM_SHARE_BASE;

	if (argc < 2) { 
		usage(argv[0]);
		return -EINVAL;
	}
	
	memfd = open(MEMDEVICE, O_RDWR | O_SYNC);
	shd_memfd = open(SHD_MEMDEVICE, O_RDWR | O_SYNC);
	if (memfd < 0) {
		fprintf(stderr, "Couldn't open file %s\n", MEMDEVICE);
		goto exit;
	}

	if (shd_memfd < 0) {
		fprintf(stderr, "Couldn't open file %s\n", SHD_MEMDEVICE);
		goto exit;
	}

	/* map GIC physical memory space into process memory space */
	gic_base = (void *)mmap(NULL, GICD_SIZE, PROT_WRITE | PROT_READ, MAP_SHARED,
			memfd, gic_addr);

	if (gic_base == (void *) -1) {
		perror("mmap");
		goto exit;
	}

	/* map share memory physical memory space into process memory space */
	share_base = (void *)mmap(NULL, CONFIG_SYS_DDR_SDRAM_SHARE_SIZE,
				PROT_WRITE | PROT_READ, MAP_SHARED,
				shd_memfd, share_addr);

	if (share_base == (void *) -1) {
		perror("mmap");
		goto exit;
	}

	printf("gic_base: %p, share_base: %p, share_phy: 0x%x, block_phy: 0x%x\n",
		gic_base, share_base,
		ICC_CORE_MEM_BASE_PHY(mycoreid),
		ICC_CORE_BLOCK_BASE_PHY(mycoreid));
	printf("\n");

	icc_init();
	if (argc == 2) {
		if (strncmp(argv[1], "show", 4) == 0) {
			do_icc_show();
			goto exit;
		}
		if (strncmp(argv[1], "get", 3) == 0) {
			do_icc_receive();
			goto exit;
		}
	}

	if (argc == 4) {
		if (strncmp(argv[1], "irq", 3) == 0) {
			do_icc_irq_cores(argc, argv);
			goto exit;
		}
		if (strncmp(argv[1], "write", 5) == 0) {
			do_icc_write_register(argc, argv);
			goto exit;
		}
		if (strncmp(argv[1], "read", 4) == 0) {
			do_icc_read_register(argc, argv);
			goto exit;
		}
		if (strncmp(argv[1], "perf", 4) == 0) {
			do_icc_perf(argc, argv);
			goto exit;
		}
	}

	if (argc == 5) {
		if (strncmp(argv[1], "send", 4) == 0) {
			do_icc_send(argc, argv);
			goto exit;
		}
	}

	printf("\n");

	usage(argv[0]);
exit:
	close(memfd);
	close(shd_memfd);
	return 0;
}
