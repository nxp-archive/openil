#!/usr/bin/env bash

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

gen_extlinux()
{
	local in="board/nxp/common/extlinux.conf"
	local out="${BINARIES_DIR}/extlinux.conf"
	local kernel=
	local dtbs=

	if grep -Eq "^BR2_LINUX_KERNEL_UIMAGE=y$" ${BR2_CONFIG}; then
		kernel="../uImage"
	else
		kernel="../zImage"
	fi

	for dt in "$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\([a-z0-9 \-]*\)"$/\1/p' ${BR2_CONFIG})"; do
		# Discard any dtb in the list except the last
		dtb="../$dt.dtb"
	done

	cp -f "${in}" "${out}"
	sed -i -e "s|%KERNEL%|${kernel}|g" \
		-e "s|%DTB%|${dtb}|g" \
		-e "s|%VERSION%|${BR2_OPENIL_VERSION}|g" \
		-e "s|%BOARD%|NXP LS1021A-TSN|g" \
		"${out}"
}

main()
{
	mkimage -A arm -T ramdisk -C gzip -d ${BINARIES_DIR}/rootfs.ext2.gz ${BINARIES_DIR}/rootfs.ext2.gz.uboot

	# define board name in version.json for ota feature
	local BOARDNAME="ls1021atsn"
	sed -e "s/%PLATFORM%/${BOARDNAME}/" board/nxp/common/version.json > ${BINARIES_DIR}/version.json

	local FILES="$(dtb_list) $(linux_image), "version.json", "rootfs.ext2.gz.uboot""
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

	gen_extlinux

	sed -e "s/%FILES%/${FILES}/" \
		board/nxp/ls1021atsn/genimage.cfg.template > ${GENIMAGE_CFG}

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
