#!/bin/bash
#
# Copyright 2018 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause
#
# reconfigure default setting of some application packages

# for sshd
if [ -f /etc/ssh/sshd_config ]; then
    sed -i "s/PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
fi

# for tftp service
if dpkg-query -W tftp-hpa 1>/dev/null 2>&1 ; then
    chmod 777 /var/lib/tftpboot
    cat > /etc/init.d/tftp <<EOF
    service tftp
    {
       disable = no
       socket_type = dgram
       protocol = udp
       wait = yes
       user = root
       server = /usr/sbin/in.tftpd
       server_args = -s /var/lib/tftpboot -c
       per_source = 11
       cps = 100 2
    }
EOF
    sed -i '/TFTP_OPTIONS/d' /etc/default/tftpd-hpa
    sed -i '/TFTP_ADDRESS/aTFTP_OPTIONS=" -l -c -s"' /etc/default/tftpd-hpa
fi


# fixup for netplan 0.36 as kernel fsl_dpa driver does not support rebinding, no need after netplan 0.38
netplan_fixup=n
if [ $netplan_fixup = y ] && [ -f /usr/share/netplan/netplan/cli/commands/apply.py ]; then
    tgtfile=/usr/share/netplan/netplan/cli/commands/apply.py
    if ! grep fsl_dpa $tgtfile; then
	sed -i "132 a\            if driver_name == 'fsl_dpa':" $tgtfile
	sed -i "133 a\                 logging.debug('replug %s: fsl_dpa does not support rebinding, ignoring', device)" $tgtfile
	sed -i "134 a\                 return False" $tgtfile
    fi
fi
