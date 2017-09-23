#!/bin/bash

echo "#################### OpenSSL BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`; pwd))
fi

. $AIU/install.d/functions.sh
init_pkg openssl

echo "#################### Check If OpenSSL Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed openssl

echo "#################### Install OpenSSL ####################"
echo "## Entering directory '$SRC'"
cd $SRC
pre_install openssl
OPENSSL_SOURCE=$EXT_DIR
OPENSSL_SRC=$SRC/$OPENSSL_SOURCE
get_value openssl;OPENSSL=$VALUE
OPENSSL_DEST=$DEST/$OPENSSL
echo "## Entering directory '$OPENSSL_SRC'"
cd $OPENSSL_SRC
./config --prefix=$OPENSSL_DEST
is_ok
make
is_ok
make test
is_ok
echo $(date) > $AIU/install.d/log/openssl_make_install.log
make install &>>$AIU/install.d/log/openssl_make_install.log
is_ok
make clean
set_value openssl_dest $OPENSSL_DEST
is_ok
echo "## INFO: 'openssl' is installed to '$OPENSSL_DEST'"
cd $AIU
echo "#################### OpenSSL END ####################"
