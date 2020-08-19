#!/bin/bash
set -u
SUDO_FILE=/etc/sudoers.d/openil_conf

permission_grant()
{
	permission_check
	if [ "x$?" = "x0" -a ${#USER[@]} -eq 0 ]
	then
		return 0
	fi

	if [ "x$?" = "x1" -a  -f ${SUDO_FILE} ]
	then
		${SUDO} rm ${SUDO_FILE}
	fi

	if [ "${confirmed}" = "true" ]
	then
		read -p "Do you want to grant:[Y/N] " -n1 ans;
		if [ "${ans}" = "N" -o "${ans}" = "n" ]
		then
			exit 0;
		fi
	fi

	echo "OpenIL User(${USER[@]}) is applying the sudo permission."

	file=$(tempfile)
	if [ "x$?" != "x0" ]
	then
			echo "Failed to creat a tempfile.";
			return 1
	fi

	if [ -f ${SUDO_FILE} ]
	then
		${SUDO} mv ${SUDO_FILE}  ${file}
		for u in "${USER[@]}"
		do
			${SUDO} ${SED} -i -e "/User_Alias/ s/$/,${u}/" ${file}
		done
	else
		echo "Host_Alias HOST = ${HOST}" >> ${file}
		echo "User_Alias USER = "${USER[0]} >> ${file}
		USER_RES=(${USER[@]})
		unset USER_RES[0]
		for u in "${USER_RES[@]}"
		do
			${SED} -i -e "/User_Alias/ s/$/,${u}/" ${file}
		done
		echo "Cmnd_Alias MOUNT    = ${MOUNT},${UMOUNT}" >> ${file}
		echo "Cmnd_Alias CHOWN = ${CHOWN}" >> ${file}
		echo "Cmnd_Alias CHROOT = ${CHROOT}" >> ${file}
		echo "Cmnd_Alias CHMOD = ${CHMOD}" >> ${file}
		echo "Cmnd_Alias DEBOOTSTRAP = ${DEBOOTSTRAP}" >> ${file}
		echo "USER HOST=(root) NOPASSWD:MOUNT,CHMOD,CHROOT,CHOWN,DEBOOTSTRAP" >> ${file}
	fi
	${SUDO} ${CHOWN} root:root ${file}
	${SUDO} ${CHMOD} +r ${file}
	${SUDO} mv ${file} ${SUDO_FILE}
	echo "OpenIL User(${USER[@]}) is granted"
	return 0
}

permission_check()
{
	if [ -f ${SUDO_FILE} ]
	then
		grep "Host_Alias" -rn ${SUDO_FILE} | grep ${HOST} > /dev/null || return 1
		grep "Cmnd_Alias MOUNT" -rn  ${SUDO_FILE}  | grep ${MOUNT} > /dev/null || return 1
		grep "Cmnd_Alias MOUNT" -rn  ${SUDO_FILE}  | grep ${UMOUNT} > /dev/null || return 1
		grep "Cmnd_Alias CHROOT" -rn ${SUDO_FILE}  | grep ${CHROOT} > /dev/null || return 1
		grep "Cmnd_Alias CHOWN" -rn  ${SUDO_FILE}  | grep ${CHOWN} > /dev/null || return 1
		grep "Cmnd_Alias CHMOD" -rn  ${SUDO_FILE}  | grep ${CHMOD} > /dev/null || return 1
		grep "Cmnd_Alias DEBOOTSTRAP" -rn  ${SUDO_FILE}  | grep ${DEBOOTSTRAP} > /dev/null || return 1
		grep "USER HOST=(root) NOPASSWD:MOUNT,CHMOD,CHROOT,CHOWN,DEBOOTSTRAP"  -rn  ${SUDO_FILE} > /dev/null || return 1
		USER_ALIAS=$(grep "User_Alias" -rn ${SUDO_FILE}) || return 1
		USER_ALIAS=$(echo $USER_ALIAS | sed -e "s/.*=//" -e "s/,/ /" -e "s/$/ /" -e "s/^/ /")
		USER_UN=()
		for u in "${USER[@]}"
		do
			echo ${USER_ALIAS} | grep -w ${u}  > /dev/null 2>&1
			if [ "x$?" != "x0" ]; then USER_UN+=" ${u} ";  continue; fi
			echo "OpenIL User(${u}) has been granted"
		done
		unset USER
		USER=(${USER_UN[@]})
		return 0
	fi
	return 1;
}

permission_withdraw()
{
	file=$(tempfile)
	if [ "x$?" != "x0" ]
	then
			echo "Failed to creat a tempfile.";
			return 1
	fi

	if [ -f ${SUDO_FILE} ]
	then
		${SUDO} mv ${SUDO_FILE}  ${file}
		for u in "${USER[@]}"
		do
			${SUDO} ${SED} -i -e "/User_Alias/  s/,${u},/,/" \
				-e "/User_Alias/ s/ ${u},//" \
				-e "/User_Alias/ s/ ${u}$//" \
				-e "/User_Alias/ s/,${u}$//" ${file}
			echo "OpenIL User ${u} has been withdrawn"
		done
		USER_ALIAS=($(grep "User_Alias" -rn ${file} | ${SED} -e "s/.*=//"))
	        if [[ ${#USER_ALIAS[@]} -eq 0 ]]
		then
			${SUDO} rm ${file}
		else
			${SUDO} ${CHOWN} root:root ${file}
			${SUDO} ${CHMOD} +r ${file}
			${SUDO} mv ${file} ${SUDO_FILE}
		fi
	fi
	return 0
}

permission_list()
{
	USER_HAS=()
	if [ -f ${SUDO_FILE} ]
	then
		USER_HAS=($(grep "User_Alias" -rn ${SUDO_FILE} | ${SED} -e "s/.*=//" -e "s/,/ /g"))
	fi
	echo "The OpenIL users:"
	echo -e "\t ${USER_HAS[@]}"
}

usage()
{
	echo -e "Usage: grant_openil_perm.sh [Options] [Users]"
	echo -e "\t The default User is current user if \"Users\" is not specified."
	echo -e "Options:"
	echo -e "\t -g\t apply the permission for the users"
	echo -e "\t -i\t need to be confirmed when applying the permission"
	echo -e "\t -c\t check whether the users have the permission"
	echo -e "\t -w\t withdraw the permission for the users"
	echo -e "\t -l\t list the all users who has the permission"
	echo -e "Example:"
	echo -e "\t grant_openil_perm.sh"
	echo -e "\t   Check whether the current user has the permission"
	echo -e ""
	echo -e "\t grant_openil_perm.sh -g"
	echo -e "\t   Apply the permission for the current user"
	echo -e ""
	echo -e "\t grant_openil_perm.sh -g user0 user1"
	echo -e "\t   Apply the permission for the user0 and user1"
	echo -e ""
	echo -e "\t grant_openil_perm.sh -w user0 user1"
	echo -e "\t   Withdraw the permission for the user0 and user1"
	echo -e ""
	echo -e "\t grant_openil_perm.sh -c  user0 user1"
	echo -e "\t   Check whether the user0 and user1  has the permission"
	echo -e ""
}

HOST=ALL
SUDO=`which sudo`
MOUNT=`which mount`
UMOUNT=`which umount`
CHROOT=`which chroot`
CHOWN=`which chown`
CHMOD=`which chmod`
SED=`which sed`
DEBOOTSTRAP=`which debootstrap`
if [ "x${DEBOOTSTRAP}" = "x" ]
then
	echo "debootstrap not found. Try running \"utils/ubuntu_env_check.sh\""
	exit 1
fi
CMD=""
USER=()

confirmed=false

if [[ $# -eq 0 ]]
then
	CMD="check"
	USER=($(whoami))
fi

while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
		-g)
			[ "${CMD}x" != "x" ] && CMD="usage" && break;
			CMD="grant"
			shift
			;;
		-w)
			[ "${CMD}x" != "x" ] && CMD="usage" && break;
			CMD="withdraw"
			shift
			;;
		-c)
			[ "${CMD}x" != "x" ] && CMD="usage" && break;
			CMD="check"
			shift
			;;
		-l)
			[ "${CMD}x" != "x" ] && CMD="usage" && break;
			CMD="list"
			shift
			;;
		-h)
			CMD="usage"; break;
			shift
			;;
		-i)
			confirmed=true;
			shift
			;;
		*)
			[ "${CMD}x" = "x" ] && CMD="usage" && break;
			USER+=($key)
			shift
			;;
	esac
done


if [[ ${#USER[@]} -eq 0 ]]
then
	USER=($(whoami))
fi

case $CMD in
	"grant")
		permission_grant
		;;
	"withdraw")
		permission_withdraw
		;;
	"check")
		permission_check
		if [[ ${#USER[@]} -ne 0 ]]
		then
			echo "OpenIL User ${USER[@]} is not granted"
		fi
		;;
	"list")
		permission_list
		;;
	"usage" | *)
		usage
		;;
esac
exit 0
