#!/bin/sh
#
host_packages_list="vim git make net-tools build-essential cpio autotools-dev automake dh-autoreconf binfmt-support qemu-system-common qemu-user-static u-boot-tools binutils bash patch gzip bzip2 tar wget libncurses5-dev unzip python3-pyelftools python-pyelftools python3-pycryptodome python-pycryptodome pkg-config libtool rsync file bc openssl sed libssl-dev autogen bison flex inetutils-ping gtk-doc-tools libglib2.0-dev libxext-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev"

main()
{
	echo "Checking the packages required on host!"
        echo "These packages will be installed if they do not exist!"

	if ! dpkg-query -l debootstrap | grep ii 1>/dev/null; then
		echo "Installing debootstrap-1.0.95ubuntu0.10"
		wget http://ports.ubuntu.com/pool/main/d/debootstrap/debootstrap_1.0.95ubuntu0.10_all.deb
		sudo dpkg -i debootstrap_1.0.95ubuntu0.10_all.deb
		rm debootstrap_1.0.95ubuntu0.10_all.deb
	else
		if ! dpkg-query -l debootstrap | grep 1.0.95ubuntu0.10 1>/dev/null; then
			echo "Reinstalling debootstrap (1.0.95ubuntu0.10)"
			sudo apt remove -y debootstrap
			wget http://ports.ubuntu.com/pool/main/d/debootstrap/debootstrap_1.0.95ubuntu0.10_all.deb
			sudo dpkg -i debootstrap_1.0.95ubuntu0.10_all.deb
			rm debootstrap_1.0.95ubuntu0.10_all.deb
		else
			echo "debootstrap-1.0.95ubuntu0.10 is ready"
		fi
	fi

	for pkg in $host_packages_list; do
		if ! dpkg-query -l $pkg | grep ii 1>/dev/null; then
			echo Installing $pkg
			sudo apt -y install $pkg
		fi
	done

}

main $@
