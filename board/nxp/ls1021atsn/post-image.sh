#!/usr/bin/env bash

set -e -u -o pipefail

source board/nxp/common/post-image.sh

main()
{
	mkimage -A arm -T ramdisk -C gzip \
		-d "${BINARIES_DIR}/rootfs.ext2.gz" \
		"${BINARIES_DIR}/rootfs.ext2.gz.uboot"

	do_genimage \
		"board/nxp/ls1021atsn/genimage.cfg.template" \
		"ls1021atsn" \
		"NXP LS1021A-TSN" \
		"uImage ls1021a-tsn.dtb version.json rootfs.ext2.gz.uboot"
}

main $@
