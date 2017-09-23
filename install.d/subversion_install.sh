#!/bin/bash

echo "#################### Subversion BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`;pwd))
fi

. $AIU/install.d/functions.sh
init_pkg subversion

echo "#################### Check If Subversion Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed subversion

echo "#################### Handle Subversion Requirements ####################"
get_value apr_dest;APR_DEST=$VALUE
is_dir_exist $APR_DEST
get_value apr-util_dest;APR_UTIL_DEST=$VALUE
is_dir_exist $APR_UTIL_DEST
get_value httpd_dest;HTTPD_DEST=$VALUE
is_dir_exist $HTTPD_DEST

echo "#################### Install Subversion ####################"
echo "## Entering directory '$SRC'"
cd $SRC
pre_install subversion
SUBVERSION_SOURCE=$EXT_DIR
SUBVERSION_SRC=$SRC/$SUBVERSION_SOURCE
get_value subversion;SUBVERSION=$VALUE
SUBVERSION_DEST=$DEST/$SUBVERSION
pre_install sqlite-amalgamation
SQLITE_AMALGAMATION_SOURCE=$EXT_DIR
mv $SQLITE_AMALGAMATION_SOURCE sqlite-amalgamation
SQLITE_AMALGAMATION_SOURCE=sqlite-amalgamation
mv $SQLITE_AMALGAMATION_SOURCE $SUBVERSION_SOURCE
echo "## Entering directory '$SUBVERSION_SRC'"
cd $SUBVERSION_SRC
./configure --prefix=$SUBVERSION_DEST \
--with-apr=$APR_DEST \
--with-apr-util=$APR_UTIL_DEST \
--with-apxs=$HTTPD_DEST/bin/apxs \
--enable-maintainer-mode
is_ok
make
is_ok
echo $(date) > $AIU/install.d/log/subversion_make_install.log
make install &>>$AIU/install.d/log/subversion_make_install.log
is_ok
make clean
set_value subversion_dest $SUBVERSION_DEST
is_ok
echo "## INFO: 'subversion' is installed to '$SUBVERSION_DEST'"
cd $AIU
echo "#################### Subversion END ####################"
