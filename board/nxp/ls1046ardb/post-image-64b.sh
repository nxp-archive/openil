#!/usr/bin/env bash
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2 linux building directory
# $3 buildroot top directory
# $4 u-boot building directory

main()
{
	echo ${2}
	echo ${3}
	echo ${4}
	echo ${BR2_ROOTFS_PARTITION_SIZE}

	cd ${3}
	# build the ramdisk rootfs
	mkimage -A arm -T ramdisk -C gzip -d ${BINARIES_DIR}/rootfs.ext2.gz ${BINARIES_DIR}/rootfs.ext2.gz.uboot

	# define board name in version.json for ota feature
	local BOARDNAME="ls1046ardb-64b"
	sed -e "s/%PLATFORM%/${BOARDNAME}/" board/nxp/common/version.json > ${BINARIES_DIR}/version.json

	# build the SDcard image
	local FILES=""Image", "fsl-ls1046a-rdb-sdk.dtb", "version.json""
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

	sed -e "s/%FILES%/${FILES}/" -e "s/%PARTITION_SIZE%/${BR2_ROOTFS_PARTITION_SIZE}/" \
		board/nxp/ls1046ardb/genimage.cfg.template > ${GENIMAGE_CFG}

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
