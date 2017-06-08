#!/usr/bin/env bash

#
# Change the toolchain from aarch64 to armv7 to build 32b kernel and fs
#
# ${2} - uboot building directory
# ${3} - top directory

echo ${2}
echo ${3}

rm -rf board/nxp/ls1046ardb/temp
mkdir board/nxp/ls1046ardb/temp

cp output/images/* board/nxp/ls1046ardb/temp/
cp ${2}/tools/mkimage board/nxp/ls1046ardb/temp/

# Copy the uboot mkimage to output/host/usr/bin for the PPA building
cp ${2}/tools/mkimage output/host/usr/bin
make ppa-build
cp ${BUILD_DIR}/ppa-fsl-sdk-v2.0-1703/ppa/soc-ls1046/build/obj/ppa.itb board/nxp/ls1046ardb/temp/

make clean
rm .config

cp board/nxp/ls1046ardb/ls1046ardb-32b_linux_fs_defconfig configs/ls1046ardb-32b_linux_fs_defconfig

make ls1046ardb-32b_linux_fs_defconfig

rm -f configs/ls1046ardb-32b_linux_fs_defconfig

make
