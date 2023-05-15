#!/bin/bash

app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tar.${ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE}"
sapp="$app-$version"

if [ ! -f $app-$version.$arch ]; then  
  filedwnld="https://download.savannah.gnu.org/releases/freetype/$app-$version.$arch"
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

mkdir -p ../build/$app &&
tar -xf "$app"."$arch" -C ../build/$app
if [ $? -eq 0 ]; then  
  cd ../build
  if [ $? -eq 0 ]; then    
    pushd $app    
    cmake -DCMAKE_INSTALL_PREFIX=$XORG_PREFIX  \
            -DCMAKE_BUILD_TYPE=Release \
            -DBUILD_SHARED_LIBS=ON \
            -DFT_DISABLE_ZLIB=TRUE \
            -DFT_DISABLE_BZIP2=TRUE \
            -DFT_DISABLE_PNG=TRUE \
            -DFT_DISABLE_HARFBUZZ=TRUE \
            -DCMAKE_INSTALL_LIBDIR=lib \
            $sapp
    exitcode="$(echo $?)"
    exit $exitcode
    
    popd
# !!! first install without harfbuzz then when it is installed reinstall freetype !!!          
## This is the first installation of freetype !!!    
  fi
fi
