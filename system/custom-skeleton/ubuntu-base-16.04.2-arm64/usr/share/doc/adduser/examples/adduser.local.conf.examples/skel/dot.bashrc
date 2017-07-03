#########################################################################
#            .bashrc: Personal initialisation file for bash             #
#########################################################################

# This file is executed by interactive shells (ie, shells for which you
# are able to provide keyboard input).  It is the best place to put shell
# aliases, etc.
#
# [JNZ] Modified 23-Sep-2004
#
# Written by John Zaitseff and released into the public domain.


# Variable settings for your convenience

export LANG=en_AU.UTF-8				# We are in Australia
export LC_ALL=en_AU.UTF-8
export TIME_STYLE=$'+%b %e  %Y\n%b %e %H:%M'	# As used by ls(1)
export EDITOR=emacs				# Everyone's favourite editor
export CVSROOT=:ext:cvs.zap.org.au:/data/cvs
export CVS_RSH=ssh

# Useful aliases, defined whether or not this shell is interactive

alias cls=clear
alias ls="ls -v"
alias dir="ls -laF"
alias lock="clear; vlock -a; clear"
alias e="emacs -nw"


# Run the following only if this shell is interactive

if [ "$PS1" ]; then

    export IGNOREEOF=5			# Disallow accidental Ctrl-D

    # Set options, depending on terminal type
    if [ -z "$TERM" -o "$TERM" = "dumb" ]; then
        # Not a very smart terminal
        export PS1="[ \u@\h | \w ] "
    else
        # Assume a smart VT100-based terminal with colour

	# Make sure the terminal is in UTF-8 mode.  This is a hack!
	/bin/echo -n -e '\033%G'

	# Make ls(1) use colour in its listings
        if [ -x /usr/bin/dircolors ]; then
            alias ls="ls -v --color=auto"
            eval $(/usr/bin/dircolors --sh)
        fi

	# Set the terminal prompt
        if [ $(id -u) -ne 0 ]; then
            export PS1="\[\e[7m\][ \u@\h | \w ]\[\e[0m\] "
        else
            # Root user gets a nice RED prompt!
            export PS1="\[\e[41;30m\][ \u@\h | \w ]\[\e[0m\] "
        fi
    fi
fi
