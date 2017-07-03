#########################################################################
#      /etc/bash.bashrc: System-wide initialisation file for bash       #
#########################################################################

# This script file is executed by bash(1) for interactive shells.
#
# [JNZ] Modified 23-Sep-2004
#
# Written by John Zaitseff and released into the public domain.

umask 022

shopt -s checkwinsize expand_aliases
set -P

# Terminal type modifications

if [ "$TERM" = teraterm ]; then
    export TERM=linux
fi

# Set the complete path, as /etc/login.defs does not seem to be consulted

if [ $(id -u) -eq 0 ]; then
    export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/bin/X11
else
    export PATH=/usr/local/bin:/bin:/usr/bin:/usr/bin/X11:/usr/games
fi

if [ -d ${HOME}/bin ]; then
    export PATH=${HOME}/bin:${PATH}
fi
