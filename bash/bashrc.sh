
# system check
if [ "$CHECK_SYSTEM" == "YES" ]; then
	system_check_fail () {
		printf "\033[1;31mSYSCHECK\033[0m %s\n" "$@"
	}
else
	system_check_fail () {
		:
	}
fi

# set locale
export LC_ALL=en_US.UTF-8

# fix TERM variable
if [ "$TERM" == "screen" ]; then
	if [ -f /usr/share/terminfo/s/screen-256color -o -f /lib/terminfo/s/screen-256color ]; then
		export TERM=screen-256color
	fi
fi

# enable colored terminal

case "$TERM" in
	xterm-256color) colorPrompt=yes;;
	xterm-color) colorPrompt=yes;;
	xterm) colorPrompt=yes;;
	vt100) colorPrompt=yes;;
	screen) colorPrompt=yes;;
esac

if [ "$colorPrompt" == "yes" ]; then
	export PS1="\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \u$ "
	alias ls="ls -G"
	alias grep="grep --color=auto"
	export MINICOM="-c on"
fi

# setup powerline
{
	which powerline-daemon > /dev/null && {
		powerline-daemon -q
		POWERLINE_BASH_CONTINUATION=1
		POWERLINE_BASH_SELECT=1

		POWERLINEPATH="/usr/local/lib/python3.4/dist-packages/powerline/bindings/bash/powerline.sh"
		POWERLINEPATH+=" /Library/Frameworks/Python.framework/Versions/3.4/lib/python3.4/site-packages/powerline/bindings/bash/powerline.sh"
		POWERLINEPATH+=" /Library/Python/2.7/site-packages/powerline/bindings/bash/powerline.sh"
		POWERLINEPATH+=" /usr/lib/python3.4/site-packages/powerline/bindings/bash/powerline.sh"
		POWERLINEPATH+=" /usr/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh"
		POWERLINEPATH+=" /opt/local/Library/Frameworks/Python.framework/Versions/3.4/lib/python3.4/site-packages/powerline/bindings/bash/powerline.sh"
		POWERLINEPATH+=" /opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh"
		POWERLINEFOUND=NO

		for a in $POWERLINEPATH; do
			if [ -e $a ]; then
				. $a
				POWERLINEFOUND=YES
			fi
		done
		
		[ $POWERLINEFOUND == YES ]
	}
} || system_check_fail "powerline was not found."
unset POWERLINEPATH
unset POWERLINEFOUND

# RVM
if [ -e /etc/profile.d/rvm.sh ]; then
	. /etc/profile.d/rvm.sh
else
	system_check_fail "rvm not found."
fi

# Man's best friend
export EDITOR=vim



