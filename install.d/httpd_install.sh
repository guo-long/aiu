#!/bin/bash

echo "#################### HTTPD BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`; pwd))
fi

. $AIU/install.d/functions.sh
init_pkg httpd

echo "#################### Check If HTTPD Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed httpd

echo "#################### Handle Requirements ####################"
apt-get -y install autoconf
$AIU/install.d/apr_install.sh
$AIU/install.d/apr-util_install.sh
$AIU/install.d/pcre_install.sh
#$AIU/install.d/openssl_install.sh
get_value apr_src;APR_SRC=$VALUE
is_dir_exist $APR_SRC
get_value apr-util_src;APR_UTIL_SRC=$VALUE
is_dir_exist $APR_UTIL_SRC
get_value apr_dest;APR_DEST=$VALUE
is_dir_exist $APR_DEST
get_value apr-util_dest;APR_UTIL_DEST=$VALUE
is_dir_exist $APR_UTIL_DEST
get_value pcre_dest;PCRE_DEST=$VALUE
is_dir_exist $PCRE_DEST
#get_value openssl_dest;OPENSSL_DEST=$VALUE
#is_dir_exist $OPENSSL_DEST

echo "#################### Install HTTPD ####################"
echo "## Entering directory '$SRC'"
cd $SRC
pre_install httpd
HTTPD_SOURCE=$EXT_DIR
HTTPD_SRC=$SRC/$HTTPD_SOURCE
get_value httpd;HTTPD=$VALUE
HTTPD_DEST=$DEST/$HTTPD
echo "## Entering directory '$HTTPD_SRC'"
cd $HTTPD_SRC
./buildconf \
--with-apr=$APR_SRC \
--with-apr-util=$APR_UTIL_SRC
is_ok
./configure --prefix=$HTTPD_DEST \
--with-apr=$APR_DEST \
--with-apr-util=$APR_UTIL_DEST \
--with-pcre=$PCRE_DEST \
--enable-so \
--enable-ssl \
--with-ssl=/usr/bin/openssl \
--enable-dav \
--enable-maintainer-mode
is_ok
make
is_ok
echo $(date) > $AIU/install.d/log/httpd_make_install.log
make install &>>$AIU/install.d/log/httpd_make_install.log
is_ok
make clean
set_value httpd_dest $HTTPD_DEST
is_ok
echo "## INFO: 'httpd' is installed to '$HTTPD_DEST'"

echo "#################### HTTPD Configuration ####################"
if [ -z $(cat /etc/group | cut -d ":" -f 1 | grep ^apache$) ]; then
  echo '## INFO: add group: apache'
  groupadd apache
fi
if [ -z $(cat /etc/passwd | cut -d ":" -f 1 | grep ^apache$) ]; then
  echo '## INFO: add user: apache'
  useradd -r -M -g apache -s /bin/false apache
fi
echo "## INFO: modify the permission mode of $HTTPD_DEST"
chown -R apache:apache $HTTPD_DEST
echo "## INFO: configure file $HTTPD_DEST/conf/httpd.conf"
sed -i '/User daemon/s/daemon/apache/g' $HTTPD_DEST/conf/httpd.conf
sed -i '/Group daemon/s/daemon/apache/g' $HTTPD_DEST/conf/httpd.conf
sed -i '/#ServerName www.example.com:80/c ServerName matrix:80' $HTTPD_DEST/conf/httpd.conf
if [ ! -d /var/www ]; then
  mkdir /var/www
  chmod 750 /var/www
  chown -R apache:apache /var/www
fi
sed -i '/DocumentRoot ".*\/htdocs"/c DocumentRoot "/var/www"' $HTTPD_DEST/conf/httpd.conf
sed -i '/<Directory ".*\/htdocs">/c <Directory "/var/www">' $HTTPD_DEST/conf/httpd.conf
echo '## INFO: configure apache as a systme service'
sed -i '2a ### BEGIN INIT INFO\n# Provides: Apache\n# Required-Start:\n# Required-Stop:\n# Default-Start: 3 5\n# Default-Stop: 0 1 2 4 6\n# Short-Description: start and stop Apache HTTP Server\n# Description: Apache HTTP Server is a web server.\n### END INIT INFO' $HTTPD_DEST/bin/apachectl
ln -s $HTTPD_DEST/bin/apachectl /etc/init.d/apache
update-rc.d apache defaults
echo "## INFO: 'httpd' has been configured"
cd $AIU
echo "#################### HTTPD END ####################"
