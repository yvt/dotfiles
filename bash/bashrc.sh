
# system check
if [ "CHECK_SYSTEM" == "YES" ]; then
	system_check_fail () {
		echo "\033[1;31mSYSCHECK\033[0m $@"
	}
else
	system_check_fail () {
		:
	}
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

if which powerline-daemon >/dev/null ; then
	powerline-daemon -q
	POWERLINE_BASH_CONTINUATION=1
	POWERLINE_BASH_SELECT=1

	POWERLINEPATH="/usr/local/lib/python3.4/dist-packages/powerline/bindings/bash/powerline.sh"
	POWERLINEPATH+=" /Library/Python/2.7/site-packages/powerline/bindings/bash/powerline.sh"
        POWERLINEPATH+=" /usr/lib/python3.4/site-packages/powerline/bindings/bash/powerline.sh"

	for a in $POWERLINEPATH; do
		if [ -e $a ]; then
			. $a
		fi
	done
else
	system_check_fail "powerline was not found."
fi

# RVM
if [ -e /etc/profile.d/rvm.sh ]; then
	. /etc/profile.d/rvm.sh
else
	system_check_fail "rvm not found."
fi

# Man's best friend
export EDITOR=vim



