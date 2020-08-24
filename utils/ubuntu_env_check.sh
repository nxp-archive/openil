#!/bin/bash
qemu_check()
{
	for tgtarch  in aarch64 arm ppc64le; do
		qemu-${tgtarch}-static -version > /dev/null 2>&1
		if [ "$?" != "0" ]
		then
			echo "qemu-${tgtarch}-static not found, Try install qemu-user-static package."
			exit 1
		fi
		if [ ! -e /proc/sys/fs/binfmt_misc/qemu-${tgtarch} ]
		then
			echo -e "The qemu-${tgtarch} is disabled, Try:\n\tsudo update-binfmts --enable qemu-${tgtarch}"
			exit 1
		fi
	done
	return 0;
}

qemu_check
debootstrap --version > /dev/null 2>&1
if [ "$?" != "0" ]
then
	echo "debootstrap not found, Try install debootstrap package."
	exit 1
fi
echo "The system is ready for ubuntu rootfs building"
exit 0
