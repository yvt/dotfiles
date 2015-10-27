#!/bin/sh

pushd `dirname $0` > /dev/null
BASEDIR=`pwd`/..
popd > /dev/null

cd

if [ ! -e .vim ]; then
	ln -s $BASEDIR/vim/vim .vim
else
	echo ".vim already exists."
fi
if [ ! -e .vimrc ]; then
	ln -s $BASEDIR/vim/vimrc .vimrc
else
	echo ".vimrc already exists."
fi

