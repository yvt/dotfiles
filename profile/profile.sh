# supposed to be called by ~/.profile

DOTFILES=~/.dotfiles
export DOTFILES

PATH=$PATH:$DOTFILES/bin
PATH=$PATH:$DOTFILES/private/bin

if [ -e /opt/local/Library/Frameworks/Python.framework/Versions/3.4/bin ]; then
	PATH=$PATH:/opt/local/Library/Frameworks/Python.framework/Versions/3.4/bin
fi

export PATH
