LS1028ARDB board is one platform based on LS1028A silicon for industry,
which is supported in LSDK-19.09.

One simple image file is created by buildroot, which includes RCW, uboot,
Linux kernel, rootfs and other necessary binaries for this board.

To program the image file created by buildroot into the flash.
There are two way to do it:

1. Program the image file on PC machine for SD card boot
  $ sudo dd if=./output/images/sdcard.img of=/dev/sdx
  # or in some other host machine:
  $ sudo dd if=./output/images/sdcard.img of=/dev/mmcblkx

  # find the right SD Card device name in your host machine and replace the
  # “sdx” or “mmcblkx”.

2. Program the image file on board for eMMC and XSPI boot
Make sure your board has ipaddr, netmask, and serverip defined to reach your
tftp server.

  2.1 Program eMMC boot image file to eMMC chip
    # Make sure output/images/sdcard.img is stored to tftp server
    # Below command is one example
    => tftpboot 0xa0000000 sdcard.img
    => mmc dev 1
    => mmc erase 0 0x200000
    => mmc write 0xa0000000 0 0x200000

    # The size "0x200000" will be changed when the image size is different.

  2.2 Program XSPI boot image file to flash
    # Make sure output/images/xspi.cpio.img is stored to tftp server
    # Below command is one example
    => tftpboot 0xa0000000 xspi.cpio.img
    => sf probe
    => sf erase 0 $filesize
    => sf write 0xa0000000 0 $filesize

3. Booting your new system
Before booting the new system, we should make sure the switch setting is right.
below switch setting is for each booting mode:
    +-----------+---------------------+
    |Boot mode  | Switch setting      |
    +---------------------------------+
    |SD boot    | SW2[1~4] = 0b’1000  |
    +---------------------------------+
    |eMMC boot  | SW2[1~4] = 0b’1001  |
    +---------------------------------+
    |XSPI boot  | SW2[1~4] = 0b’1111  |
    +-----------+---------------------+

or we use following command to reset the board in uboot prompt:
  # boot from SD card
  => qixis_reset sd

  # boot from eMMC chip
  => qixis_reset emmc

  # boot from XSPI
  => qixis_reset qspi
