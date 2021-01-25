#!/bin/bash
app="pcre-8.44"
arch="tar.bz2"

sed 's/@alsy.app.name/'$app'/g' "Makefile.am" > "Makefile"

   if [ ! -f $app.$arch ]; then
     filedwnld="ftp://ftp.pcre.org/pub/pcre/$app.$arch"
     wget $filedwnld -O $app.$arch
   fi
   
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
  cd ../build
  if [ $? -eq 0 ]; then 
    pushd $app
    ./configure $XORG_CONFIG                              \
                --docdir=$XORG_PREFIX/share/doc/pcre-8.44 \
                --enable-unicode-properties       \
                --enable-pcre16                   \
                --enable-pcre32                   \
                --enable-pcregrep-libz            \
                --enable-pcre2grep-libbz2         \
                --enable-pcretest-libreadline     \
                --disable-static && popd
  fi
fi