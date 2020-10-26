#!/usr/bin/env bash

distro=focal

trap recover_from_ctrl_c INT

recover_from_ctrl_c()
{
	do_recover_from_error "Interrupt caught ... exiting"
	exit 1
}

do_recover_from_error()
{
	sudo chroot $RFSDIR /bin/umount /proc > /dev/null 2>&1;
	sudo chroot $RFSDIR /bin/umount /sys > /dev/null 2>&1;
	USER=$(id -u); GROUPS=${GROUPS}; \
	sudo chroot $RFSDIR  /bin/chown -R ${USER}:${GROUPS} / > /dev/null 2>&1;
	echo -e "\n************"
    echo $1
	echo -e "  Please running the below commands before re-compiling:"
	echo -e "    rm -rf $RFSDIR"
	echo -e "    make skeleton-custom-dirclean"
	echo -e "  Or\n    make skeleton-custom-dirclean O=<output dir>"
}

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

    if [ $1 = arm64 ]; then
	tgtarch=aarch64
    elif [ $1 = armhf ]; then
	tgtarch=arm
    elif [ $1 = ppc64el ]; then
	tgtarch=ppc64le
    fi

    qemu-${tgtarch}-static -version > /dev/null 2>&1
    if [ "x$?" != "x0" ]; then
        echo qemu-${tgtarch}-static not found
        exit 1
    fi

    debootstrap --version > /dev/null 2>&1
    if [ "x$?" != "x0" -a $DISTROSCALE != lite ]; then
        echo debootstrap not found
        exit 1
    fi

    [ $1 != amd64 -a ! -f $RFSDIR/usr/bin/qemu-${tgtarch}-static ] && cp $(which qemu-${tgtarch}-static) $RFSDIR/usr/bin
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
	if [ "x$?" != "x0" ]; then
		do_recover_from_error "debootstrap failed in first-stage"
		exit 1
	fi

	echo "installing for second-stage ..."
	DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C \
	sudo chroot $RFSDIR /debootstrap/debootstrap  --second-stage
	if [ "x$?" != "x0" ]; then
		do_recover_from_error "debootstrap failed in second-stage"
		exit 1
	fi

	echo "configure ... "
	DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C \
	sudo chroot $RFSDIR dpkg --configure -a
    fi

    sudo chroot $RFSDIR ubuntu-package-installer $1 $distro $5 $3 $6
	if [ "x$?" != "x0" ]; then
		 do_recover_from_error "ubuntu-package-installer failed"
		exit 1
	fi

    sudo chroot $RFSDIR systemctl enable systemd-rootfs-resize
    sudo chown -R $USER:$GROUPS $RFSDIR
    if dpkg-query -l snapd | grep ii 1>/dev/null; then
	chmod +rw -R $RFSDIR/var/lib/snapd/
    fi

    if [ $distro = focal ]; then
	echo OpenIL-Ubuntu,20.04.1 | tee $RFSDIR/etc/.firststagedone 1>/dev/null
    elif [ $distro = bionic ]; then
	echo OpenIL-Ubuntu,18.04.5 | tee $RFSDIR/etc/.firststagedone 1>/dev/null
    fi
    setup_distribution_info $5 $2 $1

    rm $RFSDIR/etc/apt/apt.conf
    rm $RFSDIR/dev/* -rf
}

setup_distribution_info () {
    DISTROTYPE=$1
    RFSDIR=$2
    tarch=$3
    distroname=`head -1 $RFSDIR/etc/.firststagedone | cut -d, -f1`
    distroversion=`head -1 $RFSDIR/etc/.firststagedone | cut -d, -f2`
    releaseversion="$distroname (based on $DISTROTYPE-$distroversion-base) ${tarch}"
    releasestamp="Build: `date +'%Y-%m-%d %H:%M:%S'`"
    echo $releaseversion > $RFSDIR/etc/buildinfo
    sed -i "1 a\\$releasestamp" $RFSDIR/etc/buildinfo
    if grep U-Boot $RFSDIR/etc/.firststagedone 1>$RFSDIR/dev/null 2>&1; then
        tail -1 $RFSDIR/etc/.firststagedone >> $RFSDIR/etc/buildinfo
    fi

    if [ $DISTROTYPE = ubuntu ]; then
        echo $distroname $1-$distroversion > $RFSDIR/etc/issue
        echo $distroname $1-$distroversion > $RFSDIR/etc/issue.net

        tgtfile=$RFSDIR/etc/lsb-release
        echo DISTRIB_ID=NXP-OpenIL > $tgtfile
        echo DISTRIB_RELEASE=$distroversion >> $tgtfile
        echo DISTRIB_CODENAME=$distro >> $tgtfile
        echo DISTRIB_DESCRIPTION=\"$distroname $1-$distroversion\" >> $tgtfile

        tgtfile=$RFSDIR/etc/update-motd.d/00-header
        echo '#!/bin/sh' > $tgtfile
        echo '[ -r /etc/lsb-release ] && . /etc/lsb-release' >> $tgtfile
        echo 'printf "Welcome to %s (%s %s %s)\n" "$DISTRIB_DESCRIPTION" "$(uname -o)" "$(uname -r)" "$(uname -m)"' >> $tgtfile

        tgtfile=$RFSDIR/etc/update-motd.d/10-help-text
        echo '#!/bin/sh' > $tgtfile
        echo 'printf "\n"' >> $tgtfile
        echo 'printf " * Support:        https://www.openil.org\n"' >> $tgtfile
        echo 'printf " * Develop:        https://www.openil.org/develop.html\n"' >> $tgtfile

        tgtfile=$RFSDIR/usr/lib/os-release
        echo NAME=\"$distroname\" > $tgtfile
        echo VERSION=${DISTROTYPE}-$distroversion >> $tgtfile
        echo ID=OpenIL Ubuntu >> $tgtfile
        echo VERSION_ID=$distroversion >> $tgtfile
	echo PRETTY_NAME=\"OpenIL Ubuntu Built with Buildroot, based on Ubuntu $distroversion LTS\" >> $tgtfile
	echo VERSION_CODENAME=$distro >> $tgtfile

        rm -f $RFSDIR/etc/default/motd-news
        rm -f $RFSDIR/etc/update-motd.d/50-motd-news
    fi
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

	if [ $distro = focal ]; then
		sed -i "s/float(n\[0\])/float(n[0].split()[0])/" ${1}/usr/share/pyshared/lsb_release.py
	fi

	# rebuild iproute2 and use the tc command modified for target system
	if grep -Eq "^BR2_PACKAGE_IPROUTE2=y$" ${BR2_CONFIG}; then
		make iproute2-rebuild
	fi

	exit $?
}

main $@
