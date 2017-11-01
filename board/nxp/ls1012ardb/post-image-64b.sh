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

	rm -rf board/nxp/ls1012ardb/temp
	mkdir board/nxp/ls1012ardb/temp

	# Copy the uboot mkimage to output/host/usr/bin for the PPA building
	cp ${4}/tools/mkimage output/host/usr/bin

	local MKIMAGE=${HOST_DIR}/usr/bin/mkimage

	# build the ppa firmware
	make ppa-build
	cp ${BUILD_DIR}/ppa-fsl-sdk-v2.0-1703/ppa/soc-ls1012/build/obj/ppa.itb output/images

	# obtain the rcw image
	tar zxf dl/rcw-fsl-sdk-v2.0-1701.tar.gz -C board/nxp/ls1012ardb/temp/
	cp board/nxp/ls1012ardb/temp/rcw-fsl-sdk-v2.0-1701/ls1012ardb/R_SPNH_3508/PBL_0x35_0x08_800_250_1000_default.bin output/images

	# build the itb image
	cp output/images/fsl-ls1012a-rdb.dtb ${2}/
	cp ${BINARIES_DIR}/rootfs.ext2.gz ${2}/fsl-image-core-ls1012ardb-20160616014215.rootfs.ext2.gz
	cd ${2}/
	${MKIMAGE} -f kernel-ls1012a-rdb.its kernel-ls1012a-rdb.itb
	cd ${3}
	cp ${2}/kernel-ls1012a-rdb.itb ${BINARIES_DIR}/
	rm ${2}/fsl-image-core-ls1012ardb-20160616014215.rootfs.ext2.gz
	rm ${2}/fsl-ls1012a-rdb.dtb
	rm ${2}/kernel-ls1012a-rdb.itb

	# build the ramdisk rootfs
	${MKIMAGE} -A arm -T ramdisk -C gzip -d ${BINARIES_DIR}/rootfs.ext2.gz ${BINARIES_DIR}/rootfs.ext2.gz.uboot

	# define board name in version.json for ota feature
	local BOARDNAME="ls1012ardb-64b"
	sed -e "s/%PLATFORM%/${BOARDNAME}/" board/nxp/common/version.json > ${BINARIES_DIR}/version.json

	# build the SDcard image
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

	mv ${BINARIES_DIR}/sdcard.img ${BINARIES_DIR}/qspi.img

	exit $?
}

main $@
