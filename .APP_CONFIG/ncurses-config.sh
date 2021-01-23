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

sed 's\@alsy.app.name\'$app'\g' Makefile.am > Makefile &&

mkdir -p ../build &&
cp $app"."$arh ../build &&
cd    ../build &&
tar -xf $app"."$arh &&
cd $app &&
./configure $XORG_CONFIG                                        \
            --with-termlib                                      \
            --with-pcre2                                        \
            --with-pkg-config                                   \
            --with-pkg-config-libdir=$XORG_PREFIX/lib/pkgconfig \
            --with-shared
