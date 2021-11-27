#!/bin/bash

#app="pcre2"
#version="10.36"
app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tar.bz2"

if [ ! -f $app-$version.$arch ]; then
  filedwnld="https://github.com/PhilipHazel/pcre2/releases/download/$app-$version/$app-$version.$arch"
  wget $filedwnld -O $app-$version.$arch
fi


app="$app-$version"
sed 's/@alsy.app.name/'$app'/g' "Makefile.am" > "Makefile"

if [ -d ../build/$app ]; then
 rm -rfd ../build/$app
 if [ $? -eq 0 ]; then
   echo "clean .. [ ok ]"
 else
   exit 1
 fi
fi

sapp="PCRE2-$version"
mkdir -p ../build &&
tar -xf "$app"."$arch" -C ../build
if [ $? -eq 0 ]; then  
  cd ../build
  if [ $? -eq 0 ]; then    
    pushd $app &&
    if [[ -f configure.ac && ! -x configure ]]; then
      libtoolize &&
      autoreconf -fiv
    fi &&
    if [ -x configure ]; then      
      ./configure --prefix=$XORG_PREFIX                  \
                  --docdir=$XORG_PREFIX/share/doc/$app   \
                  --enable-unicode                       \
                  --enable-jit                           \
                  --enable-pcre2-16                      \
                  --enable-pcre2-32                      \
                  --enable-pcre2grep-libz                \
                  --enable-pcre2grep-libbz2              \
                  --enable-pcre2test-libreadline         \
                  --disable-static && popd
    elif [ -f meson.build ]; then
      meson  --prefix=/usr/src/tools/$sapp          \
             -Dbuildtype=release                    \
             .. && popd
    else         
      CFLAGS="-g -O2 $([ $(uname -m) = x86_64 ] && echo -fPIC)" \
      cmake -DCMAKE_INSTALL_PREFIX=/usr/src/tools/$sapp \
            -DCMAKE_BUILD_TYPE=Release \
            -DBUILD_SHARED_LIBS=ON && popd
    fi    
  fi
else
  if [ -f "$app"."$arch" ]; then
    rm -f "$app"."$arch"
  fi
fi
