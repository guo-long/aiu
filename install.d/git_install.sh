#!/bin/bash

echo "#################### Git BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`;pwd))
fi

. $AIU/install.d/functions.sh
init_pkg git

echo "#################### Check If Git Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed git

echo "#################### Handle Requirements ####################"
apt-get -y install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev asciidoc xmlto docbook2x

echo "#################### Install Git ####################"
echo "## Entering directory '$SRC'"
cd $SRC
pre_install git
GIT_SOURCE=$EXT_DIR
GIT_SRC=$SRC/$GIT_SOURCE
get_value git;GIT=$VALUE
GIT_DEST=$DEST/$GIT
echo "## Entering directory '$GIT_SRC'"
cd $GIT_SRC
make all doc info prefix=$GIT_DEST
is_ok
echo $(date) > $AIU/install.d/log/git_make_install.log
make install install-doc install-html install-info install-man prefix=$GIT_DEST &>>$AIU/install.d/log/git_make_install.log
is_ok
make clean
set_value git_dest $GIT_DEST
is_ok
echo "## INFO: 'git' is installed to '$GIT_DEST'"
cd $AIU
echo "#################### Git END ####################"
