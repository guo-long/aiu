#!/bin/bash

echo "#################### APR BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`; pwd))
fi

. $AIU/install.d/functions.sh
init_pkg apr

echo "#################### Check If APR Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed apr

echo "#################### Install APR ####################"
echo "## Entering directory '$SRC'"
cd $SRC
pre_install apr
APR_SOURCE=$EXT_DIR
APR_SRC=$SRC/$APR_SOURCE
get_value apr;APR=$VALUE
APR_DEST=$DEST/$APR
echo "## Entering directory '$APR_SRC'"
cd $APR_SRC
./configure --prefix=$APR_DEST
is_ok
make
is_ok
echo $(date) > $AIU/install.d/log/apr_make_install.log
make install &>>$AIU/install.d/log/apr_make_install.log
is_ok
make clean
set_value apr_dest $APR_DEST
is_ok
echo "## INFO: 'apr' is installed to '$APR_DEST'"
cd $AIU
echo "#################### APR END ####################"
