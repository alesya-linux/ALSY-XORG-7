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

if [ -d ../build/$sapp ]; then
  rm -rfd ../build/$sapp
  echo -n "clean....."
  if [ -d ../build/$sapp ]; then
    echo "[ fail ]"
  else
    echo "[ ok ]"
  fi
fi
# https://github.com/mirror/ncurses/archive/v6.2.tar.gz
sed 's\@alsy.app.name\'$app'\g' Makefile.am > Makefile &&

mkdir -p ../build &&
tar -xf $app.$arch -C ../build &&
cd ../build/$app &&

mkdir build &&
pushd build
  ../configure
  make -C include
  make -C progs tic
popd

./configure --prefix=$XORG_PREFIX           \
            --host=x86_64-alesya-linux      \
            --build=$(./config.guess)       \
            --mandir=$XORG_PREFIX/share/man \
            --with-manpage-format=normal    \
            --enable-widec                  \
            --with-shared                   \            
            --with-pkg-config               \
            --with-pkg-config-libdir=$XORG_PREFIX/lib/pkgconfig  
            
            
            
