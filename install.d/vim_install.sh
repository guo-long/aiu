#!/bin/bash
echo "#################### VIM BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`; pwd))
fi

. $AIU/install.d/functions.sh
init_pkg vim

echo "#################### Check If VIM Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed vim

echo "#################### Handle VIM Requirements ####################"
apt-get -y install libncurses5-dev

echo "#################### Install VIM ####################"
echo "## Entering directory '$SRC'"
cd $SRC
pre_install vim
VIM_SOURCE=$EXT_DIR
VIM_SRC=$SRC/$VIM_SOURCE
get_value vim;VIM=$VALUE
VIM_DEST=$DEST/$VIM
cd $VIM_SRC
./configure --prefix=$VIM_DEST \
--with-features=huge \
--enable-cscope \
--enable-fontset \
--enable-multibyte \
--enable-pythoninterp \
--enable-perlinterp
is_ok
make
is_ok
echo $(date) > $AIU/install.d/log/vim_make_install.log
make install &>>$AIU/install.d/log/vim_make_install.log
is_ok
make clean
set_value vim_dest $VIM_DEST
is_ok
echo "## INFO: 'vim' is installed to '$VIM_DEST'"
cd $AIU
echo "#################### VIM END ####################"
