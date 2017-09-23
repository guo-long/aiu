# 获取 key 对应的 value
# 产生全局变量 VALUE
function get_value() {
  unset VALUE
  if [[ -n $1 ]]; then
    VALUE=$(cat $AIU/install.conf | grep "^$1=" | cut -d "=" -f 2)
    # if [[ -z $VALUE ]]; then
    #   echo "## ERROR: No such key '$1', or no value for the key"
    #   exit 1
    # fi
  else
    echo "## ERROR: Parameter not found"
    exit 1
  fi
}

# 设置 key 对应的 value
function set_value() {
  local suffix=${1##*_}
  case "$suffix" in
    dest )
      sed -i "/^$1=/c $1=$2" $AIU/install.conf
      ;;
    src )
      sed -i "/^$1=/c $1=$SRC/$EXT_DIR" $AIU/install.conf
      ;;
  esac
}

# 检查目录是否存在
function is_dir_exist() {
  if [[ ! -d $1 ]]; then
    echo "## ERROR: Directory '$1' not found"
    exit 1
  fi
}

# 初始化 AIU
function init_aiu() {
  echo "Initializing AIU..."
  get_value DEST; DEST=$VALUE
  is_dir_exist $DEST
  get_value SRC; SRC=$VALUE
  is_dir_exist $SRC
  if [[ ! -f /etc/profile.d/custom.sh ]]; then
    touch /etc/profile.d/custom.sh
  fi
  ENVVARS=/etc/profile.d/custom.sh
  rm -rf $AIU/install.d/log/*
  echo "Initializing AIU done"
}

# 软件包安装前初始化
function init_pkg() {
  echo "Initializing $1..."
  if [[ -z $DEST ]]; then
    get_value DEST; DEST=$VALUE
    is_dir_exist $DEST
  fi
  if [[ -z $SRC ]]; then
    get_value SRC; SRC=$VALUE
    is_dir_exist $SRC
  fi
  if [[ -z $ENVVARS ]]; then
    if [[ ! -f /etc/profile.d/custom.sh ]]; then
      touch /etc/profile.d/custom.sh
    fi
    ENVVARS=/etc/profile.d/custom.sh
  fi
  if [[ -f $AIU/install.d/log/"$1"_make_install.log ]]; then
    rm -rf $AIU/install.d/log/"$1"_make_install.log
  fi
  echo "Initializing $1 done"
}

# 检查上一个命令执行是否正常
function is_ok() {
  if [[ $? -ne 0 ]]; then
    echo "## ERROR: Command in '$0' not executed correctly"
    exit
  fi
}

# 检查软件包是否以前被 DPKG 安装
function is_installed_dpkg() {
  local dpkg=$(dpkg -l | awk '{print $2}' | grep $1)
  if [[ -n $dpkg ]]; then
    echo "## WARNING: $1 probably installed by DPKG:"
    echo $dpkg
    echo "## WARNING: Installations above probably cause conflicts with current installing"
  fi
}

# 检查 DEST 下是否存在目录 pkg_dest，也即检查是否已安装
function is_installed_src_bin() {
  get_value $1; local pkg=$VALUE
  if [[ -n $pkg && -d $DEST/$pkg ]]; then
    echo "## WARNING: Directory '$DEST/$pkg' already exists"
    echo "## WARNING: If reinstall $1, delete '$DEST/$pkg', or change the value of key '$1' in '$AIU/install.conf'"
    exit 1
  fi
}

# APT 安装依赖
function apt_install() {
  apt-get -y install $*
  if [ $? -ne 0 ]; then
    echo "## ERROR: Installing $* by APT occur errors"
    exit
  fi
}

# 下载源码或二进制归档文件
# 依赖全局变量 ARCHIVE
function download() {
  get_value $1_url;local url=$VALUE
  if [[ -z $url ]]; then
    echo "## ERROR: $1_url: missing downloading URL"
    exit 1
  fi
  local downloaded_archive=$(basename $url)
  echo "## INFO: Download archive '$downloaded_archive'"
  if [[ $1 = "jdk" ]]; then
    wget --no-cookie --header "Cookie: oraclelicense=accept-securebackup-cookie" $url
  else
    wget $url
  fi
  if [[ $? -ne 0 ]]; then
    if [[ -f $downloaded_archive ]]; then
      rm -rf $downloaded_archive
    fi
    echo "## ERROR: Downloading '$downloaded_archive' occurs error"
    exit 1
  fi
  ARCHIVE=$downloaded_archive
}

# 解压缩
# 依赖全局变量 ARCHIVE 作为解压缩文件名
function decompress() {
  if [[ ! -f $1 ]]; then
    echo "## ERROR: No archive $1 found"
    exit 1
  fi
  echo "## INFO: Decompressing archive '$SRC/$1'"
  case $1 in
    # *.tar.gz)
    #   tar zxf $1;;
    # *.tar.bz2)
    #   tar jxf $1;;
    # *.tar.xz)
    #   tar Jxf $1;;
    *.zip)
      unzip "$1"$([[ -n "$2" ]] && echo " -d $2")
      ;;
    *)
      tar -axf "$1"$([[ -n "$2" ]] && echo " -C $2")
      ;;
  esac
  if [[ $? -ne 0 ]]; then
    echo "## ERROR: Decompressing occurs error"
  fi
}

# 获取软件包的归档文件，并保存其名称
# 产生全局变量 ARCHIVE
function get_archive() {
  for file in $(ls | grep "^$1$\|$1[[:digit:]]\+\|$1-[vV]\?[[:digit:]]\+")
  do
    if [[ -f $file ]]; then
      # 正常情况，在 $SRC 下每个软件包只存在一个归档文件
      ARCHIVE=$file
      echo "## INFO: Archive '$SRC/$ARCHIVE' found"
      return
    fi
  done
  unset file
}

# 正常情况，在 $SRC 下只有一个符合条件的解压缩目录
# 产生全局变量 EXT_DIR
# 依赖全局变量 ARCHIVE
function get_ext_dir() {
  unset EXT_DIR
  for dir in $(ls | grep "^$1$\|$1[[:digit:]]\+\|$1-[vV]\?[[:digit:]]\+")
  do
    if [[ -d $dir ]]; then
      EXT_DIR=$dir
      set_value $1_src
      echo "## INFO: '$SRC/$ARCHIVE' is decompressed to directory '$(pwd)/$EXT_DIR'"
    fi
  done
  unset dir
  if [[ -z $EXT_DIR ]]; then
    echo "## ERROR: EXT_DIR: No such directory"
    exit 1
  fi
  return 0
}
function get_ext_dir_bin() {
  unset EXT_DIR
  for dir in $(ls | grep "^$1$\|$1[[:digit:]]\+\|$1-[vV]\?[[:digit:]]\+")
  do
    if [[ -d $dir ]]; then
      EXT_DIR=$dir
      # set_value $1_src
      echo "## INFO: '$SRC/$ARCHIVE' is decompressed to directory '$(pwd)/$EXT_DIR'"
    fi
  done
  unset dir
  if [[ -z $EXT_DIR ]]; then
    echo "## ERROR: EXT_DIR: No such directory"
    exit 1
  fi
  return 0
}

# 删除已解压缩的源码或二进制目录
function delete_ext_dir() {
  for dir in $(ls | grep "^$1$\|^$1[[:digit:]]\+\|^$1-[vV]\?[[:digit:]]\+")
  do
    if [[ -d $dir ]]; then
      rm -rf $dir
      echo "## INFO: Deleting temporary decompressed source or binary directory: $SRC/$dir"
    fi
  done
  unset dir
}

# preinstall from source
function pre_install() {
  delete_ext_dir $1
  get_archive $1
  if [[ ! -f $ARCHIVE ]]; then
    download $1
  fi
  decompress $ARCHIVE
  get_ext_dir $1
  # 最后一次使用由函数定义的全局变量后，unset 该变量。因为在多个位置赋值 ARCHIVE并各个位置互有关系，所以在使用后 unset
  unset ARCHIVE
}

# preinstall from binary
function preinstall_bin() {
  get_archive $1
  if [[ ! -f $ARCHIVE ]]; then
    download $1
  fi
  decompress $ARCHIVE $2
  echo "## INFO: Entering directory $2"
  cd $2
  get_ext_dir_bin $1
  unset ARCHIVE
}

# 检查指定软件包是否存在已安装的实例
function is_installed() {
  is_installed_dpkg $1
  is_installed_src_bin $1
}
