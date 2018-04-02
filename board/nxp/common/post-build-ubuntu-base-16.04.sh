#!/usr/bin/env bash
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2 linux building directory
# $3 buildroot top directory
# $4 u-boot building directory

main()
{
	echo ${SKELETON_DIRE}

	# Copy the original Ubuntu systemd binaries and services to target
	cp ${SKELETON_DIRE}/bin/systemctl ${TARGET_DIR}/bin/
	cp ${SKELETON_DIRE}/bin/systemd-* ${TARGET_DIR}/bin/
	cp ${SKELETON_DIRE}/lib/systemd/systemd* ${TARGET_DIR}/lib/systemd/
	cp ${SKELETON_DIRE}/lib/systemd/systemd ${TARGET_DIR}/lib/systemd/
	cp ${SKELETON_DIRE}/usr/bin/systemd-* ${TARGET_DIR}/usr/bin/
	cp ${SKELETON_DIRE}/lib/systemd/system/systemd-journald.service ${TARGET_DIR}/lib/systemd/system/
	cp ${SKELETON_DIRE}/lib/systemd/system/systemd-timesyncd.service ${TARGET_DIR}/lib/systemd/system/
	cp ${SKELETON_DIRE}/lib/systemd/system/systemd-networkd.service ${TARGET_DIR}/lib/systemd/system/
	cp ${SKELETON_DIRE}/lib/systemd/system/systemd-timedated.service ${TARGET_DIR}/lib/systemd/system/
	cp ${SKELETON_DIRE}/lib/systemd/system/systemd-resolved.service ${TARGET_DIR}/lib/systemd/system/
	cp ${SKELETON_DIRE}/lib/systemd/system/systemd-hostnamed.service ${TARGET_DIR}/lib/systemd/system/

	exit $?
}

main $@
