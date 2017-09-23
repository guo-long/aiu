#!/bin/bash

# PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

AIU=$(cd `dirname $0`;pwd)
. $AIU/install.d/functions.sh
init_aiu

apt-get -y update
apt-get -y dist-upgrade
apt-get install gcc g++ make build-essential

# install from source
$AIU/install.d/git_install.sh
is_ok
# $AIU/install.d/git-daemon_install.sh
# is_ok
$AIU/install.d/httpd_install.sh
is_ok
$AIU/install.d/node_install.sh
is_ok
$AIU/install.d/subversion_install.sh
is_ok
$AIU/install.d/vim_install.sh
is_ok

# install from binary
$AIU/install.d/jdk_install.sh
is_ok
$AIU/install.d/maven_install_bin.sh
is_ok
$AIU/install.d/mysql_install_bin.sh
is_ok
$AIU/install.d/tomcat_install_bin.sh
is_ok
