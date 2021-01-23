#!/bin/bash

app="pcre2"
version="10.36"
arch="tar.bz2"

if [ ! -f $app-$version.$arch ]; then
  filedwnld="ftp://ftp.pcre.org/pub/pcre/$app-$version.$arch"
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

# check libtirpc
if [ "$(pkg-config --modversion libtirpc | wc -w)" == "1" ]; then
  echo "check libtirpc.......$(pkg-config --modversion libtirpc)...[ok]"
else
  echo "Error: libtirpc not found!"
  exit 1
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
      ./configure $XORG_CONFIG \
                  --docdir=/usr/src/tools/share/doc/$app \
                  --enable-unicode                       \
                  --enable-jit                           \
                  --enable-pcre2-16                      \
                  --enable-pcre2-32                      \
                  --enable-pcre2grep-libz && popd
#                  --enable-pcre2grep-libbz2              \
#                  --enable-pcre2test-libreadline         \
#                  --disable-static && popd
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