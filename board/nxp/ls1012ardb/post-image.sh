#!/usr/bin/env bash
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2 linux building directory
# $3 buildroot top directory

main()
{
	local MKIMAGE=${HOST_DIR}/usr/bin/mkimage

	echo ${3}
	echo ${2}

	# cp the pre-build uboot mkimage to output/host/usr/bin
	cp board/nxp/ls1012ardb/temp/mkimage output/host/usr/bin
	rm -f board/nxp/ls1012ardb/temp/mkimage

	# cp the pre-build uboot and dtb images to output/images
	rm -f board/nxp/ls1012ardb/temp/Image
	cp board/nxp/ls1012ardb/temp/* output/images/

	# obtain the rcw image
	tar zxf dl/rcw-fsl-sdk-v2.0-1701.tar.gz -C board/nxp/ls1012ardb/temp/
	cp board/nxp/ls1012ardb/temp/rcw-fsl-sdk-v2.0-1701/ls1012ardb/R_SPNH_3508/PBL_0x35_0x08_800_250_1000_default.bin output/images

	# build the itb image
	cp output/images/fsl-ls1012a-rdb.dtb ${2}/
	cp ${BINARIES_DIR}/rootfs.ext2.gz ${2}/fsl-image-core-ls1012ardb-32b.ext2.gz
	cd ${2}/
	${MKIMAGE} -f kernel-ls1012a-rdb-aarch32.its kernel-ls1012a-rdb-aarch32.itb
	cd ${3}
	cp ${2}/kernel-ls1012a-rdb-aarch32.itb ${BINARIES_DIR}/
	rm ${2}/fsl-image-core-ls1012ardb-32b.ext2.gz
	rm ${2}/fsl-ls1012a-rdb.dtb
	rm ${2}/kernel-ls1012a-rdb-aarch32.itb
	ln -s ${BINARIES_DIR}/kernel-ls1012a-rdb-aarch32.itb ${BINARIES_DIR}/kernel-ls1012a-rdb.itb

	# build the ramdisk rootfs
	${MKIMAGE} -A arm -T ramdisk -C gzip -d ${BINARIES_DIR}/rootfs.ext2.gz ${BINARIES_DIR}/rootfs.ext2.gz.uboot

	# define board name in version.json for ota feature
	local BOARDNAME="ls1012ardb-32b"
	sed -e "s/%PLATFORM%/${BOARDNAME}/" board/nxp/common/version.json > ${BINARIES_DIR}/version.json

	# build the SDcard image
	local FILES=""kernel-ls1012a-rdb-aarch32.itb", "version.json""
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

	mv ${BINARIES_DIR}/sdcard.img ${BINARIES_DIR}/qspi.img

	exit $?
}

main $@
