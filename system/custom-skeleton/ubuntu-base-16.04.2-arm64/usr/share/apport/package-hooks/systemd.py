'''apport package hook for systemd

(c) 2014 Canonical Ltd.
Author: Martin Pitt <martin.pitt@ubuntu.com>
'''

import os.path
import apport.hookutils

def add_info(report):
    apport.hookutils.attach_hardware(report)

    report['SystemdDelta'] = apport.hookutils.command_output(['systemd-delta'])

    if not os.path.exists('/run/systemd/system'):
        return

    # Add details about all failed units, if any
    out = apport.hookutils.command_output(['systemctl', '--failed', '--full',
                                           '--no-legend']).strip()
    if out:
        failed = ''
        for line in out.splitlines():
            unit = line.split()[0]
            if failed:
                failed += '------\n'
            failed += apport.hookutils.command_output(['systemctl', 'status', '--full', unit])
        report['SystemdFailedUnits'] = failed

