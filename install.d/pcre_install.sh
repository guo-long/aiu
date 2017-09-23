#!/bin/bash

echo "#################### PCRE BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`; pwd))
fi

. $AIU/install.d/functions.sh
init_pkg pcre

echo "#################### Check If PCRE Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed pcre

echo "#################### Install PCRE ####################"
echo "## Entering directory '$SRC'"
cd $SRC
pre_install pcre
PCRE_SOURCE=$EXT_DIR
PCRE_SRC=$SRC/$PCRE_SOURCE
get_value pcre;PCRE=$VALUE
PCRE_DEST=$DEST/$PCRE
echo "## Entering directory '$PCRE_SRC'"
cd $PCRE_SRC
./configure --prefix=$PCRE_DEST
is_ok
make
is_ok
echo $(date) > $AIU/install.d/log/pcre_make_install.log
make install &>>$AIU/install.d/log/pcre_make_install.log
is_ok
make clean
set_value pcre_dest $PCRE_DEST
is_ok
echo "## INFO: 'pcre' is installed to '$PCRE_DEST'"
cd $AIU
echo "#################### PCRE END ####################"
