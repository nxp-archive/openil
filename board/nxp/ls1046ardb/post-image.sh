#!/usr/bin/env bash
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2 linux building directory
# $3 buildroot top directory

main()
{
	echo ${3}
	echo ${2}
	echo ${BR2_ROOTFS_PARTITION_SIZE}

	# cp the pre-build uboot, ppa and dtb images to output/images
	rm -f board/nxp/ls1046ardb/temp/Image
	cp board/nxp/ls1046ardb/temp/* output/images/

	# build the itb image
	cp board/nxp/ls1046ardb/kernel-ls1046a-rdb-aarch32.its ${2}/
	cp output/images/fsl-ls1046a-rdb-sdk.dtb ${2}/
	cp ${BINARIES_DIR}/rootfs.ext2.gz ${2}/fsl-image-core-ls1046ardb-32b.ext2.gz
	cd ${2}/
	/usr/bin/mkimage -f kernel-ls1046a-rdb-aarch32.its kernel-ls1046a-rdb-aarch32.itb
	cd ${3}
	cp ${2}/kernel-ls1046a-rdb-aarch32.itb ${BINARIES_DIR}/
	rm ${2}/fsl-image-core-ls1046ardb-32b.ext2.gz
	rm ${2}/fsl-ls1046a-rdb-sdk.dtb
	rm ${2}/kernel-ls1046a-rdb-aarch32.itb
	rm ${2}/kernel-ls1046a-rdb-aarch32.its

	# build the ramdisk rootfs
	mkimage -A arm -T ramdisk -C gzip -d ${BINARIES_DIR}/rootfs.ext2.gz ${BINARIES_DIR}/rootfs.ext2.gz.uboot

	# define board name in version.json for ota feature
	local BOARDNAME="ls1046ardb-32b"
	sed -e "s/%PLATFORM%/${BOARDNAME}/" board/nxp/common/version.json > ${BINARIES_DIR}/version.json

	# build the SDcard image
	local FILES=""kernel-ls1046a-rdb-aarch32.itb", "version.json""
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
