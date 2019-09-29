#!/usr/bin/env bash

#
# dtb_list extracts the list of DTB files from BR2_LINUX_KERNEL_INTREE_DTS_NAME
# in ${BR_CONFIG}, then prints the corresponding list of file names for the
# genimage configuration file
#
dtb_list() {
	local DTB_LIST="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\([a-z0-9 \-]*\)"$/\1/p' ${BR2_CONFIG})"

	for dt in $DTB_LIST; do
		echo -n "\"$dt.dtb\", "
	done
}

#
# linux_image extracts the Linux image format from BR2_LINUX_KERNEL_UIMAGE in
# ${BR_CONFIG}, then prints the corresponding file name for the genimage
# configuration file
#
linux_image() {
	if grep -Eq "^BR2_LINUX_KERNEL_UIMAGE=y$" ${BR2_CONFIG}; then
		echo "\"uImage\""
	else
		echo "\"zImage\""
	fi
}

main() {
	# Set in BR2_ROOTFS_POST_SCRIPT_ARGS
	# BINARIES_DIR is $1
	local LINUX_DIR="$2"
	local TOPDIR="$3"
	local UBOOT_DIR="$4"
	local its="bootimage-ls1021a-twr.its"

	mkimage -A arm -T ramdisk -C gzip -d ${BINARIES_DIR}/rootfs.ext2.gz ${BINARIES_DIR}/rootfs.ext2.gz.uboot

	# define board name in version.json for ota feature
	local BOARDNAME="ls1021atwr"
	sed -e "s/%PLATFORM%/${BOARDNAME}/" board/nxp/common/version.json > ${BINARIES_DIR}/version.json

	local FILES="$(dtb_list) $(linux_image), "version.json", "rootfs.ext2.gz.uboot""
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

	sed -e "s/%FILES%/${FILES}/" \
		board/nxp/ls1021atwr/genimage.cfg.template > ${GENIMAGE_CFG}

	rm -rf "${GENIMAGE_TMP}"

	genimage \
		--rootpath "${TARGET_DIR}" \
		--tmppath "${GENIMAGE_TMP}" \
		--inputpath "${BINARIES_DIR}" \
		--outputpath "${BINARIES_DIR}" \
		--config "${GENIMAGE_CFG}"
	rm -f ${GENIMAGE_CFG}

	# build the itb image
	(cd ${BINARIES_DIR};
	cp -f ${LINUX_DIR}/arch/arm/boot/zImage ${TOPDIR}/board/nxp/ls1021atwr/${its} .;
	mkimage -f ${its} bootimage-ls1021a-twr.itb;)

	exit $?
}

main $@
