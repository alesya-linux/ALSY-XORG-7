#!/bin/bash

app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tar.${ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE}"
sapp="$app-$version"

if [ ! -f $app-$version.$arch ]; then  
  filedwnld="ftp://ftp.freedesktop.org/pub/mesa/mesa-$version.tar.xz"
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
      ./$sapp/configure $XORG_CONFIG && popd
    else
GALLIUM_DRV="i915,iris,nouveau,svga,virgl"
DRI_DRIVERS="i965,nouveau"
      filename="mesa-20.3.3-add_xdemos-1.patch"
      filedwnld="http://www.linuxfromscratch.org/patches/blfs/svn/$filemaname"
      if [ -f ../../../../APP_PATCHES/$filename ]; then
        cp -a ../../../../APP_PATCHES/$filename $filename  
      fi
      if [ ! -f $filename ]; then         
        wget $filedwnld 
        if [ $? -ne 0 ]; then
          exit 1
        fi
      fi
      cd $sapp &&
      patch -Np1 -i ../mesa-20.3.3-add_xdemos-1.patch &&
      meson --prefix=$XORG_PREFIX          \
            -Dplatforms=x11                \
            -Dllvm=disabled                \
            -Dshared-llvm=disabled         \
            -Dgallium-nine=false           \
            -Dosmesa=false                 \
            -Dvulkan-drivers=              \
            -Dglx=dri                      \
            -Dgallium-drivers=$GALLIUM_DRV \
            -Ddri-drivers=$DRI_DRIVERS     \
            -Dshared-swr=false             \
            -Dvalgrind=disabled            \
            -Dlibunwind=disabled ..         
#      -Dbuildtype=release            \      
#      $sapp
    fi 
  fi
fi
