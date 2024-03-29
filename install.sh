LIBRARY_PATH="/usr/libexec/gcc/x86_64-alesya-linux/"
CPLUS_INCLUDE_PATH="/include/c++/9.2.0/"
C_INCLUDE_PATH="/lib/gcc/x86_64-alesya-linux/9.2.0/include/"

# Choose your installation prefix, and set the XORG_PREFIX variable with the following command:
export XORG_PREFIX="$1"
export XORG_VIRTUAL="$2"

# Throughout these instructions, you will use the following configure switches 
# for all of the packages. 

# Create the XORG_CONFIG variable to use for this parameter substitution:
export XORG_CONFIG="--prefix=$XORG_PREFIX              \
                    --sysconfdir=$XORG_PREFIX/etc      \
                    --localstatedir=$XORG_PREFIX/var   \
                    --disable-static"

if [ "$XORG_PREFIX" == "" ]; then
 echo "Error: prefix not filled in !" 
 exit 1
fi

if [ "$XORG_VIRTUAL" == "" ]; then
 echo "Error: prefix not filled in !" 
 exit 1
fi

# Create an /etc/profile.d/xorg.sh configuration file containing these variables as the root user:
mkdir -p $XORG_PREFIX/etc/profile.d/

cat > $XORG_PREFIX/etc/profile.d/xorg.sh << EOF
ALSY_XORG="1.0.9"
XORG_PREFIX="$XORG_VIRTUAL"
XORG_CONFIG="\
--prefix=\$XORG_PREFIX\
--sysconfdir=\$XORG_PREFIX/etc\
--localstatedir=\$XORG_PREFIX/var\
--disable-static"
export XORG_PREFIX XORG_CONFIG ALSY_XORG
PATH="$XORG_PREFIX/bin:\$PATH"
PKG_CONFIG_PATH="\
/lib/pkgconfig:\
/lib32/pkgconfig:\
/lib64/pkgconfig:\
/usr/lib/pkgconfig:\
/usr/lib64/pkgconfig:\
/usr/local/lib/pkgconfig:\
/usr/local/lib64/pkgconfig:\
/share/pkgconfig:$XORG_PREFIX/lib/pkgconfig\
"
LIBRARY_PATH="$XORG_PREFIX/lib:\$LIBRARY_PATH"
C_INCLUDE_PATH="$XORG_PREFIX/include:\$C_INCLUDE_PATH"
CPLUS_INCLUDE_PATH="$XORG_PREFIX/include:\$CPLUS_INCLUDE_PATH"
ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"
export PATH PKG_CONFIG_PATH ACLOCAL LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH
EOF
chmod 755 $XORG_PREFIX/etc/profile.d/xorg.sh
echo "$XORG_PREFIX/lib" >> /etc/ld.so.conf
cp -a /etc/ld.so.conf $XORG_PREFIX/etc/ld.so.conf
if [ -f /etc/man_db.conf ]; then
  sed "s@/usr/X11R6@$XORG_PREFIX@g" -i /etc/man_db.conf
  cp -a /etc/man_db.conf $XORG_PREFIX/etc/man_db.conf
fi
# Some applications look for shared files in /usr/share/X11. Create a symbolic link to the proper location as the root user:
mkdir -p $XORG_PREFIX/usr/share
ln -svf $XORG_PREFIX/share/X11 $XORG_PREFIX/usr/share/X11
# If building KDE, some cmake files look for Xorg in places other than $XORG_PREFIX. Allow cmake to find Xorg with:
ln -svf $XORG_PREFIX $XORG_PREFIX/usr/X11R6
ln -svf $XORG_PREFIX $XORG_PREFIX/$XORG_VIRTUAL  
if [ ! -f $XORG_PREFIX/ALSY-XORG-7 ]; then
 ln -svf $XORG_PREFIX $XORG_PREFIX/ALSY-XORG-7
fi
