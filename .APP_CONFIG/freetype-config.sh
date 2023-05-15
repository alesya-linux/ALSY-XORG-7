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
tar -xf "$app"."$arch" --strip-components=2 -C ../build/$app
if [ $? -eq 0 ]; then  
  cd ../build
  if [ $? -eq 0 ]; then    
    pushd $app &&    
  #  if [[ -f $sapp/configure.ac && ! -x $sapp/configure ]]; then
  #    cd $sapp   &&
  #    libtoolize && 
  #    autoreconf -fiv &&
  #    cd ..
 #   fi &&
    if [ -x $sapp/configure ]; then    
      sed -ri "s:.*(AUX_MODULES.*valid):\1:" $sapp/modules.cfg &&
      sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
      -i $sapp/include/freetype/config/ftoption.h  &&
      ./$sapp/configure $XORG_CONFIG \
      --without-harfbuzz \
      --enable-freetype-config && popd    
# !!! first install without harfbuzz then when it is installed reinstall freetype !!!          
## This is the first installation of freetype !!!
    fi 
  fi
fi
