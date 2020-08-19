#!/usr/bin/env bash

distro=focal

do_distrorfs_first_stage() {
# $1: platform architecture, arm64, armhf, ppc64el
# $2: rootfs directory, output/build/skeleton-custom
# $3: board/nxp/common/ls/ubuntu-additional_packages_list
# $4: bionic
# $5: ubuntu
# $6: Full or main for RootFS
    echo $1
    echo $2
    echo $3
    echo $4
    echo $5
    echo $6

    DISTROSCALE=$6
    DISTROTYPE=$5
    [ -z "$RFSDIR" ] && RFSDIR=$2
    [ -z $RFSDIR ] && echo No RootFS exist! && return
    [ -f $RFSDIR/etc/.firststagedone ] && echo $RFSDIR firststage exist! && return
    [ -f /etc/.firststagedone -a ! -f /proc/uptime ] && return
    mkdir -p $RFSDIR/lib/modules

    for pkg in binfmt-support qemu-system-common qemu-user-static debootstrap; do
	if ! dpkg-query -l $pkg | grep ii 1>/dev/null; then
	    echo installing $pkg
	    sudo apt-get -y install $pkg
        fi
    done

    if [ $1 = arm64 ]; then
	tgtarch=aarch64
    elif [ $1 = armhf ]; then
	tgtarch=arm
    elif [ $1 = ppc64el ]; then
	tgtarch=ppc64le
    fi

    [ ! -f /usr/sbin/update-binfmts ] && echo update-binfmts not found && exit 1

    if update-binfmts --display qemu-$tgtarch | grep -q disabled; then
	sudo update-binfmts --enable qemu-$tgtarch
	if update-binfmts --display qemu-$tgtarch | grep disabled; then
	    echo enable qemu-$tgtarch failed && exit 1
	else
	    echo enable qemu-$tgtarch successfully
	fi
    fi

    [ ! -f /usr/bin/qemu-${tgtarch}-static ] && echo qemu-${tgtarch}-static not found && exit 1
    [ ! -f /usr/sbin/debootstrap -a $DISTROSCALE != lite ] && echo debootstrap not found && exit 1
    [ $1 != amd64 -a ! -f $RFSDIR/usr/bin/qemu-${tgtarch}-static ] && cp /usr/bin/qemu-${tgtarch}-static $RFSDIR/usr/bin
    mkdir -p $2/usr/local/bin
    cp -f board/nxp/common/ls/ubuntu-package-installer $RFSDIR/usr/local/bin/

    packages_list=board/nxp/common/ls/$3
    [ ! -f $packages_list ] && echo $packages_list not found! && exit 1

    echo additional packages list: $packages_list
    if [ ! -d $RFSDIR/usr/aptpkg ]; then
	mkdir -p $RFSDIR/usr/aptpkg
	cp -f $packages_list $RFSDIR/usr/aptpkg
	if [ -f board/nxp/common/ls/reconfigpkg.sh ]; then
		cp -f board/nxp/common/ls/reconfigpkg.sh $RFSDIR/usr/aptpkg
	fi
    fi

    if [ -n "$http_proxy" ]; then
	mkdir -p $RFSDIR/etc/apt
	echo "Acquire::http::proxy \"$http_proxy\";" | tee -a $RFSDIR/etc/apt/apt.conf 1>/dev/null
    fi
    if [ -n "$https_proxy" ]; then
	echo "Acquire::https::proxy \"$https_proxy\";" | tee -a $RFSDIR/etc/apt/apt.conf 1>/dev/null
    fi

    cp -f /etc/resolv.conf $RFSDIR/etc/resolv.conf

    if [ ! -d $RFSDIR/debootstrap -a $DISTROSCALE != lite -a $DISTROTYPE = ubuntu ] || \
       [ ! -d $RFSDIR/debootstrap -a $DISTROTYPE = debian ]; then
	export LANG=en_US.UTF-8
	sudo debootstrap --arch=$1 --foreign $4 $RFSDIR
	echo "installing for second-stage ..."
	DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C \
	sudo chroot $RFSDIR /debootstrap/debootstrap  --second-stage
	echo "configure ... "
	DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C \
	sudo chroot $RFSDIR dpkg --configure -a
    fi
    echo OpenIL-Ubuntu,18.04.4 | sudo tee $RFSDIR/etc/.firststagedone 1>/dev/null

    sudo chroot $RFSDIR ubuntu-package-installer $1 $distro $5 $3 $6
    sudo chroot $RFSDIR systemctl enable systemd-rootfs-resize
    sudo chown -R $USER $RFSDIR
    sudo chgrp -R $USER $RFSDIR
    if dpkg-query -l snapd | grep ii 1>/dev/null; then
	chmod +rw -R $RFSDIR/var/lib/snapd/
    fi
    sudo rm $RFSDIR/etc/apt/apt.conf
    sudo rm $RFSDIR/dev/* -rf
}

plat_name()
{
	if grep -Eq "^BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM=\"ls1028ardb\"$" ${BR2_CONFIG}; then
		echo "LS1028ARDB"
	elif grep -Eq "^BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM=\"ls1028atsn\"$" ${BR2_CONFIG}; then
		echo "LS1028ATSN"
	elif grep -Eq "^BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM=\"lx2160ardb\"$" ${BR2_CONFIG}; then
		echo "LX2160ARDB"
	elif grep -Eq "^BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM=\"ls1046ardb\"$" ${BR2_CONFIG}; then
		echo "LS1046ARDB"
	elif grep -Eq "^BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM=\"ls1046afrwy\"$" ${BR2_CONFIG}; then
		echo "LS1046AFRWY"
	elif grep -Eq "^BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM=\"ls1043ardb\"$" ${BR2_CONFIG}; then
		echo "LS1043ARDB"
	elif grep -Eq "^BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM=\"imx8mp\"$" ${BR2_CONFIG}; then
		echo "IMX8MPEVK"
	elif grep -Eq "^BR2_LINUX_KERNEL_INTREE_DTS_NAME=\"ls1021a-iot\"$" ${BR2_CONFIG}; then
		echo "LS1021AIOT"
	elif grep -Eq "^BR2_LINUX_KERNEL_INTREE_DTS_NAME=\"ls1021a-tsn\"$" ${BR2_CONFIG}; then
		echo "LS1021ATSN"
	elif grep -Eq "^BR2_LINUX_KERNEL_INTREE_DTS_NAME=\"imx6q-sabresd\"$" ${BR2_CONFIG}; then
		echo "IMX6Q"
	fi
}

arch_type()
{
	if grep -Eq "^BR2_aarch64=y$" ${BR2_CONFIG}; then
		echo "arm64"
	elif grep -Eq "^BR2_arm=y$" ${BR2_CONFIG}; then
		echo "armhf"
	fi
}

full_rtf()
{
	if grep -Eq "^BR2_ROOTFS_SKELETON_CUSTOM_FULL_RFS=y$" ${BR2_CONFIG}; then
		echo "full"
	else
		echo "main"
	fi
}

main()
{
	# $1 - the current rootfs directory, skeleton-custom or target
	echo ${1}
	echo ${2}
	echo $(arch_type)
	echo $(plat_name)
	echo $(full_rtf)

	if [[ $(plat_name) = LS1021ATSN ]] || [[ $(plat_name) = LS1021AIOT ]] || [[ $(plat_name) = IMX6Q ]]; then
		distro=bionic
	fi

	# run first stage do_distrorfs_first_stage arm64 ${1} ubuntu-additional_packages_list bionic ubuntu
	do_distrorfs_first_stage $(arch_type) ${1} ubuntu-additional_packages_list bionic ubuntu $(full_rtf)

	# change the hostname to "platforms-Ubuntu"
	echo $(plat_name)-Ubuntu > ${1}/etc/hostname

	exit $?
}

main $@
