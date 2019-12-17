#!/usr/bin/env bash
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2 linux building directory
# $3 buildroot top directory
# $4 uboot building directory

main()
{
	echo ${2}
	echo ${3}
	echo ${4}

	# build the itb image
	cp board/nxp/ls1012ardb/kernel-ls1012a-rdb.its ${2}/
	cp output/images/fsl-ls1012a-rdb.dtb ${2}/
	cp ${BINARIES_DIR}/rootfs.cpio.gz ${2}/fsl-image-core-ls1012ardb.rootfs.cpio.gz
	cd ${2}/
	/usr/bin/mkimage -f kernel-ls1012a-rdb.its kernel-ls1012a-rdb.itb
	cd ${3}
	cp ${2}/kernel-ls1012a-rdb.itb ${BINARIES_DIR}/
	rm ${2}/fsl-image-core-ls1012ardb.rootfs.cpio.gz
	rm ${2}/fsl-ls1012a-rdb.dtb
	rm ${2}/kernel-ls1012a-rdb.itb
	rm ${2}/kernel-ls1012a-rdb.its

	# define board name in version.json for ota feature
	local BOARDNAME="ls1012ardb-64b"
	sed -e "s/%PLATFORM%/${BOARDNAME}/" board/nxp/common/version.json > ${BINARIES_DIR}/version.json

	# build the QSPI image
	local FILES=""kernel-ls1012a-rdb.itb", "version.json""
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

	sed -e "s/%FILES%/${FILES}/" \
		board/nxp/ls1012ardb/genimage.cfg.template > ${GENIMAGE_CFG}

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
