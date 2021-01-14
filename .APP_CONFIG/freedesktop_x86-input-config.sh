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
  filedwnld="ftp://ftp.x.org/pub/individual/driver/$app-$version.$arch"  
  wget $filedwnld -O "$app-$version".$arch --no-check-certificate
  if [ $? -ne 0 ]; then 
    filedwnld=" https://github.com/linuxwacom/$app/releases/download/$app-$version/$app-$version.$arch"
    wget $filedwnld -O "$app-$version".$arch --no-check-certificate
  fi
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
    fi 
  fi
else
  rm -rf "$app"."$arch"
fi 