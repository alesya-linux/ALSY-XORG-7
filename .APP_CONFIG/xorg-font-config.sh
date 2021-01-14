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
  filedwnld="ftp://ftp.x.org/pub/individual/font/$app-$version.$arch"
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
      case $app in
      luit-[0-9]* )
         sed -i -e "/D_XOPEN/s/5/6/" $sapp/configure
       ;;
      esac
      ./$sapp/configure $XORG_CONFIG && popd
    fi 
  fi
fi
