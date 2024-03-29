#!/bin/bash
export XORG_PREFIX="/usr/src/tools/ALSY-XORG-7"
FLAGSET="X"
ETAP1_FLAG="X" # This is Flag compile for file XORG-7.md5
ETAP2_FLAG="X" # This is Flag compile for file app-7.md5 
ETAP3_FLAG="X" # This is Flag compile for file font-7.md5 
ETAP4_FLAG="X" # This is Flag compile for file XorgInputDrivers.md5
ETAP5_FLAG="X" # This is Flag compile for file XorgVideoDrivers.md5
ETAP6_FLAG="X" # This is Flag compile for file Xorg-Legacy.md5
ETAP6_WGET_FLAG="X"
CHECK_MD5SUM_FLAG="X"
export SOURCE_DATE_EPOCH="$(date +%s)";

gcc_version=$(gcc --version | grep "gcc (GCC)" | cut -d " " -f3)

if [ "$( echo $1 | sed 's/--prefix=//' )" != ""  ]; then
  export XORG_PREFIX="$( echo $1 | sed 's/--prefix=//' )"  
fi

prefix=$(echo $XORG_PREFIX | sed 's/\//\\\//g' )
cp -a Makefile.in Makefile.am
sed -i 's/\${PREFIX}/'$prefix'/' Makefile.am

INSTALL_DIR=$XORG_PREFIX
l1="$(expr length $INSTALL_DIR)"
INSTALL_DIR="${XORG_PREFIX%/*}"
if [ "$INSTALL_DIR" != "" ]; then
  l2="$(expr length $INSTALL_DIR)"  
fi
let r1=l1-1
if [ "$r1" == "$l2" ]; then
  INSTALL_DIR="${INSTALL_DIR%/*}"
fi
if [ "$INSTALL_DIR" == "" ]; then
  echo "Error: invalid prefix"
  exit 1
fi
INSTALLDIR=$(echo $INSTALL_DIR | sed 's/\//\\\//g' )
sed 's/\${INSTALLDIR}/'$INSTALLDIR'/' Makefile.am > Makefile

export XORG_CONFIG="--prefix=$XORG_PREFIX              \
                    --sysconfdir=$XORG_PREFIX/etc      \
                    --localstatedir=$XORG_PREFIX/var   \
                    --disable-static"
SAVEPATH="$PATH"
PKG_CONFIG_PATH="$XORG_PREFIX/lib64/pkgconfig:$XORG_PREFIX/lib/pkgconfig"
PKG_CONFIG_PATH="$XORG_PREFIX/share/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH
export PATH="$XORG_PREFIX/bin:$PATH"

LIBRARY_PATH=""
C_INCLUDE_PATH=""
CPLUS_INCLUDE_PATH=""
LIBRARY_PATH="$XORG_PREFIX/lib:$LIBRARY_PATH"
C_INCLUDE_PATH="$XORG_PREFIX/include:$C_INCLUDE_PATH"
CPLUS_INCLUDE_PATH="/include/c++/$gcc_version:$XORG_PREFIX/include:$CPLUS_INCLUDE_PATH"
ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"
export ACLOCAL LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH
export XORGPREFIX="$XORG_PREFIX"
export XORGCONFIG="$XORG_CONFIG"
export LD_LIBRARY_PATH="$XORG_PREFIX/lib:$XORG_PREFIX/lib64"
export CPLUS_INCLUDE_PATH

MD5SUMFILE=""
APPLICATION_SITE=""
INSTALL_APPLICATION=""

APP_LISTING=".APP_LISTING"
APP_CONFIG=".APP_CONFIG"
APP_MAKEFILE=".APP_MAKEFILE"
APP_COMPILE="build/compile"
APP_PACKAGE="APP_PACKAGE"
APP_PATCHES="APP_PATCHES"

echo "Installation Log File: $(date)" > install_log.txt

Add_Log()
{
  echo "$INSTALL_APPLICATION: $MD5SUMFILE" >> $APPLICATION_SITE/install_log.txt
}

check_last()
{
  if [ $? -ne 0 ]; then    
    echo "Error $*"
    exit 1    
  fi
}

as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

make_install()
{
LASTPATH="$PATH"
PATH="$SAVEPATH"
as_root make XORG_PREFIX=$XORG_PREFIX install
check_last "make install"
# Add Log
Add_Log
PATH="$LASTPATH"
}

compile()
{
APPLICATION_SITE="$PWD"
INSTALL_APPLICATION="$packagedir"
 
pushd $packagedir
chmod u+x config.sh
if [ -f install.sh ]; then
chmod u+x install.sh
fi
./config.sh
check_last "config"
if [ -f $APPLICATION_SITE/$packagedir/$package ]; then
  MD5SUMFILE=$( md5sum $APPLICATION_SITE/$packagedir/$package | cut -d" " -f1 )
fi
if [ "$CHECK_MD5SUM_FLAG" == "X" ]; then  
  if [ "$MD5SUMFILE" != "$CURRMD5SUM" ]; then
    echo "Error check md5sum for file: $APPLICATION_SITE/$packagedir/$package"
    echo "$CURRMD5SUM"
    echo "$MD5SUMFILE"
    exit 1
  else
    MD5SUMFILE="$(md5sum $APPLICATION_SITE/$packagedir/$package)"
  fi
fi
make XORG_PREFIX=$XORG_PREFIX      
check_last "make"
make_install
popd
}


if [ "$ETAP1_FLAG" == "X" ]; then
COMPILEFILE="$APP_LISTING/XORG-7.md5"
for package in $(grep -v '^#' $COMPILEFILE | awk '{print $2}')
do  
  if [ "${package%.tar.*}" != "$package" ]; then
    packagedir=${package%.tar.*}
    typearchive=${package#*.tar.*}
  else
    packagedir=${package%.tgz}
    typearchive=${package#*.tgz}
  fi
  CURRMD5SUM=$(grep -v '^#' $COMPILEFILE | grep $package | cut -d" " -f1)

for ijk1 in $(echo $CURRMD5SUM)
do
  CURRMD5SUM=${ijk1}
done
  
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $APP_COMPILE/$packagedir ]; then
  mkdir -p $APP_COMPILE/$packagedir
fi  

if [ -f $APP_PACKAGE/$package ]; then
  cp -rfv $APP_PACKAGE/$package $APP_COMPILE/$packagedir
  if [ -L $APP_PACKAGE/$package ]; then
    targetfile=$(ls -l $APP_PACKAGE/$package | cut -d">" -f2 | cut -d" " -f2)
    cp -rfv $APP_PACKAGE/$targetfile $APP_COMPILE/$packagedir
  fi
fi

cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
case $packagedir in
  libva*)
    cp -a $APP_CONFIG/libva-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/libva-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  graphite2*)
    cp -a $APP_CONFIG/graphite2-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  pkg* )
    cp -a $APP_CONFIG/pkg-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  bison* )
    cp -r $APP_CONFIG/bison-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/bison-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  flex* )
    cp -r $APP_CONFIG/flex-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/flex-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  bzip2* )
    cp -r $APP_CONFIG/bzip2-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/bzip2-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  xz* )
    cp -r $APP_CONFIG/xz-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  libgcrypt* )
    cp -r $APP_CONFIG/libgcrypt-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  libgpg* )
    cp -r $APP_CONFIG/libgpg-error-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  readline* )
    cp -r $APP_CONFIG/readline-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/readline-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  expat* )
    cp $APP_CONFIG/expat-config.sh $APP_COMPILE/$packagedir/config.sh    
    cp $APP_MAKEFILE/expat-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  gperf* )
    cp -r $APP_CONFIG/gperf-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  ncurses* )
    cp -r $APP_CONFIG/ncurses-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/ncurses-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  pcre2* )
    cp -r $APP_CONFIG/pcre2-config.sh $APP_COMPILE/$packagedir/config.sh
  ;; 
  pcre* )
    cp -r $APP_CONFIG/pcre-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  gettext* )
    cp -r $APP_CONFIG/gettext-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  V3* )
    cp -r $APP_CONFIG/V3-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/lm_sensors-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  file* )
    cp -r $APP_CONFIG/file-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  util-linux* )
    cp -r $APP_CONFIG/util-linux-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  freetype-2* )
    cp -r $APP_CONFIG/freetype-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  freetype2* )
    cp -r $APP_CONFIG/freetype2-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/freetype2-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
    ln -svf freetype-2.13.0.tar.xz $APP_COMPILE/$packagedir/$package
  ;;
  harfbuzz* )
    cp -r $APP_CONFIG/harfbuzz-config.sh $APP_COMPILE/$packagedir/config.sh  
  ;;
  fontconfig* )
    cp -r $APP_CONFIG/fontconfig.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  xcb-util* )
    cp $APP_CONFIG/xcb-util-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  libdrm* )
    cp -r $APP_CONFIG/libdrm-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/libdrm-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libepoxy* )
    cp -r $APP_CONFIG/libepoxy-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/libepoxy-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libpng* )
    cp -r $APP_CONFIG/libpng-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  libxml2* )
    cp $APP_CONFIG/libxml2-config.sh $APP_COMPILE/$packagedir/config.sh    
    cp $APP_MAKEFILE/libxml2-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
    if [ -f $APP_PATCHES/libxml2-2.9.10-security_fixes-1.patch ]; then
      cp $APP_PATCHES/libxml2-2.9.10-security_fixes-1.patch $APP_COMPILE/$packagedir
    fi
  ;;
  libxslt* )
    cp $APP_CONFIG/libxslt-config.sh $APP_COMPILE/$packagedir/config.sh    
    cp $APP_MAKEFILE/libxslt-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
    cp $APP_CONFIG/libxslt-install.sh $APP_COMPILE/$packagedir/install.sh
  ;;
  lib* )
    cp $APP_CONFIG/xorglib-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  xtrans* )
    cp $APP_CONFIG/xorglib-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  proto* )
    cp $APP_CONFIG/proto-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  glproto* )
    cp $APP_CONFIG/proto-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  util* )
    cp $APP_CONFIG/util-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  Python* )
    cp $APP_CONFIG/python-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;  
  mesa* )
    cp $APP_CONFIG/mesa-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/mesa-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  randr* )
    cp $APP_CONFIG/proto-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  xineramaproto* )
    cp $APP_CONFIG/proto-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  xproto* )
    cp $APP_CONFIG/proto-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  xorgproto* )
    cp $APP_CONFIG/proto-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  xcb-proto* )
    cp $APP_CONFIG/proto-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  nettle* )  
    cp $APP_CONFIG/nettle-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  xbitmaps* )
    cp $APP_CONFIG/data-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  zlib* )
    cp -a $APP_CONFIG/zlib-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -a $APP_MAKEFILE/zlib-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
esac


if [ -d $APP_COMPILE/$packagedir ]; then
 pushd $APP_COMPILE
 compile
 popd
fi
done
# Снимаем флаг
sed -i 's/ETAP1_FLAG="'$FLAGSET'"/ETAP1_FLAG=" "/' config.sh
fi


if [ "$ETAP2_FLAG" == "X" ]; then
COMPILEFILE="$APP_LISTING/app-7.md5"
# List Xorg Application
for package in $(grep -v '^#' $COMPILEFILE | awk '{print $2}')
do
packagedir=${package%.tar.*}
typearchive=${package#*.tar.*}
CURRMD5SUM=$(grep -v '^#' $COMPILEFILE | grep $package | cut -d" " -f1)
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $APP_COMPILE/$packagedir ]; then
  mkdir -p $APP_COMPILE/$packagedir
fi

if [ -f $APP_PACKAGE/$package ]; then
  cp -rfv $APP_PACKAGE/$package $APP_COMPILE/$packagedir
fi

cp $APP_CONFIG/xorg-app-config.sh $APP_COMPILE/$packagedir/config.sh
case $packagedir in 
  xcursor-themes* )
    cp -r $APP_CONFIG/data-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
esac  
cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am

if [ -d $APP_COMPILE/$packagedir ]; then
  pushd $APP_COMPILE
  compile
  popd
fi
done
# Снимаем флаг
sed -i 's/ETAP2_FLAG="'$FLAGSET'"/ETAP2_FLAG=" "/' config.sh
fi

if [ "$ETAP3_FLAG" == "X" ]; then
COMPILEFILE="$APP_LISTING/font-7.md5"
# List Xorg Font
for package in $(grep -v '^#' $COMPILEFILE | awk '{print $2}')
do
packagedir=${package%.tar.*}
typearchive=${package#*.tar.*}
CURRMD5SUM=$(grep -v '^#' $COMPILEFILE | grep $package | cut -d" " -f1)  
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $APP_COMPILE/$packagedir ]; then
  mkdir -p $APP_COMPILE/$packagedir  
fi

if [ -f $APP_PACKAGE/$package ]; then
  cp -rfv $APP_PACKAGE/$package $APP_COMPILE/$packagedir
fi 

  cp $APP_CONFIG/xorg-font-config.sh $APP_COMPILE/$packagedir/config.sh
  cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  
  case $packagedir in 
  xz* )
    cp -r $APP_CONFIG/xz-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;  
  xkeyboard-config* )
    cp -r $APP_CONFIG/XKeyboardConfig.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  xorg-server* )
    cp -r $APP_CONFIG/Xorg-Server-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  pixman* )
    cp -r $APP_CONFIG/pixman-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  libdrm* )
    cp -r $APP_CONFIG/libdrm-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/meson-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libunwind* )
    cp -r $APP_CONFIG/libunwind-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  freetype-2* )
    cp -r $APP_CONFIG/freetype-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  freetype2* )
    cp -r $APP_CONFIG/freetype2-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  harfbuzz* )
    cp -r $APP_CONFIG/harfbuzz-config.sh $APP_COMPILE/$packagedir/config.sh  
  ;;
  fontconfig* )
    cp -r $APP_CONFIG/fontconfig.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  util* )
    cp -r $APP_CONFIG/util-linux-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  freefont* )
    cp -r $APP_CONFIG/freefont-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_CONFIG/freefont-install.sh $APP_COMPILE/$packagedir/install.sh
    cp -r $APP_MAKEFILE/freefont-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
    cp -r $APP_MAKEFILE/freefont-Makefile.in $APP_COMPILE/$packagedir/Makefile.in
  ;;
  esac
      
if [ -d $APP_COMPILE/$packagedir ]; then
  pushd $APP_COMPILE
  compile
  popd
fi
done
# Снимаем флаг
sed -i 's/ETAP3_FLAG="'$FLAGSET'"/ETAP3_FLAG=" "/' config.sh
fi

# TEST INSTALL... 
echo $PKG_CONFIG_PATH
echo "--- check glproto......"
pkg-config --modversion glproto
echo "--- check freetype2......"
pkg-config --modversion freetype2
echo "--- check fontconfig......"
pkg-config --modversion fontconfig
echo "--- check harfbuzz......"
pkg-config --modversion harfbuzz
echo "--- check x11......"
pkg-config --modversion x11
echo "--- check libpng......"
pkg-config --modversion libpng
echo "--- check xfont2......"
pkg-config --modversion xfont2
echo "--- check xkbfile......"
pkg-config --modversion xkbfile
echo "--- check xau......"
pkg-config --modversion xau
echo "--- check xshmfence......"
pkg-config --modversion xshmfence
echo "--- check xdmcp......"
pkg-config --modversion xdmcp
echo "--- check dri3proto......"
pkg-config --modversion dri3proto
echo "--- check dri......"
pkg-config --modversion dri
echo "--- check presentproto......"
pkg-config --modversion presentproto
echo "--- check xf86driproto......"
pkg-config --modversion xf86driproto
echo "--- check resourceproto......"
pkg-config --modversion resourceproto
echo "--- check kbproto......"
pkg-config --modversion kbproto
echo "--- check videoproto......"
pkg-config --modversion videoproto
echo "--- check fixesproto......"
pkg-config --modversion fixesproto
echo "--- check xbitmaps......"
pkg-config --modversion xbitmaps
echo "--- check xorg-server......"
pkg-config --modversion xorg-server

if [ "$ETAP4_FLAG" == "X" ]; then
COMPILEFILE="$APP_LISTING/XorgInputDrivers.md5"
# List Xorg Input Drivers
for package in $(grep -v '^#' $COMPILEFILE | awk '{print $2}')
do
packagedir=${package%.tar.*}
typearchive=${package#*.tar.*}
CURRMD5SUM=$(grep -v '^#' $COMPILEFILE | grep $package | cut -d" " -f1)  
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $APP_COMPILE/$packagedir ]; then
  mkdir -p $APP_COMPILE/$packagedir
fi

if [ -f $APP_PACKAGE/$package ]; then
  cp -rfv $APP_PACKAGE/$package $APP_COMPILE/$packagedir
fi 

  case $packagedir in
  xorg-server* )
    cp -r $APP_CONFIG/Xorg-Server-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  attr* )
    cp -r $APP_CONFIG/attr-config.sh $APP_COMPILE/$packagedir/config.sh
    cp $APP_MAKEFILE/attr-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  acl* )
    cp -r $APP_CONFIG/acl-config.sh $APP_COMPILE/$packagedir/config.sh
    cp $APP_MAKEFILE/acl-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  xf86-input-wacom* )
    cp -r $APP_CONFIG/x86-wacom-input.config.sh $APP_COMPILE/$packagedir/config.sh
    cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  xf86* )
    cp -r $APP_CONFIG/freedesktop_x86-input-config.sh $APP_COMPILE/$packagedir/config.sh
    cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  Linux-PAM* )
    cp -r $APP_CONFIG/Linux-PAM-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/pam-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
    cp -r $APP_CONFIG/pam-install.sh $APP_COMPILE/$packagedir/install.sh
  ;;
  systemd* )
    cp -r $APP_CONFIG/systemd-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/meson-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libtirpc* )
    cp -r $APP_CONFIG/libtirpc-config.sh $APP_COMPILE/$packagedir/config.sh
    cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  mtdev* )
    cp -r $APP_CONFIG/mtdev-config.sh $APP_COMPILE/$packagedir/config.sh
    cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libinput* )
    cp -r $APP_CONFIG/libinput-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/libinput-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libcap1* )
    echo "---------------$APP_CONFIG"
    cp -r $APP_CONFIG/libcap1-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/libcap1-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libcap2* )
    cp -r $APP_CONFIG/libcap2-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/libcap2-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libpcap* )
    cp -r $APP_CONFIG/libpcap-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/libpcap-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libevdev* )
    cp $APP_CONFIG/freedesktop_soft-config.sh $APP_COMPILE/$packagedir/config.sh
    cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am  
  ;;
  esac


if [ -d $APP_COMPILE/$packagedir ]; then
 pushd $APP_COMPILE
 compile
 popd
fi
done
# Снимаем флаг
sed -i 's/ETAP4_FLAG="'$FLAGSET'"/ETAP4_FLAG=" "/' config.sh
fi # End Etap 4


if [ "$ETAP5_FLAG" == "X" ]; then
COMPILEFILE="$APP_LISTING/XorgVideoDrivers.md5"
# List Xorg Video Drivers
for package in $(grep -v '^#' $COMPILEFILE | awk '{print $2}')
do
packagedir=${package%.tar.*}
typearchive=${package#*.tar.*}
CURRMD5SUM=$(grep -v '^#' $COMPILEFILE | grep $package | cut -d" " -f1)  
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $APP_COMPILE/$packagedir ]; then
  mkdir -p $APP_COMPILE/$packagedir 
  if [ -f $APP_PACKAGE/$package ]; then
    cp -rfv $APP_PACKAGE/$package $APP_COMPILE/$packagedir
  fi 
  cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  cp $APP_CONFIG/proto-video-driver-config.sh $APP_COMPILE/$packagedir/config.sh
  case $packagedir in
  xf86-video-intel* )
    cp -r $APP_CONFIG/xf86-video-intel-20200817.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  xf86-video* )
    cp -r $APP_CONFIG/xf86-video-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;  
  esac
fi

if [ -d $APP_COMPILE/$packagedir ]; then
 pushd $APP_COMPILE
 compile
 popd
fi
done
# Снимаем флаг
sed -i 's/ETAP5_FLAG="'$FLAGSET'"/ETAP5_FLAG=" "/' config.sh
fi # End Etap 5


if [ "$ETAP6_FLAG" == "X" ]; then
COMPILEFILE="$APP_LISTING/Xorg-Legacy.md5"
# Xorg Legacy Font
if [ "$ETAP6_WGET_FLAG" == "X" ]; then

mkdir -p $APP_PACKAGE &&
cd    $APP_PACKAGE &&
grep -v '^#' ../$APP_LISTING/legacy.dat | awk '{print $2$3}' | wget -i- -c \
-B https://www.x.org/pub/individual/ &&
grep -v '^#' ../$APP_LISTING/legacy.dat | awk '{print $1 " " $3}' > ../$COMPILEFILE &&
md5sum -c ../$COMPILEFILE && 
echo "81e2d19bd74288f4ddd2476b466c3269 xterm-363.tgz" >> ../$COMPILEFILE && 
cd ..

# Снимаем флаг
sed -i 's/ETAP6_WGET_FLAG="'$FLAGSET'"/ETAP6_WGET_FLAG=" "/' config.sh

fi

for package in $(grep -v '^#' $COMPILEFILE | awk '{print $2}')
do
  packagedir=${package%.tar.*}
  typearchive=${package#*.tar.*}
  CURRMD5SUM=$(grep -v '^#' $COMPILEFILE | grep $package | cut -d" " -f1)  
  case $packagedir in
  xterm* )
    packagedir=${package%.tgz}
    typearchive=${package#*.}
  ;;
  esac
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $APP_COMPILE/$packagedir ]; then
  mkdir -p $APP_COMPILE/$packagedir
fi

if [ -f $APP_PACKAGE/$package ]; then
  cp -rfv $APP_PACKAGE/$package $APP_COMPILE/$packagedir
fi 

cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
cp $APP_CONFIG/Xorg-Legacy-Font-config.sh $APP_COMPILE/$packagedir/config.sh
export APP_SITE="app"
 case $packagedir in
 font* )
   export APP_SITE="font"
 ;;
 xterm* )
   cp $APP_CONFIG/Xorg-xterm-config.sh $APP_COMPILE/$packagedir/config.sh
 ;;
 esac
if [ -d $APP_COMPILE/$packagedir ]; then
  pushd $APP_COMPILE
  compile
  popd
fi
done
# Снимаем флаг
  sed -i 's/ETAP6_FLAG="'$FLAGSET'"/ETAP6_FLAG=" "/' config.sh
fi # End Etap 6
