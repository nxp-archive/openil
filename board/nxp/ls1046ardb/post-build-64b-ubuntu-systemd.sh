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

	# Copy the original Ubuntu systemd binaries and services to target
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/bin/systemctl ${3}/output/target/bin/
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/bin/systemd-* ${3}/output/target/bin/
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/lib/systemd/systemd* ${3}/output/target/lib/systemd/
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/lib/systemd/systemd ${3}/output/target/lib/systemd/
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/usr/bin/systemd-* ${3}/output/target/usr/bin/
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/lib/systemd/system/systemd-journald.service ${3}/output/target/lib/systemd/system/
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/lib/systemd/system/systemd-timesyncd.service ${3}/output/target/lib/systemd/system/
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/lib/systemd/system/systemd-networkd.service ${3}/output/target/lib/systemd/system/
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/lib/systemd/system/systemd-timedated.service ${3}/output/target/lib/systemd/system/
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/lib/systemd/system/systemd-resolved.service ${3}/output/target/lib/systemd/system/
	cp ${3}/system/custom-skeleton/ubuntu-base-16.04.2-arm64/lib/systemd/system/systemd-hostnamed.service ${3}/output/target/lib/systemd/system/

	exit $?
}

main $@
