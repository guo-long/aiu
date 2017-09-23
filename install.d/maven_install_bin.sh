#!/bin/bash

echo "#################### MAVEN BEGIN ####################"

if [ -z $AIU ]; then
  AIU=$(dirname $(cd `dirname $0`; pwd))
fi

. $AIU/install.d/functions.sh
init_pkg maven

echo "#################### Check If MAVEN Installed ####################"
echo "## Entering directory '$DEST'"
cd $DEST
is_installed maven

echo "#################### Install MAVEN ####################"
echo "## Entering directory '$SRC'"
cd $SRC
preinstall_bin maven $DEST
MAVEN_BINARY=$EXT_DIR
get_value "maven";MAVEN=$VALUE
mv $MAVEN_BINARY $MAVEN
MAVEN_DEST=$DEST/$MAVEN
sed -i '
/<profiles>/a\    <profile>\n      <id>jdk-1.8</id>\n      <activation>\n        <activeByDefault>true</activeByDefault>\n        <jdk>1.8</jdk>\n      </activation>\n      <properties>\n        <maven.compiler.source>1.8</maven.compiler.source>\n        <maven.compiler.target>1.8</maven.compiler.target>\n        <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>\n      </properties>\n    </profile>
' $MAVEN_DEST/conf/settings.xml

set_value "maven_dest" $MAVEN_DEST
MAVEN_HOME=$(cat $ENVVARS | grep "^export MAVEN_HOME=")
if [[ -z $MAVEN_HOME ]]; then
  echo -e '\n# maven' >> $ENVVARS
  echo "export MAVEN_HOME=$MAVEN_DEST" >> $ENVVARS
  echo 'export PATH=$PATH:/$MAVEN_HOME/bin' >> $ENVVARS
fi
source $ENVVARS
echo "#################### MAVEN END ####################"
