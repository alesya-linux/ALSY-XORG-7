#!/bin/bash

app="${PWD##*/}"
# And this is the second installation of freetype using harfbuzz !!!
app="$(echo $app | sed 's/freetype2/freetype/g')"
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
    pushd $app &&    
    if [[ -f $sapp/configure.ac && ! -x $sapp/configure ]]; then
      cd $sapp   &&
      libtoolize && 
      autoreconf -fiv &&
      cd ..
    fi &&
    if [ -x $sapp/configure ]; then 
      python3 -m pip install -U pip &&
      python3 -m pip install -U meson &&
      python3 -m pip install -U docwriter &&
      ./$sapp/configure $XORG_CONFIG        \
                        --with-harfbuzz=yes \
                        --with-bzip2=yes    \
                        --with-png=yes      \
                        --with-zlib=yes     \
                        --enable-freetype-config && popd
# !!! first install without harfbuzz then when it is installed reinstall freetype !!!    
# And this is the second installation of freetype using harfbuzz !!!
    fi 
  fi
fi
