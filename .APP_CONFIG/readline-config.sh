#!/bin/bash

app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tar.${ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE}"
sapp="$app-$version"

if [ ! -f $app-$version.$arch ]; then  
  filedwnld="https://ftp.gnu.org/gnu/$app/$app-$version.$arch"
  wget $filedwnld -O $app-$version.$arch --no-check-certificate
fi

app=$sapp

if [ -d ../build/$app ]; then
  rm -rfd ../build/$app
  echo -n "clean....."
  if [ -d ../build ]; then
    echo "[ fail ]"
  else
    echo "[ ok ]"
  fi
fi

sed 's\@alsy.app.name\'$app'\g' Makefile.am > Makefile &&

mkdir -p ../build &&
tar -xf $app.$arch -C ../build &&
cd ../build/$app &&
./configure $XORG_CONFIG \
            --with-curses \
            --docdir=$XORG_PREFIX/share/doc/$sapp