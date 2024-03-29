#!/bin/bash
app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tar.${ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE}"
sapp="$app-$version"
verdwnld="R_2_2_10"

if [ ! -f $sapp.$arch ]; then
  wget https://github.com/libexpat/libexpat/releases/download/$verdwnld/$sapp.$arch -O $sapp.$arch --no-check-certificate
fi

sed 's/@app.alsy.name/'$sapp'/g' "Makefile.am" > "Makefile"

if [ -d ../build/$sapp ]; then
 rm -rfd ../build/$sapp
 if [ $? -eq 0 ]; then
   echo "delete..[ ok ]"
 else
   exit 1
 fi
fi

mkdir -p ../build &&
tar -xf "$sapp"."$arch" -C ../build || rm -f "$sapp"."$arch"
if [ $? -eq 0 ]; then
  cd ../build/$sapp
  if [ $? -eq 0 ]; then         
    ./configure $XORG_CONFIG --docdir=$XORG_PREFIX/share/doc/$sapp
  fi
fi
