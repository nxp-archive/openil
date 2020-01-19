#!/usr/bin/env bash

main()
{
	echo ${1}

	cd ${1}
	# remove the var/run runtime deirectory
	rm var/run

	# change the hostname to "OpenIL-Ubuntu"
	sed -i 's/localhost.localdomain/OpenIL-Ubuntu/' etc/hostname

	# enable the root user login
	sed -i 's/root:\*:/root::/' etc/shadow

	#resize the partition2
	sed -i "/exit 0/i\resize2fs /dev/mmcblk0p2" etc/rc.local

	# create the link for mount and umount for the systemd
	ln -s /bin/mount usr/bin/mount
	ln -s /bin/umount usr/bin/umount

	# set the ttyS0 as the terminal
	# rm etc/systemd/system/getty.target.wants/getty@tty1.service
	# ln -s /lib/systemd/system/getty@.service etc/systemd/system/getty.target.wants/getty@ttyS0.service
	exit $?
}

main $@
