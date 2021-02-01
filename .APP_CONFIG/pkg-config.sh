#!/bin/bash
app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tar.${ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE}"
sapp="$app-$version"

if [ ! -f $app-$version.$arch ]; then  
  filedwnld="https://pkg-config.freedesktop.org/releases/$app-$version.$arch"
  wget $filedwnld -O "$app-$version".$arch --no-check-certificate
fi
app="$app-$version"
sed 's/@alsy.app.name/'$app'/g' "Makefile.am" > "Makefile"

if [ -d ../build/$app ]; then
 rm -rfd ../build/$app
 if [ $? -eq 0 ]; then
   echo "delete..[ ok ]"
 else
   exit 1
 fi
fi

mkdir -p ../build &&
tar -xf "$app"."$arch" -C ../build
if [ $? -eq 0 ]; then
  cd ../build/$app
  if [ $? -eq 0 ]; then
    ./configure --prefix=$XORG_PREFIX \
                --disable-static      \
                --with-internal-glib
  fi
fi