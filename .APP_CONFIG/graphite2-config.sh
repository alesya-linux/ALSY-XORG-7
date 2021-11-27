#!/bin/bash

app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tgz"
sapp="$app-$version"

if [ ! -f $app-$version.$arch ]; then  
  filedwnld=" https://github.com/silnrsi/graphite/releases/download/$version/$app-$version.$arch"
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

    sed -i '/cmptest/d' $app/tests/CMakeLists.txt &&
    cmake -DCMAKE_INSTALL_PREFIX=$XORG_PREFIX $app

    popd
  fi
fi
