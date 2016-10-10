
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

if [ ! "$BASEDIR" == "$HOME/.dotfiles"  ] && [ ! "$BASEDIR" == "/usr$HOME/.dotfiles" ]; then
	fatal "dotfiles must be at ~/.dotfiles"
	exit 1
else
	BASEDIR="$HOME/.dotfiles"
fi

