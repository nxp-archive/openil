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
	echo ${CST_VERSION}

	# build the itb image
	cp board/nxp/ls1046ardb/kernel-ls1046a-rdb.its ${2}/
	cp output/images/fsl-ls1046a-rdb-sdk.dtb ${2}/
	cp ${BINARIES_DIR}/rootfs.cpio.gz ${2}/fsl-image-core-ls1046ardb.cpio.gz
	cd ${2}/
	/usr/bin/mkimage -f kernel-ls1046a-rdb.its kernel-ls1046a-rdb.itb
	cd ${3}
	cp ${2}/kernel-ls1046a-rdb.itb ${BINARIES_DIR}/
	rm ${2}/fsl-image-core-ls1046ardb.cpio.gz
	rm ${2}/fsl-ls1046a-rdb-sdk.dtb
	rm ${2}/kernel-ls1046a-rdb.itb
	rm ${2}/kernel-ls1046a-rdb.its

	# define board name in version.json for ota feature
	local BOARDNAME="ls1046ardb-64b"
	sed -e "s/%PLATFORM%/${BOARDNAME}/" board/nxp/common/version.json > ${BINARIES_DIR}/version.json

	mkimage -A arm -T script -a 0 -e 0x40 -d board/nxp/ls1046ardb/bootscript.txt.qspi ${BUILD_DIR}/host-cst-${CST_VERSION}/bootscript
	# create secure boot header for each image
	local FILE_SRKPRI="${BUILD_DIR}/host-cst-${CST_VERSION}/srk.pri"
	local FILE_SRKPUB="${BUILD_DIR}/host-cst-${CST_VERSION}/srk.pub"
	local FILE_SRKPRI_SPEC="board/nxp/ls1046ardb/srk.pri"
	local FILE_SRKPUB_SPEC="board/nxp/ls1046ardb/srk.pub"
	echo "#--------------- Check specify srk.pri and srk.pub -----------------#"
	if [ -f "$FILE_SRKPRI_SPEC" ] && [ -f "$FILE_SRKPUB_SPEC" ]; then
		echo "Find specify srk.pri and srk.pub at board/nxp/ls1046ardb/, use them!"
		echo "If you want new keys, please delete the srk.pri and srk.pub from board/nxp/ls1046ardb/"
		echo "and from ${BUILD_DIR}/host-cst-${CST_VERSION}/"
		cp ${FILE_SRKPRI_SPEC} ${BUILD_DIR}/host-cst-${CST_VERSION}
		cp ${FILE_SRKPUB_SPEC} ${BUILD_DIR}/host-cst-${CST_VERSION}
	else
		echo "There are no srk.pri and srk.pub at board/nxp/ls1046ardb/"
	fi
	cd ${BUILD_DIR}/host-cst-${CST_VERSION}
	# copy all needed images
	cp ${BINARIES_DIR}/kernel-ls1046a-rdb.itb ./kernel.itb
	if [ -f "$FILE_SRKPRI" ] && [ -f "$FILE_SRKPUB" ]; then
		echo "There are srk.pri and srk.pub, don't need to run gen_keys"
	else
		echo "No srk.pri and srk.pub, run gen_keys"
		# create the public and private keys
		./gen_keys 1024
	fi
	# create csf header for all the images
	./platforms/ls104x_1012_qspi.sh
	# copy all the created images to binary directory
	cp hdr_kernel.out ${BINARIES_DIR}
	cp hdr_bs.out ${BINARIES_DIR}
	cp bootscript ${BINARIES_DIR}
	cp secboot_hdrs_qspiboot.bin ${BINARIES_DIR}
	cp srk_hash.txt ${BINARIES_DIR}
	echo ${3}
	cd ${3}

	# build the SDcard image
	local FILES=""kernel-ls1046a-rdb.itb", "version.json""
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

	sed -e "s/%FILES%/${FILES}/" -e "s/%PARTITION_SIZE%/${BR2_ROOTFS_PARTITION_SIZE}/" \
		board/nxp/ls1046ardb/genimage.qspi-sb-cfg.template > ${GENIMAGE_CFG}

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
