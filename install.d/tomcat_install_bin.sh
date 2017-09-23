#!/bin/bash

echo "#################### Tomcat BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`; pwd))
fi

. $AIU/install.d/functions.sh
init_pkg tomcat

echo "#################### Check If Tomcat Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed tomcat

echo "#################### Install Tomcat ####################"
echo "## Entering directory '$SRC'"
cd $SRC
preinstall_bin tomcat $DEST
TOMCAT_BINARY=$EXT_DIR
get_value tomcat;TOMCAT=$VALUE
mv $TOMCAT_BINARY $TOMCAT
TOMCAT_DEST=$DEST/$TOMCAT

# compile tomcat daemon
echo "## INFO: Entering directory $TOMCAT_DEST/bin"
cd $TOMCAT_DEST/bin
tar zxvf commons-daemon-native.tar.gz
echo "## INFO: Entering directory $TOMCAT_DEST/bin/commons-daemon-1.0.15-native-src/unix"
cd commons-daemon-1.0.15-native-src/unix
./configure --with-java=/usr/local/java
make
cp jsvc $TOMCAT_DEST/bin
# create group and user for running tomcat
if [[ -z $(cat /etc/group | cut -d ":" -f 1 | grep "^tomcat$") ]]; then
  groupadd tomcat
fi
if [[ -z $(cat /etc/passwd | cut -d ":" -f 1 | grep "^tomcat$") ]]; then
  useradd -r -M -g tomcat -s /bin/false tomcat
fi
# modify daemon.sh
sed -i '91c JAVA_HOME=/usr/local/java' $TOMCAT_DEST/bin/daemon.sh

# modify file permissions
chown -R tomcat:tomcat $TOMCAT_DEST
chmod +x $TOMCAT_DEST/bin/daemon.sh

# configure as service
ln -s $TOMCAT_DEST/bin/daemon.sh /etc/init.d/tomcat
# on ubuntu 16.04
sed -i '2a ### BEGIN INIT INFO\n# Provides: Tomcat\n# Required-Start:\n# Required-Stop:\n# Default-Start: 3 5\n# Default-Stop: 0 1 2 4 6\n# Short-Description: start and stop Tomcat\n# Description: Apache Tomcat is a web server and container.\n### END INIT INFO' $TOMCAT_DEST/bin/daemon.sh
update-rc.d tomcat defaults
## disable start on system startup
update-rc.d tomcat disable

set_value "tomcat_dest" $TOMCAT_DEST
echo "#################### Tomcat END ####################"
