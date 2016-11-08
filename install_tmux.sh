#!/bin/bash

# Script for installing tmux on systems where you don't have root access.
# The latest version of tmux will be installed in $HOME/local/bin.
# It is assumed that standard compilation tools (a C/C++ compiler with autoconf) are available. If git is installed it will be used instead of curl.

# Modified from https://gist.github.com/ryin/3106801 and https://gist.github.com/ryin/3106801 to use the latest version from github.

TARGET_DIR="$HOME/.local"
TMP_DIR="$HOME/tmp_tmux"
# Variable version #
TMUX_VERSION=2.2
# For some reason the 2.3 version didn't work..

# exit on error
set -e

get_from_github () {
  if type "git" &> /dev/null ; then
    git clone https://github.com/$1/$1
  else
    curl -L https://github.com/$1/$1/archive/master.tar.gz -o $1.tar.gz
    tar xvzf $1.tar.gz
  fi
}

# create our directories
mkdir -p $TMP_DIR
cd $TMP_DIR

# download source files for tmux, libevent, and ncurses
#get_from_github tmux
#get_from_github libevent
# GEt tmux
wget -O tmux-${TMUX_VERSION}.tar.gz https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
tar xvzf tmux-${TMUX_VERSION}.tar.gz
# Get libevent
wget https://github.com/downloads/libevent/libevent/libevent-2.0.19-stable.tar.gz
tar xvzf libevent-2.0.19-stable.tar.gz
# ncurse
curl -L ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz -o ncurses.tar.gz
tar xvzf ncurses.tar.gz

#########################
# configure and compile #
#########################

# libevent
cd $TMP_DIR/libevent*
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j2
make install

# ncurses
cd $TMP_DIR/ncurses-*
./configure --prefix=$TARGET_DIR --without-debug --without-shared
make -j2
make install

# tmux
cd $TMP_DIR/tmux-${TMUX_VERSION}
./autogen.sh
./configure --prefix=$TARGET_DIR CFLAGS="-I$TARGET_DIR/include -I$TARGET_DIR/include/ncurses" LDFLAGS="-L$TARGET_DIR/lib -L$TARGET_DIR/include/ncurses -L$TARGET_DIR/include" 
#CPPFLAGS="-I$TARGET_DIR/include -I$TARGET_DIR/include/ncurses" LDFLAGS="-static -L$TARGET_DIR/include -L$TARGET_DIR/include/ncurses -L$TARGET_DIR/lib"

# Move #
make -j2
cp tmux $TARGET_DIR/bin

# cleanup
cd
rm -rf $TMP_DIR

echo "$TARGET_DIR/bin/tmux is now available. You can optionally add $TARGET_DIR/bin to your PATH."
# e.g. to export path
# export PATH=$PATH:/path/to/dir1

