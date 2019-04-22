/*
 * Copyright 2018 NXP
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
#include <signal.h>

#include "inter-core-comm.h"

struct icc_ring *ring[CONFIG_MAX_CPUS];
int blocks[ICC_CORE_BLOCK_COUNT];
unsigned int block_idx;
void *g_icc_irq_cb[CONFIG_MAX_CPUS] = {NULL};
int fd;

#define block2index(x) ((x - ICC_CORE_BLOCK_BASE_PHY(mycoreid)) / ICC_BLOCK_UNIT_SIZE)
#define index2block(x) (ICC_CORE_BLOCK_BASE_PHY(mycoreid) + (x * ICC_BLOCK_UNIT_SIZE))

static int icc_ring_empty(struct icc_ring *ring)
{
	if (ring->desc_tail == ring->desc_head)
		return 1;
	return 0;
}

static int icc_ring_full(struct icc_ring *ring)
{
	if (((ring->desc_head + 1) % ring->desc_num) == ring->desc_tail)
		return 1;
	return 0;
}

/* how many rx blocks are valid waiting to be handled */
static int icc_ring_valid(struct icc_ring *ring)
{
	int valid;

	if (icc_ring_empty(ring))
		return 0;

	if (ring->desc_head > ring->desc_tail)
		valid = ring->desc_head - ring->desc_tail;
	else
		valid = ring->desc_num - ring->desc_tail + ring->desc_head;
	return valid;
}

/* check the block legal in this core; 0:illegal, 1:legal */
static int icc_block_legal(unsigned long block)
{
	if ((block >= ICC_CORE_BLOCK_BASE_PHY(mycoreid))
		&& (block < ICC_CORE_BLOCK_END_PHY(mycoreid))
		&& !(block % ICC_BLOCK_UNIT_SIZE))
		return 1;
	else
		return 0;
}

/*
 * check the state of ring for one destination core.
 * return: 0 - empty or input error
 *	   !0 - the working block address currently
 */
unsigned long icc_ring_state(int coreid)
{
	unsigned int tail;
	struct icc_desc *desc;

	if ((coreid >= CONFIG_MAX_CPUS) || (coreid == mycoreid)) {
		printf("Input coreid: %d error\n", coreid);
		return 0;
	}
	if (icc_ring_empty(ring[coreid]))
		return 0;

	tail = ring[coreid]->desc_tail;
	desc = ICC_PHY2VIRT(ring[coreid]->desc);

	return desc[tail].block_addr;
}

unsigned long icc_block_request(void)
{
	unsigned int idx = block_idx;
	struct icc_desc *desc = NULL;
	struct icc_desc *desc_phy = NULL;
	unsigned long block;
	int i;

	for (i = 0; i < CONFIG_MAX_CPUS; i++) {
		if (mycoreid != i) {
			desc_phy = ring[i]->desc + ring[i]->desc_head;
			desc = ICC_PHY2VIRT(desc_phy);
			if (desc->block_addr) {
				block = desc->block_addr;
				blocks[block2index(block)] &= ~(0x1 << ring[i]->dest_coreid);
				if (!blocks[block2index(block)]) {
					desc->block_addr = 0;
					blocks[block2index(block)] = CONFIG_MAX_CPUS;
					return block;
				}
			}
		}
	}

	while (blocks[block_idx]) {
		block_idx = (block_idx + 1) % ICC_CORE_BLOCK_COUNT;
		if (idx == block_idx) {
			printf("No available block at core %d!\n", mycoreid);
			return 0;
		}
	}
	blocks[block_idx] = CONFIG_MAX_CPUS;
	return index2block(block_idx); 
}

void icc_block_free(unsigned long block)
{
	if (!icc_block_legal(block))
		return;

	blocks[block2index(block)] = 0;
}

void icc_set_sgi(int core_mask, unsigned int hw_irq)
{
	unsigned long val;
	char hostname[32];

	if(hw_irq > 15) {
		printf ("Interrupt id num: %lu is not valid, SGI[0 - 15]\n", hw_irq);
		return;
	}

	if (gethostname(hostname,sizeof(hostname))) {
		printf ("gethostname error");
		return;
	}
	if (strstr(hostname, "LS1028A")) { /* Check the LS1028A board */
		val = core_mask | hw_irq << 24;
		if (ioctl(shd_memfd, 1, &val))
			printf("Triger Interrupt failed\n");
	} else { /* Other board */
		val = (core_mask << 16) | 0x8000 | hw_irq;
		*((volatile unsigned int *)((void *)gic_base + GIC_DIST_SOFTINT)) = val;
	}
}

int icc_set_block(int core_mask, unsigned int byte_count, unsigned long block)
{
	struct icc_desc *desc = NULL;
	struct icc_desc *desc_phy = NULL;
	int i, full;
	int dest_core = core_mask & (~(0x1 << mycoreid));

	if (!dest_core)
		return -1;

	full = 0;
	for (i = 0; i < CONFIG_MAX_CPUS; i++) {
		if ((dest_core >> i) & 0x1) {
			if (icc_ring_full(ring[i])) {
				ring[i]->busy_counts++;
				full++;
			}
		}
	}
	if (full)
		return -1;

	if (byte_count > ICC_BLOCK_UNIT_SIZE) {
		printf("Set block failed! core_mask: 0x%x, byte_count: %d, max byte: %d\n",
			core_mask, byte_count, ICC_BLOCK_UNIT_SIZE);
		return -1;
	}

	if (!icc_block_legal(block)) {
		printf("The block 0x%lx is illegal!\n", block);
		return -1;
	}

	blocks[block2index(block)] = dest_core;
	for (i = 0; i < CONFIG_MAX_CPUS; i++) {
		if ((dest_core >> i) & 0x1) {
			desc_phy = ring[i]->desc + ring[i]->desc_head;
			desc = ICC_PHY2VIRT(desc_phy);
			if (desc->block_addr) {
				blocks[block2index(desc->block_addr)] &= ~(0x1 << ring[i]->dest_coreid);
			}
			desc->block_addr = block;
			desc->byte_count = byte_count;
			ring[i]->desc_head = (ring[i]->desc_head + 1) % ring[i]->desc_num;
			ring[i]->interrupt_counts++;
		}
	}

	/* trigger the inter-core interrupt */
	icc_set_sgi(dest_core, ICC_SGI);

	return 0;
}

static int icc_check_resource(int coreid)
{
	/* check ring and desc space */
	if ((ICC_RING_ENTRY * CONFIG_MAX_CPUS * sizeof(struct icc_desc)
	    + CONFIG_MAX_CPUS * sizeof(struct icc_ring))
	    > ICC_RING_DESC_SPACE) {
		printf("The memory size %d is not enough for core%d %d rings and %d desc\n",
			ICC_RING_DESC_SPACE, coreid, CONFIG_MAX_CPUS,
			CONFIG_MAX_CPUS * ICC_RING_ENTRY);
		return -1;
	}
	return 0;
}

static void icc_ring_init(int coreid)
{
	int i, k;
	struct icc_desc *desc;

	for (i = 0; i < CONFIG_MAX_CPUS; i++) {
		ring[i] = (struct icc_ring *)ICC_CORE_RING_BASE(coreid, i);

		ring[i]->src_coreid = coreid;
		ring[i]->dest_coreid = i;
		ring[i]->interrupt = ICC_SGI;
		ring[i]->desc_num = ICC_RING_ENTRY;
		ring[i]->desc_head = 0;
		ring[i]->desc_tail = 0;
		ring[i]->busy_counts = 0;
		ring[i]->interrupt_counts = 0;
		ring[i]->desc = (struct icc_desc *)(ICC_CORE_DESC_BASE_PHY(coreid)
				+ i * ICC_RING_ENTRY * sizeof(struct icc_desc));

		/* init desc */
		desc = ICC_PHY2VIRT(ring[i]->desc);
		for (k = 0; k < ICC_RING_ENTRY; k++) {
			desc[k].block_addr = 0;
			desc[k].byte_count = 0;
		}
	}
}

static void icc_irq_handler(int n, siginfo_t *info, void *unused)
{
	struct icc_ring *ring;
	struct icc_desc *desc;
	struct icc_desc *desc_phy;
	unsigned long block_addr;
	unsigned int byte_count;
	int i, valid;
	void (*irq_handle)(int, unsigned long, unsigned int);
	int hw_irq, src_coreid;

	hw_irq = info->si_int >> 16;
	src_coreid = info->si_int & 0xffff;

	if (hw_irq != ICC_SGI) {
		printf("Get the wrong SGI number: %d, expect: %d\n", hw_irq, ICC_SGI);
		return;
	}

	if (src_coreid == mycoreid) {
		printf("Do not support self-icc now!\n");
		return;
	}

	/* get the ring for this core from source core */
	ring = (struct icc_ring *)ICC_CORE_RING_BASE(src_coreid, mycoreid);
	valid = icc_ring_valid(ring);
	for (i = 0; i < valid; i++) {
		desc_phy = ring->desc + ring->desc_tail;
		desc = ICC_PHY2VIRT(desc_phy);
		block_addr = desc->block_addr;
		byte_count = desc->byte_count;

		irq_handle = (void (*)(int, unsigned long, unsigned int))g_icc_irq_cb[src_coreid];
		if (irq_handle)
			irq_handle(src_coreid, block_addr, byte_count);
		else
			printf("Get the SGI %d from core %d; block: 0x%lx, byte: %d\n",
				hw_irq, src_coreid, block_addr, byte_count);

		/* add desc_tail */
		ring->desc_tail = (ring->desc_tail + 1) % ring->desc_num;
	}
}

int icc_irq_register(int src_coreid, void (*irq_handle)(int, unsigned long, unsigned int))
{
	int i;
	char buf[10];
	struct sigaction sig;

	if ((src_coreid > CONFIG_MAX_CPUS) || (src_coreid == mycoreid))
		return -1;
	else if (src_coreid == CONFIG_MAX_CPUS) {
		for (i = 0; i < CONFIG_MAX_CPUS; i++) {
			g_icc_irq_cb[i] = (void *)irq_handle;
		}
		g_icc_irq_cb[mycoreid] = NULL;
	} else
		g_icc_irq_cb[src_coreid] = (void *)irq_handle;

	sig.sa_sigaction = icc_irq_handler;
	sig.sa_flags = SA_SIGINFO;
	sigaction(SIG_BM, &sig, NULL);

	fd = open(DEVICE_BM, O_WRONLY);
	if(fd < 0) {
		perror("open");
		return -1;
	}

	sprintf(buf, "%i", getpid());
	if (write(fd, buf, strlen(buf) + 1) < 0) {
		perror("fwrite");
		return -1;
	}

	return 0;
}

int icc_irq_release(void)
{
	close(fd);
	return 0;
}

int icc_init(void)
{
	int ret;

	mycoreid = 0;
	ret = icc_check_resource(mycoreid);
	if (ret) {
		printf("Core%d check resource failed! %d\n", mycoreid, ret);
		return ret;
	}

	icc_ring_init(mycoreid);

	return 0;
}

void icc_show(void)
{
	int i;

	printf("all cores: reserved_share_memory_base: 0x%lx; size: %d\n",
		CONFIG_SYS_DDR_SDRAM_SHARE_RESERVE_BASE,
		CONFIG_SYS_DDR_SDRAM_SHARE_RESERVE_SIZE);
	printf("\n");
	printf("mycoreid: %d; ICC_SGI: %d; share_memory_size: %d\n",
		mycoreid, ICC_SGI, ICC_CORE_MEM_SPACE);
	printf("block_unit_size: %d; block number: %d; block_idx: %d\n",
		ICC_BLOCK_UNIT_SIZE, ICC_CORE_BLOCK_COUNT, block_idx);

	for (i = 0; i < CONFIG_MAX_CPUS; i++) {
		printf("\n");
		printf("#ring %d base: %p; dest_core: %d; SGI: %d\n",
		       i, ring[i], ring[i]->dest_coreid, ring[i]->interrupt);
		printf("desc_num: %d; desc_base: %p; head: %d; tail: %d\n",
		       ring[i]->desc_num, ring[i]->desc, ring[i]->desc_head, ring[i]->desc_tail);
		printf("busy_counts: %ld; interrupt_counts: %ld\n",
			ring[i]->busy_counts, ring[i]->interrupt_counts);
	}
}
