#!/usr/bin/env bash

main()
{
	echo ${1}

	cd ${1}
	# remove the var/run runtime deirectory
	rm var/run

	# change the hostname to "OpenIL-Ubuntu-LS1028ARDB"
	sed -i 's/localhost.localdomain/OpenIL-Ubuntu-Lx2160ARDB/' etc/hostname

	# enable the root user login
	sed -i 's/root:\*:/root::/' etc/shadow

	#resize the partition2
	sed -i "/exit 0/i\resize2fs /dev/mmcblk0p2" etc/rc.local

	# create the link for mount and umount for the systemd
	ln -s /bin/mount usr/bin/mount
	ln -s /bin/umount usr/bin/umount

	exit $?
}

main $@
