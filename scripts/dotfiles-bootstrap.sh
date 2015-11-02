#!/bin/bash

pushd `dirname $0` > /dev/null
BASEDIR=`pwd`
BASEDIR=`dirname $BASEDIR`
popd > /dev/null

cd

function fatal {
	printf "\033[1;31mFATAL\033[0m %s\n" "$@"
}
function warn {
	printf "\033[1;33mWARN\033[0m %s\n" "$@"
}
function notice {
	printf "\033[1;32mNOTICE\033[0m %s\n" "$@"
}

function mklink {
	if [ ! -e $2 ]; then
		ln -s $1 $2
		notice "symbolic link created $2 --> $1"
	else
		warn "$2 already exists."
	fi
}
function dorsync {
	notice "rsync $1 --> $2"
	rsync -rav $1 $2
}
function addline {
	FILE="$1"
	ENTRY="$2"
	if [ -e "$FILE" ]; then
		if grep "$ENTRY" "$FILE" > /dev/null; then
			warn "$FILE already patched."
			return 1
		fi
	fi
	echo "$ENTRY" >> "$FILE"
	notice "patched $FILE"
}
function gitclone {
	DIR="$2"
	REPO="$1"
	if [ -e "$DIR" ]; then
		warn "$DIR already exists."
	else
		pushd `dirname $DIR`
		git clone "$REPO" `basename $DIR`
		popd
		notice "git clone done at $DIR"
	fi
}
function putdefault {
	FROM="$1"
	TO="$2"
	if [ ! -e $TO ]; then
		cp $FROM $TO
		notice "copied $FROM --> $TO"
	else
		warn "$TO already exists."
	fi
}

if [ ! "$BASEDIR" == "$HOME/.dotfiles" ]; then
	fatal "dotfiles must be at ~/.dotfiles"
	exit 1
else
	BASEDIR="~/.dotfiles"
fi

which vim >/dev/null || {
	fatal "You're missing something."
	exit 1 
}

mkdir -p .vim/bundle
gitclone https://github.com/VundleVim/Vundle.vim .vim/bundle/Vundle.vim

addline .vimrc "source $BASEDIR/vim/vimrc"

addline .profile ". $BASEDIR/profile/profile.sh"
putdefault "$BASEDIR/profile/default_bash_profile.sh" .bash_profile

addline .bashrc ". $BASEDIR/bash/bashrc.sh"

notice "please make sure .tmux.conf updated properly."

notice "Testing shell scripts..."
export CHECK_SYSTEM=YES
. ~/.bash_profile
notice "Done!"
