***************************
NXP LS1021ATWR board
***************************
This file documents the Buildroot support for the NXP LS1021ATWR board.

Build
=====
First, configure Buildroot for LS1021ATWR board:

# build the SD boot image with QSPI enabled
  make nxp_ls1021atwr_defconfig
# or, build the SD boot image with IFC Nor flash enabled
  make nxp_ls1021atwr_sdboot_ifc_defconfig

Build all components:

  make

You will find in output/images/ the following files:
  - boot.vfat
  - ls1021a-twr.dtb
  - rootfs.ext2
  - rootfs.tar
  - sdcard.img
  - u-boot-with-spl-pbl.bin
  - uImage
  - uboot-env.bin

Create a bootable SD card
=========================
To determine the device associated to the SD card have a look in the
/proc/partitions file:

  cat /proc/partitions

Buildroot prepares a bootable "sdcard.img" image in the output/images/
directory, ready to be dumped on a SD card. Launch the following
command as root:

  dd if=./output/images/sdcard.img of=/dev/<your-sd-device>

*** WARNING! This will destroy all the card content. Use with care! ***

For details about the medium image layout, see the definition in
board/nxp/common/genimage.cfg.template.

Switch setting
==============
To boot ls1021atwr board from SD card, follow below switch setting:
SW2[1:8]=0010_1000; SW3[1:8]=0110_0001 # boot from SD card with IFC enabled
SW2[1:8]=0010_0000; SW3[1:8]=0110_0001 # boot from SD card with QSPI enabled


Boot the LS1021ATWR board
=========================
To boot your newly created system:
- insert the SD card in the SD slot of the board;
- put a micro USB cable into the Debug USB Port and connect using a terminal
  emulator at 115200 bps, 8n1;
- power on the board.

Memory map
==========
The addresses in brackets are physical addresses.

Start Address   End Address     Description                     Size
0x00_0000_0000  0x00_000F_FFFF  Secure Boot ROM                 1MB
0x00_0100_0000  0x00_0FFF_FFFF  CCSRBAR                         240MB
0x00_1000_0000  0x00_1000_FFFF  OCRAM0                          64KB
0x00_1001_0000  0x00_1001_FFFF  OCRAM1                          64KB
0x00_2000_0000  0x00_20FF_FFFF  DCSR                            16MB
0x00_4000_0000  0x00_5FFF_FFFF  QSPI                            512MB
0x00_6000_0000  0x00_67FF_FFFF  IFC - NOR Flash                 128MB
0x00_8000_0000  0x00_FFFF_FFFF  DRAM1                           2GB

Enjoy!
