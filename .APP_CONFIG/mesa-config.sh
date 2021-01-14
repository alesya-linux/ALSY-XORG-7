#!/bin/bash
as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

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
GALLIUM_DRV="i915,nouveau"
DRI_DRIVERS="i965,nouveau"
      meson --prefix=$XORG_PREFIX          \
            -Dplatforms=x11                \
            -Dllvm=disabled                \
            -Dshared-llvm=disabled         \
            -Dgallium-nine=false           \
            -Dosmesa=none                  \
            -Dvulkan-drivers=              \
            -Dglx=dri                      \
            -Dgallium-drivers=$GALLIUM_DRV \
            -Ddri-drivers=$DRI_DRIVERS     \
            -Dshared-swr=false             \
            -Dvalgrind=disabled            \
            -Dlibunwind=disabled $sapp         
#      -Dbuildtype=release            \      
#      $sapp
    fi 
  fi
fi
