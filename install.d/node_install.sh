#!/bin/bash

echo "#################### NODE BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`;pwd))
fi

. $AIU/install.d/functions.sh
init_pkg node

echo "#################### Check If Node Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed node

echo "#################### Handle Requirements ####################"
apt-get -y install clang

echo "#################### Install Node ####################"
echo "## Entering directory '$SRC'"
cd $SRC
pre_install node
NODE_SOURCE=$EXT_DIR
NODE_SRC=$SRC/$NODE_SOURCE
get_value node;NODE=$VALUE
NODE_DEST=$DEST/$NODE
echo "## Entering directory '$NODE_SRC'"
cd $NODE_SRC
./configure --prefix=$NODE_DEST
is_ok
make -j4
is_ok
make doc
is_ok
./node -e "console.log('Hello from Node.js ' + process.version)"
is_ok
echo $(date) > $AIU/install.d/log/node_make_install.log
make install &>>$AIU/install.d/log/node_make_install.log
is_ok
make clean
set_value node_dest $NODE_DEST
is_ok
echo "## INFO: 'node' is installed to '$NODE_DEST'"
cd $AIU
echo "#################### NODE END ####################"
