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
su -c "make install"
check_last "make install"
# Add Log
Add_Log
PATH="$LASTPATH"
}

compile()
{
  APPLICATION_SITE="$PWD"
  MD5SUMFILE="$(md5sum $APPLICATION_SITE/$packagedir/$package)"
  INSTALL_APPLICATION="$packagedir"
  
pushd $packagedir
./config.sh
check_last "config"
make      
check_last "make"
make_install
popd
}

for package in $(grep -v '^#' $APP_LISTING/XORG-7.md5 | awk '{print $2}')
do  
  packagedir=${package%.tar.*}
  typearchive=${package#*.tar.*}
  
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $packagedir ]; then
  mkdir -p $packagedir
  if [ -f $package ]; then
    mv -v $package $packagedir
  fi
  cp $APP_MAKEFILE/proto-Makefile.am $packagedir/Makefile.am
  case $packagedir in
  util-linux* )
    cp -r $APP_CONFIG/util-linux-config.sh $packagedir/config.sh
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
  xcb-util* )
    cp $APP_CONFIG/xcb-util-config.sh $packagedir/config.sh
  ;;
  libdrm* )
    cp -r $APP_CONFIG/libdrm-config.sh $packagedir/config.sh
    cp -r $APP_MAKEFILE/meson-Makefile.am $packagedir/Makefile.am
  ;;
  libepoxy* )
    cp -r $APP_CONFIG/libepoxy-config.sh $packagedir/config.sh
    cp -r $APP_MAKEFILE/meson-Makefile.am $packagedir/Makefile.am
  ;;
  libpng* )
    cp -r $APP_CONFIG/libpng-config.sh $packagedir/config.sh
  ;;
  lib* )
    cp $APP_CONFIG/xorglib-config.sh $packagedir/config.sh
  ;;
  xtrans* )
    cp $APP_CONFIG/xorglib-config.sh $packagedir/config.sh
  ;;
  proto* )
    cp $APP_CONFIG/proto-config.sh $packagedir/config.sh
  ;;
  glproto* )
    cp $APP_CONFIG/proto-config.sh $packagedir/config.sh
  ;;
  util* )
    cp $APP_CONFIG/util-config.sh $packagedir/config.sh
  ;;
  Python* )
    cp $APP_CONFIG/python-config.sh $packagedir/config.sh
  ;;  
  mesa* )
    cp $APP_CONFIG/mesa-config.sh $packagedir/config.sh
    cp -r $APP_MAKEFILE/meson-Makefile.am $packagedir/Makefile.am
  ;;
  randr* )
    cp $APP_CONFIG/proto-config.sh $packagedir/config.sh
  ;;
  xineramaproto* )
    cp $APP_CONFIG/proto-config.sh $packagedir/config.sh
  ;;
  xproto* )
    cp $APP_CONFIG/proto-config.sh $packagedir/config.sh
  ;;
  xorgproto* )
    cp $APP_CONFIG/proto-config.sh $packagedir/config.sh
  ;;
  xcb-proto* )
    cp $APP_CONFIG/proto-config.sh $packagedir/config.sh
  ;;
  nettle* )  
    cp $APP_CONFIG/nettle-config.sh $packagedir/config.sh
  ;;
  xbitmaps* )
    cp $APP_CONFIG/data-config.sh $packagedir/config.sh
  ;;
  zlib* )
    cp $APP_CONFIG/zlib-config.sh $packagedir/config.sh
  ;;
  esac
fi

if [ -d $packagedir ]; then
  compile
fi
done

# List Xorg Application
for package in $(grep -v '^#' $APP_LISTING/app-7.md5 | awk '{print $2}')
do
packagedir=${package%.tar.*}
typearchive=${package#*.tar.*}
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $packagedir ]; then
  mkdir -p $packagedir
  cp $APP_CONFIG/xorg-app-config.sh $packagedir/config.sh
  case $packagedir in 
  xcursor-themes* )
    cp -r $APP_CONFIG/data-config.sh $packagedir/config.sh
  ;;
  esac  
  cp $APP_MAKEFILE/proto-Makefile.am $packagedir/Makefile.am
fi
      
if [ -d $packagedir ]; then
compile
fi
done

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

# List Xorg Input Drivers
for package in $(grep -v '^#' $APP_LISTING/XorgInputDrivers.md5 | awk '{print $2}')
do
packagedir=${package%.tar.*}
typearchive=${package#*.tar.*}
export ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE="$typearchive"
if [ ! -d $packagedir ]; then
  mkdir -p $packagedir
  if [ -f $package ]; then
    mv -v $package $packagedir
  fi
  cp $APP_CONFIG/freedesktop_soft-config.sh $packagedir/config.sh
  cp $APP_MAKEFILE/proto-Makefile.am $packagedir/Makefile.am
  case $packagedir in
  xf86* )
    cp -r $APP_CONFIG/freedesktop_x86-input-config.sh $packagedir/config.sh
  ;;
  Linux-PAM* )
    cp -r $APP_CONFIG/Linux-PAM-config.sh $packagedir/config.sh
  ;;
  systemd* )
    cp -r $APP_CONFIG/systemd-config.sh $packagedir/config.sh
    cp -r $APP_MAKEFILE/meson-Makefile.am $packagedir/Makefile.am
  ;;
  libtirpc* )
    cp -r $APP_CONFIG/libtirpc-config.sh $packagedir/config.sh
  ;;
  mtdev* )
    cp -r $APP_CONFIG/mtdev-config.sh $packagedir/config.sh
  ;;
  libinput* )
    cp -r $APP_CONFIG/libinput-config.sh $packagedir/config.sh
    cp -r $APP_MAKEFILE/meson-Makefile.am $packagedir/Makefile.am
  ;;
  esac
fi

if [ -d $packagedir ]; then
compile
fi
done
