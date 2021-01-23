#!/bin/bash
version="3.1"
app="gperf"
arch="tar.gz"

sed 's/@alsy.app.name/'$app-$version'/g' "Makefile.am" > "Makefile"

if [ ! -f $app-$version.$arch ]; then
  filedwnld="https://ftp.gnu.org/gnu/$app/$app-$version.$arch"
  wget $filedwnld -O $app-$version.$arch
fi
sapp=$app-$version   
if [ -d ../build/$sapp ]; then
 rm -rfd ../build/$sapp
 if [ $? -eq 0 ]; then
   echo "delete..[ ok ]"
 else
   exit 1
 fi
fi

mkdir -p ../build &&
tar -xf $sapp.$arch -C ../build
if [ $? -eq 0 ]; then
  cd ../build
  if [ $? -eq 0 ]; then 
    pushd $sapp
    ./configure $XORG_CONFIG \
                --enable-shared && popd
  fi
fi