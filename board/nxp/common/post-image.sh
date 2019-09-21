#!/usr/bin/env bash

gen_extlinux()
{
	local board="$1"
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
		-e "s|%BOARD%|${board}|g" \
		"${out}"
}

do_genimage()
{
	local template="$1"
	local platform="$2"
	local distro_boot_name="$3"
	local filelist="$4"
	local genimage_tmp="${BUILD_DIR}/genimage.tmp"
	local genimage_cfg="$(mktemp --suffix genimage.cfg)"
	local files=""

	# define board name in version.json for ota feature
	sed -e "s/%PLATFORM%/${platform}/" board/nxp/common/version.json > \
		${BINARIES_DIR}/version.json

	# Generate extlinux file for U-Boot distro boot
	gen_extlinux "${distro_boot_name}"

	rm -rf "${genimage_tmp}"

	for file in ${filelist}; do
		files="\"${file}\",\n${files}"
	done

	sed -e "s/%FILES%/${files}/" ${template} > ${genimage_cfg}

	genimage \
		--rootpath "${TARGET_DIR}" \
		--inputpath "${BINARIES_DIR}" \
		--outputpath "${BINARIES_DIR}" \
		--tmppath "${genimage_tmp}" \
		--config "${genimage_cfg}"

	rm -rf "${genimage_tmp}"
}
