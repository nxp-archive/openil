#!/usr/bin/env bash
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2 linux building directory
# $3 buildroot top directory
# $4 u-boot building directory
#
plat_name()
{
	if grep -Eq "^BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM=\"ls1028ardb\"$" ${BR2_CONFIG}; then
		echo "ls1028ardb"
	fi
}

# genimage.qspi.cfg.template: Boot from 64MB QSPI flash
# genimage.xspi.256MB.cfg.template: Boot from 256MB flexSPI_nor flash
# genimage.xspi.64MB.cfg.template: Boot from 64MB flexSPI_nor flash
# genimage.cfg.template: Boot from SD and eMMC
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
	# build the itb image
	cp board/nxp/$(plat_name)/kernel.its ${BINARIES_DIR}/kernel.its
	cd ${BINARIES_DIR}/
	/usr/bin/mkimage -f kernel.its kernel.itb
	rm kernel.its

	cd ${3}

	# build the SDcard image
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
