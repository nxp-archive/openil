#!/usr/bin/env bash

main()
{
	# $1 - the target directory
	echo ${1}
        sudo chroot ${1} systemctl enable systemd-openil

	exit $?
}

main $@
