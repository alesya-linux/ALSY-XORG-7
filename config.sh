#!/bin/bash
export XORG_PREFIX="/usr/src/tools/XORG-7"
export XORG_CONFIG="--prefix=$XORG_PREFIX              \
                    --sysconfdir=$XORG_PREFIX/etc      \
                    --localstatedir=$XORG_PREFIX/var   \
                    --disable-static"
SAVEPATH="$PATH"
PKG_CONFIG_PATH="$XORG_PREFIX/lib64/pkgconfig"
PKG_CONFIG_PATH="$XORG_PREFIX/share/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH="$XORG_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH" 
export PATH="$XORG_PREFIX/bin:$PATH"

LIBRARY_PATH=""
C_INCLUDE_PATH=""
CPLUS_INCLUDE_PATH="$C_INCLUDE_PATH"
LIBRARY_PATH="$XORG_PREFIX/lib:$LIBRARY_PATH"
C_INCLUDE_PATH="$XORG_PREFIX/include:$C_INCLUDE_PATH"
CPLUS_INCLUDE_PATH="$XORG_PREFIX/include:$CPLUS_INCLUDE_PATH"
ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"
export ACLOCAL LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH
export XORGPREFIX="$XORG_PREFIX"
export XORGCONFIG="$XORG_CONFIG"

MD5SUMFILE=""
APPLICATION_SITE=""
INSTALL_APPLICATION=""

APP_LISTING=".APP_LISTING"
APP_CONFIG=".APP_CONFIG"
APP_MAKEFILE=".APP_MAKEFILE"
APP_COMPILE="build/compile"

ETAP1_FLAG=" " # This is compile for file XORG-7.md5
ETAP2_FLAG=" " # This is compile for file app-7.md5 
ETAP3_FLAG=" " # This is compile for file font-7.md5 
ETAP4_FLAG="X" # This is compile for file XorgInputDrivers.md5
ETAP5_FLAG=" " # This is compile for file XorgVideoDrivers.md5
ETAP6_FLAG=" " # This is compile for file Xorg-Legacy.md5

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

make_install()
{
LASTPATH="$PATH"
PATH="$SAVEPATH"
make install
check_last "make install"
# Add Log
Add_Log
PATH="$LASTPATH"
}

compile()
{
  APPLICATION_SITE="$PWD"
  MD5SUMFILE="$(md5sum $APPLICATION_SITE/$APP_COMPILE/$packagedir/$package)"
  INSTALL_APPLICATION="$packagedir"
  
pushd $packagedir
./config.sh
check_last "config"
make      
check_last "make"
make_install
popd
}

if [ "$ETAP1_FLAG" == "X" ]; then

for package in $(grep -v '^#' $APP_LISTING/XORG-7.md5 | awk '{print $2}')
do  
  packagedir=${package%.tar.*}
  typearchive=${package#*.tar.*}
  
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $APP_COMPILE/$packagedir ]; then
  mkdir -p $APP_COMPILE/$packagedir
  if [ -f $package ]; then
    mv -v $package $APP_COMPILE/$packagedir
  fi
  cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  case $packagedir in
  util-linux* )
    cp -r $APP_CONFIG/util-linux-config.sh $APP_COMPILE/$packagedir/config.sh
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
  xcb-util* )
    cp $APP_CONFIG/xcb-util-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  libdrm* )
    cp -r $APP_CONFIG/libdrm-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/meson-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libepoxy* )
    cp -r $APP_CONFIG/libepoxy-config.sh $APP_COMPILE/$packagedir/config.sh
    cp -r $APP_MAKEFILE/meson-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
  ;;
  libpng* )
    cp -r $APP_CONFIG/libpng-config.sh $APP_COMPILE/$packagedir/config.sh
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
    cp -r $APP_MAKEFILE/meson-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
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
    cp $APP_CONFIG/zlib-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  esac
fi

if [ -d $APP_COMPILE/$packagedir ]; then
 pushd $APP_COMPILE
 compile
 popd
fi
done

fi

if [ "$ETAP2_FLAG" == "X" ]; then

# List Xorg Application
for package in $(grep -v '^#' $APP_LISTING/app-7.md5 | awk '{print $2}')
do
packagedir=${package%.tar.*}
typearchive=${package#*.tar.*}
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $APP_COMPILE/$packagedir ]; then
  mkdir -p $APP_COMPILE/$packagedir
  cp $APP_CONFIG/xorg-app-config.sh $APP_COMPILE/$packagedir/config.sh
  case $packagedir in 
  xcursor-themes* )
    cp -r $APP_CONFIG/data-config.sh $APP_COMPILE/$packagedir/config.sh
  ;;
  esac  
  cp $APP_MAKEFILE/proto-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
fi
      
if [ -d $APP_COMPILE/$packagedir ]; then
  pushd $APP_COMPILE
  compile
  popd
fi
done

fi

if [ "$ETAP3_FLAG" == "X" ]; then

# List Xorg Font
for package in $(grep -v '^#' $APP_LISTING/font-7.md5 | awk '{print $2}')
do
packagedir=${package%.tar.*}
typearchive=${package#*.tar.*}
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $packagedir ]; then
  mkdir -p $packagedir
  if [ -f $package ]; then
    mv -v $package $packagedir
  fi
  cp $APP_CONFIG/xorg-font-config.sh $packagedir/config.sh
  cp $APP_MAKEFILE/proto-Makefile.am $packagedir/Makefile.am
  case $packagedir in 
  xkeyboard-config* )
    cp -r $APP_CONFIG/XKeyboardConfig.sh $packagedir/config.sh
  ;;
  xorg-server* )
    cp -r $APP_CONFIG/Xorg-Server-config.sh $packagedir/config.sh
  ;;
  pixman* )
    cp -r $APP_CONFIG/pixman-config.sh $packagedir/config.sh
  ;;
  libdrm* )
    cp -r $APP_CONFIG/libdrm-config.sh $packagedir/config.sh
    cp -r $APP_MAKEFILE/meson-Makefile.am $packagedir/Makefile.am
  ;;
  libunwind* )
    cp -r $APP_CONFIG/libunwind-config.sh $packagedir/config.sh
  ;;
  freetype-2* )
    cp -r $APP_CONFIG/freetype-config.sh $packagedir/config.sh
  ;;
  freetype2* )
    cp -r $APP_CONFIG/freetype2-config.sh $packagedir/config.sh
  ;;
  harfbuzz* )
    cp -r $APP_CONFIG/harfbuzz-config.sh $packagedir/config.sh  
  ;;
  fontconfig* )
    cp -r $APP_CONFIG/fontconfig.sh $packagedir/config.sh
  ;;
  util* )
    cp -r $APP_CONFIG/util-linux-config.sh $packagedir/config.sh
  ;;
  esac
fi
      
if [ -d $packagedir ]; then
compile
fi
done

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

# List Xorg Input Drivers
for package in $(grep -v '^#' $APP_LISTING/XorgInputDrivers.md5 | awk '{print $2}')
do
packagedir=${package%.tar.*}
typearchive=${package#*.tar.*}
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $APP_COMPILE/$packagedir ]; then
  mkdir -p $APP_COMPILE/$packagedir
  if [ -f $APP_COMPILE/$package ]; then
    mv -v $package $APP_COMPILE/$packagedir
  fi
fi


  case $packagedir in
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
    cp -r $APP_MAKEFILE/meson-Makefile.am $APP_COMPILE/$packagedir/Makefile.am
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

fi

if [ "$ETAP5_FLAG" == "X" ]; then

# List Xorg Video Drivers
for package in $(grep -v '^#' $APP_LISTING/XorgVideoDrivers.md5 | awk '{print $2}')
do
packagedir=${package%.tar.*}
typearchive=${package#*.tar.*}
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $APP_COMPILE/$packagedir ]; then
  mkdir -p $APP_COMPILE/$packagedir
  if [ -f $APP_COMPILE/$package ]; then
    mv -v $package $APP_COMPILE/$packagedir
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

fi

if [ "$ETAP6_FLAG" == "X" ]; then

# Xorg Legacy Font

#mkdir -p legacy &&
#cd    legacy &&
#grep -v '^#' ../$APP_LISTING/legacy.dat | awk '{print $2$3}' | wget -i- -c \
#     -B https://www.x.org/pub/individual/ &&
#grep -v '^#' ../$APP_LISTING/legacy.dat | awk '{print $1 " " $3}' > ../$APP_LISTING/Xorg-Legacy.md5 &&
#md5sum -c ../$APP_LISTING/Xorg-Legacy.md5 && cd ..

for package in $(grep -v '^#' $APP_LISTING/Xorg-Legacy.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.*}
  typearchive=${package#*.tar.*}
  case $packagedir in
  xterm* )
    packagedir=${package%.tgz}
    typearchive=${package#*.tgz}
  ;;
  esac
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $packagedir ]; then
  mkdir -p $packagedir  
fi

if [ -f legacy/$package ]; then
  cp -rfv legacy/$package $packagedir
fi 
  
cp $APP_MAKEFILE/proto-Makefile.am $packagedir/Makefile.am
cp $APP_CONFIG/Xorg-Legacy-Font-config.sh $packagedir/config.sh
export APP_SITE="app"
 case $packagedir in
 font* )
   export APP_SITE="font"
 ;;
 xterm* )
   cp $APP_CONFIG/Xorg-xterm-config.sh $packagedir/config.sh
 ;;
 esac
if [ -d $packagedir ]; then
  compile
  ldconfig
fi
done

fi
