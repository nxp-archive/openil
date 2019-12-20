#!/usr/bin/env bash
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2 linux building directory
# $3 buildroot top directory

main()
{
	echo ${3}
	echo ${2}

	# cp the pre-build uboot, paa and dtb images to output/images
	cp board/nxp/ls1012ardb/temp/* output/images/

	# build the itb image
	cp board/nxp/ls1012ardb/kernel-ls1012a-rdb-aarch32.its ${2}/
	cp output/images/fsl-ls1012a-rdb.dtb ${2}/
	cp ${BINARIES_DIR}/rootfs.cpio.gz ${2}/fsl-image-core-ls1012ardb-32b.cpio.gz
	cd ${2}/
	/usr/bin/mkimage -f kernel-ls1012a-rdb-aarch32.its kernel-ls1012a-rdb-aarch32.itb
	cd ${3}
	cp ${2}/kernel-ls1012a-rdb-aarch32.itb ${BINARIES_DIR}/
	rm ${2}/fsl-image-core-ls1012ardb-32b.cpio.gz
	rm ${2}/fsl-ls1012a-rdb.dtb
	rm ${2}/kernel-ls1012a-rdb-aarch32.itb
	rm ${2}/kernel-ls1012a-rdb-aarch32.its
	ln -s ${BINARIES_DIR}/kernel-ls1012a-rdb-aarch32.itb ${BINARIES_DIR}/kernel-ls1012a-rdb.itb

	# define board name in version.json for ota feature
	local BOARDNAME="ls1012ardb-32b"
	sed -e "s/%PLATFORM%/${BOARDNAME}/" board/nxp/common/version.json > ${BINARIES_DIR}/version.json

	# build the QSPI image
	local FILES=""kernel-ls1012a-rdb-aarch32.itb", "version.json""
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

	sed -e "s/%FILES%/${FILES}/" \
		board/nxp/ls1012ardb/genimage.32b.cfg.template > ${GENIMAGE_CFG}

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
