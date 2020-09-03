#!/bin/sh
#
host_packages_list="vim git make net-tools build-essential cpio autotools-dev automake dh-autoreconf binfmt-support qemu-system-common qemu-user-static debootstrap u-boot-tools binutils bash patch gzip bzip2 tar wget libncurses5-dev unzip python3-pyelftools python-pyelftools python3-pycryptodome python-pycryptodome pkg-config libtool rsync file bc openssl sed libssl-dev autogen bison flex inetutils-ping"

main()
{
	echo "Checking the packages required on host!"
        echo "These packages will be installed if they are not exist!"
	for pkg in $host_packages_list; do
		if ! dpkg-query -l $pkg | grep ii 1>/dev/null; then
			echo Installing $pkg
			sudo apt -y install $pkg
		fi
	done

}

main $@
