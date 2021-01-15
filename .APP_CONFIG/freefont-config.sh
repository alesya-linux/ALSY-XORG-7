#!/bin/bash

app="${PWD##*/}"
version="${app##*-}"
app="${app%-*}"
arch="tar.${ALSY_XORG_APP_CONFIG_ARCHIVE_TYPE}"
sapp="$app-$version"

if [ ! -f $app-$version.$arch ]; then  
  filedwnld="https://mirrors.tripadvisor.com/gnu/freefont/$app-$version.$arch"
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
      ./$sapp/configure $XORG_CONFIG 
    else      
      cd ../../$app
      rpart="${app##*-}"
      lpart="${app%%-*}"
      ltype="${app%-*}"
      lcan_install=" "
      case $ltype in
      freefont-ttf* )
       lcan_install="X"
      ;;
      freefont-otf* )
       lcan_install="X"
      ;;
      esac
      if [ "$lcan_install" == "X" ]; then
       export package_site="$lpart-$rpart"
       export package_type="${ltype##*-}"
       export package_xtype="$(echo $package_type | tr '[:lower:]' '[:upper:]')"
       chmod u+rwx install.sh
       ./install.sh $app $package_site
       sed -i 's/@alsy.app.name/'$app'/g' "Makefile.in"
       sed -i 's/@alsy.package.name/'$package_site'/g' "Makefile.in"
       sed -i 's/@alsy.package.xtype/'$package_xtype'/g' "Makefile.in" > "Makefile"
       sed 's/@alsy.package.type/'$package_type'/g' "Makefile.in" > "Makefile"
      else
       exit 1
      fi
    fi && popd
  fi
fi
