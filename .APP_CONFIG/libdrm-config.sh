#!/bin/bash

app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tar.${ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE}"
sapp="$app-$version"

if [ ! -f $app-$version.$arch ]; then  
  filedwnld="https://dri.freedesktop.org/libdrm/$app-$version.$arch"
  wget $filedwnld -O "$app-$version".$arch --no-check-certificate
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

#python -m pip install -U ninja

mkdir -p ../build/$app &&
tar -xf "$app"."$arch" -C ../build/$app
if [ $? -eq 0 ]; then  
  cd ../build
  if [ $? -eq 0 ]; then    
    pushd $app &&    
    if [[ -f $sapp/configure.ac && ! -x $sapp/configure ]]; then
      cd $sapp   &&
      libtoolize && 
      autoreconf -fiv &&
      cd ..
    fi &&
    if [ -x $sapp/configure ]; then    
      ./$sapp/configure $XORG_CONFIG && popd
    elif [ -f $sapp/meson.build ]; then
      python3 -m pip install -U pip &&
      python3 -m pip install -U meson &&
      python3 -m pip install -U ninja &&
      cd $sapp &&
      meson setup \
      --prefix=$XORG_PREFIX \
      --buildtype=release   \
      -Dudev=true           \
      -Dvalgrind=disabled   \
      build
    fi 
  fi
fi
