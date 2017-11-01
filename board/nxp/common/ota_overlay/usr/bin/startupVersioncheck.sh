#!/bin/sh

FILEPATH=/tmp
VERSIONFILE=version.json

parse_json(){
	sed 's/\"//g' $1 | grep $2: | sed 's/.*'$2':\([^,}]*\).*/\1/'
}
write_json(){
	sed -i "/$2\":/ s/\(.*:\).*/\1$3/" $1
}

dd if=/dev/mmcblk0 of=$FILEPATH/updateInfo.img bs=1K skip=2040 count=1
updateStatus=`cat $FILEPATH/updateInfo.img`

if [ "${updateStatus:0:2}"x == "33"x ];then
	mount /dev/mmcblk0p1 /mnt
	boardName=$(parse_json /mnt/$VERSIONFILE "boardname")
	if [ "$boardName" != "ls1021aiot" ];then
	     imageName=$(basename /mnt/*.itb)
		 mv /mnt/${imageName}_old /mnt/$imageName
	else
		mv /mnt/uImage_old /mnt/uImage
	fi
	umount /dev/mmcblk0p1
elif [ "${updateStatus:0:2}"x == "34"x ];then
	/usr/bin/rollback.sh
	exit
elif [ "${updateStatus:0:1}"x != "2"x ];then
	exit
fi

dd if=/dev/zero of=/dev/mmcblk0 bs=1K seek=2040 count=1
rm -f $FILEPATH/updateInfo.img

if [ "${updateStatus:0:2}"x == "33"x ];then
	exit
fi

mount /dev/mmcblk0p1 /mnt
updatePart=$(parse_json /mnt/backup/$VERSIONFILE "updatePart")
updateVersion=$(parse_json /mnt/backup/$VERSIONFILE "updateVersion")
write_json /mnt/backup/$VERSIONFILE $updatePart "\"$updateVersion\""
umount /dev/mmcblk0p1
