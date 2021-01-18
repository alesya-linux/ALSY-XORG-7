#!/bin/bash

app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tar.${ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE}"
sapp="$app-$version"

if [ ! -f $app-$version.$arch ]; then  
  filedwnld="https://github.com/systemd/systemd/archive/v$version/$app-$version.$arch"  
  wget $filedwnld -O "$app-$version".$arch --no-check-certificate
  if [ $? -ne 0 ]; then 
    filedwnld="https://github.com/systemd/systemd/archive/v247/systemd-247.tar.gz"
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
       filename="systemd-247-upstream_fixes-1.patch"
       if [ -f ../../../../APP_PATCHES/$filename ]; then
         cp -a ../../../../APP_PATCHES/$filename $filename  
       fi
       
       if [ ! -f $filename ]; then
         filedwnld="http://www.linuxfromscratch.org/patches/blfs/svn/$filename"
         wget $filedwnld 
         if [ $? -ne 0 ]; then
           exit 1
         fi
       fi
       
       if [ $? -eq 0 ]; then
         cd $sapp && patch -Np1 -i ../$filename
         if [ $? -eq 0 ]; then           
           sed -i 's/GROUP="render", //' rules.d/50-udev-default.rules.in &&
           meson --prefix=$XORG_PREFIX                        \
                  -Dblkid=true                                \
                  -Dbuildtype=release                         \
                  -Ddefault-dnssec=no                         \
                  -Dfirstboot=false                           \
                  -Dinstall-tests=false                       \
                  -Dldconfig=false                            \
                  -Dman=auto                                  \
                  -Drootprefix=                               \
                  -Drootlibdir=$XORG_PREFIX/lib               \
                  -Dsplit-usr=true                            \
                  -Dsysusers=false                            \
                  -Drpmmacrosdir=no                           \
                  -Db_lto=false                               \
                  -Dhomed=false                               \
                  -Duserdb=false                              \
                  -Dmode=release                              \
                  -Dpamconfdir=$XORG_PREFIX/etc/pam.d         \
                  -Ddocdir=$XORG_PREFIX/share/doc/systemd-247 \
                  ..
         fi
       fi
    fi 
    popd
  fi
else
  rm -rf "$app"."$arch"
fi 
