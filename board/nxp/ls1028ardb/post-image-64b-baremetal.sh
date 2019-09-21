#!/usr/bin/env bash

set -e -u -o pipefail

source board/nxp/common/post-image.sh

# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2 linux building directory
# $3 buildroot top directory
# $4 u-boot building directory
# $5 BR2_PACKAGE_OPENIL_RCW_BIN
main()
{
	local RCWFILE="$5"
	local DESTRCW="rcw_1300.bin"

	RCWFILE=${RCWFILE##*/}
	RCWFILE=${RCWFILE%\"*}

	cp ${BINARIES_DIR}/${RCWFILE} ${BINARIES_DIR}/${DESTRCW}

	# build the ramdisk rootfs
	mkimage -A arm -T ramdisk -C gzip -d \
		"${BINARIES_DIR}/rootfs.ext2.gz" \
		"${BINARIES_DIR}/rootfs.ext2.gz.uboot"

	do_genimage \
		"board/nxp/ls1028ardb/genimage.cfg.template" \
		"ls1028ardb-64b" \
		"NXP LS1028A-RDB (Baremetal))" \
		"Image fsl-ls1028a-rdb-sdk-bm.dtb ls1028a-dp-fw.bin version.json bm-u-boot.bin rootfs.ext2.gz.uboot"
}

main $@
