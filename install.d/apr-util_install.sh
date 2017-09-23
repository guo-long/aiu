#!/bin/bash

echo "#################### APR-Util BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`; pwd))
fi

. $AIU/install.d/functions.sh
init_pkg apr-util

echo "#################### Check If APR-Util Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed apr-util

echo "#################### Handle Requirements ####################"
$AIU/install.d/apr_install.sh
get_value apr_dest;APR_DEST=$VALUE
is_dir_exist $APR_DEST

echo "#################### Install APR-Util ####################"
echo "## Entering directory '$SRC'"
cd $SRC
pre_install apr-util
APR_UTIL_SOURCE=$EXT_DIR
APR_UTIL_SRC=$SRC/$APR_UTIL_SOURCE
get_value apr-util;APR_UTIL=$VALUE
APR_UTIL_DEST=$DEST/$APR_UTIL
echo "## Entering directory '$APR_UTIL_SRC'"
cd $APR_UTIL_SRC
./configure --prefix=$APR_UTIL_DEST \
--with-apr=$APR_DEST
is_ok
make
is_ok
echo $(date) > $AIU/install.d/log/apr-util_make_install.log
make install &>>$AIU/install.d/log/apr-util_make_install.log
is_ok
make clean
set_value apr-util_dest $APR_UTIL_DEST
is_ok
echo "## INFO: 'apr-util' is installed to '$APR_UTIL_DEST'"
cd $AIU
echo "#################### APR-Util END ####################"
