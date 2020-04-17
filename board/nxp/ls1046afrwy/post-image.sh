#!/usr/bin/env bash
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2 linux building directory
# $3 buildroot top directory
# $4 u-boot building directory

#
# dtb_list extracts the list of DTB files from BR2_LINUX_KERNEL_INTREE_DTS_NAME
# in ${BR_CONFIG}, then prints the corresponding list of file names for the
# genimage configuration file
#
dtb_file()
{
	local DTB_LIST="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\([\/a-z0-9 \-]*\)"$/\1/p' ${BR2_CONFIG})"

	for dt in $DTB_LIST; do
		echo -n "\"`basename $dt`.dtb\", "
	done
}

plat_name()
{
	if grep -Eq "^BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM=\"ls1046afrwy\"$" ${BR2_CONFIG}; then
		echo "ls1046afrwy"
	fi
}

#
# genimage.sd.cfg.template: Boot from SD
# genimage.emmc.cfg.template: Boot from eMMC
#
genimage_type()
{
	if grep -Eq "^BR2_PACKAGE_HOST_QORIQ_RCW_BOOT_MODE=\"qspi\"$" ${BR2_CONFIG}; then
		echo "genimage.qspi.cfg.template"
	elif grep -Eq "^BR2_PACKAGE_HOST_QORIQ_RCW_BOOT_MODE=\"flexspi_nor\"$" ${BR2_CONFIG}; then
		echo "genimage.xspi.cfg.template"
	elif grep -Eq "^BR2_PACKAGE_HOST_QORIQ_RCW_BOOT_MODE=\"emmc\"$" ${BR2_CONFIG}; then
		echo "genimage.emmc.cfg.template"
	elif grep -Eq "^BR2_PACKAGE_HOST_QORIQ_RCW_BOOT_MODE=\"sd\"$" ${BR2_CONFIG}; then
		echo "genimage.sd.cfg.template"
	fi
}

main()
{
	local FILES="$(dtb_file) "Image""
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

	sed -e "s/%FILES%/${FILES}/" \
		board/nxp/$(plat_name)/$(genimage_type) > ${GENIMAGE_CFG}

	rm -rf "${GENIMAGE_TMP}"

	genimage \
		--rootpath "${TARGET_DIR}" \
		--tmppath "${GENIMAGE_TMP}" \
		--inputpath "${BINARIES_DIR}" \
		--outputpath "${BINARIES_DIR}" \
		--config "${GENIMAGE_CFG}"

	rm -f ${GENIMAGE_CFG}

	exit $?
}

main $@
