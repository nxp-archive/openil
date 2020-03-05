#!/usr/bin/env bash
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2 linux building directory
# $3 buildroot top directory
# $4 u-boot building directory

main()
{
	# build the itb image
	cp board/nxp/lx2160ardb/kernel.its ${BINARIES_DIR}/kernel.its
	cd ${BINARIES_DIR}
	/usr/bin/mkimage -f kernel.its kernel.itb
	rm kernel.its

	cd ${3}

	# build the SDcard image
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

	sed -e "s/%FILES%/${FILES}/" \
		board/nxp/lx2160ardb/genimage.xspi.cfg.template > ${GENIMAGE_CFG}

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
