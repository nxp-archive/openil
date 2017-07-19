#!/usr/bin/env bash

# $2 buildroot top directory
#
# dtb_list extracts the list of DTB files from BR2_LINUX_KERNEL_INTREE_DTS_NAME
# in ${BR_CONFIG}, then prints the corresponding list of file names for the
# genimage configuration file
#
dtb_list()
{
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
linux_image()
{
	if grep -Eq "^BR2_LINUX_KERNEL_UIMAGE=y$" ${BR2_CONFIG}; then
		echo "\"uImage\""
	else
		echo "\"zImage\""
	fi
}

main()
{
	local MKIMAGE=${HOST_DIR}/usr/bin/mkimage
	${MKIMAGE} -A arm -T ramdisk -C gzip -d ${BINARIES_DIR}/rootfs.ext2.gz ${BINARIES_DIR}/rootfs.ext2.gz.uboot

	${MKIMAGE} -A arm -T script -a 0 -e 0x40 -d board/nxp/ls1021atsn/bootscript.txt.tee ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703/bootscript
	# create secure boot header for each image
	local FILE_SRKPRI="${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703/srk.pri"
	local FILE_SRKPUB="${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703/srk.pub"
	local FILE_SRKPRI_SPEC="board/nxp/ls1021atsn/srk.pri"
	local FILE_SRKPUB_SPEC="board/nxp/ls1021atsn/srk.pub"
	echo "#--------------- Check specify srk.pri and srk.pub -----------------#"
	if [ -f "$FILE_SRKPRI_SPEC" ] && [ -f "$FILE_SRKPUB_SPEC" ]; then
		echo "Find specify srk.pri and srk.pub at board/nxp/ls1021atsn/, use them!"
		echo "If you want new keys, please delete the srk.pri and srk.pub from board/nxp/ls1021atsn/"
		echo "and from ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703/"
		cp ${FILE_SRKPRI_SPEC} ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703
		cp ${FILE_SRKPUB_SPEC} ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703
	else
		echo "There are no srk.pri and srk.pub at board/nxp/ls1021atsn/"
	fi
	cd ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703
	# copy all needed images
	cp ${BINARIES_DIR}/u-boot-with-spl-pbl.bin ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703
	cp ${BINARIES_DIR}/u-boot-spl.bin ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703
	cp ${BINARIES_DIR}/u-boot-dtb.bin ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703
	cp ${BINARIES_DIR}/uImage ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703/uImage.bin
	cp ${BINARIES_DIR}/ls1021a-tsn.dtb ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703/uImage.dtb
	cp ${BINARIES_DIR}/rootfs.ext2.gz.uboot ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703/rootfs
	cp ${BINARIES_DIR}/tee.bin ${BUILD_DIR}/host-cst-fsl-sdk-v2.0-1703
	if [ -f "$FILE_SRKPRI" ] && [ -f "$FILE_SRKPUB" ]; then
		echo "There are srk.pri and srk.pub, don't need to run gen_keys"
	else
		echo "No srk.pri and srk.pub, run gen_keys"
		# create the public and private keys
		./gen_keys 1024
	fi
	# create csf header for all the images
	./uni_sign input_files/uni_sign/ls1/sdboot/input_uboot_secure | tee ${BINARIES_DIR}/srk.txt
	./uni_sign input_files/uni_sign/ls1/sdboot/input_uimage_secure
	./uni_sign input_files/uni_sign/ls1/sdboot/input_bootscript_secure
	./uni_sign input_files/uni_sign/ls1/sdboot/input_rootfs_secure
	./uni_sign input_files/uni_sign/ls1/sdboot/input_dtb_secure
	./uni_sign input_files/uni_sign/ls1/sdboot/input_spl_uboot_secure
	./uni_sign input_files/uni_sign/ls1/sdboot/input_tee_secure
	# final update the rcw for secure boot
	./uni_pbi input_files/uni_pbi/ls1/input_pbi_sd_secure
	# copy all the created images to binary directory
	cp u-boot-with-spl-pbl-sec.bin ${BINARIES_DIR}
	cp hdr_linux.out ${BINARIES_DIR}
	cp hdr_dtb.out ${BINARIES_DIR}
	cp hdr_rootfs.out ${BINARIES_DIR}
	cp hdr_tee.out ${BINARIES_DIR}
	cp uImage.bin ${BINARIES_DIR}
	cp uImage.dtb ${BINARIES_DIR}
	cp rootfs ${BINARIES_DIR}
	echo ${2}
	cd ${2}

	local FILES="$(dtb_list) $(linux_image)"
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

	echo ${BR2_ROOTFS_PARTITION_SIZE}
	sed -e "s/%FILES%/${FILES}/" -e "s/%PARTITION_SIZE%/${BR2_ROOTFS_PARTITION_SIZE}/" \
		board/nxp/ls1021atsn/genimage.optee-cfg.template > ${GENIMAGE_CFG}

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
