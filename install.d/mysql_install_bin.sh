#!/bin/bash

echo "#################### MySQL BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`; pwd))
fi

. $AIU/install.d/functions.sh
init_pkg mysql

echo "#################### Check If MySQL Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed mysql

echo "#################### Handle Requirements ####################"
apt-get -y install libaio1
is_ok

echo "#################### Install MySQL ####################"
echo "## Entering directory '$SRC'"
cd $SRC
preinstall_bin mysql $DEST
MYSQL_BINARY=$EXT_DIR
get_value mysql;MYSQL=$VALUE
mv $MYSQL_BINARY $MYSQL
MYSQL_DEST=$DEST/$MYSQL
# create group and user for running mysql
if [[ -z $(cat /etc/group | cut -d ":" -f 1 | grep "^mysql$") ]]; then
  groupadd mysql
fi
if [[ -z $(cat /etc/passwd | cut -d ":" -f 1 | grep "^mysql$") ]]; then
  useradd -r -M -g mysql -s /bin/false mysql
fi
# configure file etc/my.cnf and directory mysql-files
echo "## INFO: Entering directory $MYSQL_DEST"
cd $MYSQL_DEST
mkdir etc
touch etc/my.cnf
echo "[mysqld]" >> etc/my.cnf
#cp support-files/my-default.cnf etc/my.cnf # MySQL 5.7.18 and down
sed -i "/# basedir/c basedir=$MYSQL_DEST" etc/my.cnf
sed -i "/# datadir/c datadir=$MYSQL_DEST/data" etc/my.cnf
mkdir mysql-files
chmod 750 mysql-files etc
chown -R mysql .
chgrp -R mysql .
## initialize mysql
bin/mysqld --defaults-file=$MYSQL_DEST/etc/my.cnf \
--initialize-insecure \
--user=mysql
bin/mysql_ssl_rsa_setup
chown -R root .
chown -R mysql data mysql-files
## start mysql by running background
bin/mysqld_safe --defaults-file=$MYSQL_DEST/etc/my.cnf --user=mysql &
bin/mysqladmin password 648502 -uroot -p
# configure as system service
ln -s $MYSQL_DEST/support-files/mysql.server /etc/init.d/mysql
update-rc.d mysql defaults
# set mysql environment variables
MYSQL_HOME=$(cat $ENVVARS | grep "^export MYSQL_HOME=")
if [[ -z $MYSQL_HOME ]]; then
  echo -e '\n# mysql' >> $ENVVARS
  echo "export MYSQL_HOME=$MYSQL_DEST" >> $ENVVARS
  echo 'export PATH=$PATH:/$MYSQL_HOME/bin' >> $ENVVARS
fi
source $ENVVARS
set_value "mysql_dest" $MYSQL_DEST
echo "#################### MySQL END ####################"
