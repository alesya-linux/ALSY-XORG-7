#!/bin/bash

app="ncurses-6.2"
arh="tar.gz"
sapp="ncurses-6.2"

if [ -d ../build/$sapp ]; then
  rm -rfd ../build/$sapp
  echo -n "clean....."
  if [ -d ../build ]; then
    echo "[ fail ]"
  else
    echo "[ ok ]"
  fi
fi
# https://github.com/mirror/ncurses/archive/v6.2.tar.gz
sed 's\@alsy.app.name\'$app'\g' Makefile.am > Makefile &&

mkdir -p ../build &&
cp $app"."$arh ../build &&
cd    ../build &&
tar -xf $app"."$arh &&
cd $app &&
./configure $XORG_CONFIG \
            --with-termlib \
            --without-debug \
            --without-ada   \
            --without-normal \
            --enable-widec \
            --with-pkg-config \
            --with-pkg-config-libdir=$XORG_PREFIX/lib/pkgconfig \
            --with-shared