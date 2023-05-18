#!/bin/bash
sapp="gettext-0.21"
app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tar.gz"

sed 's/@alsy.app.name/'$sapp'/g' "Makefile.am" > "Makefile"
if [ ! -f $sapp.$arch ]; then
  wget https://ftp.gnu.org/pub/gnu/gettext/$sapp.$arch -O $sapp.$arch
fi

if [ -d ../build/$sapp ]; then
 rm -rd ../build/$sapp
 if [ $? -eq 0 ]; then
   echo "clean .. [ ok ]"
 else
   exit 1
 fi
fi

mkdir -p ../build &&
tar -xf "$sapp"."$arch" -C ../build
if [ $? -eq 0 ]; then  
  cd ../build/$sapp
  if [ $? -eq 0 ]; then    
    ./configure $XORG_CONFIG \
    --without-libxml2        \
    --without-libxml2-prefix
  fi
fi
