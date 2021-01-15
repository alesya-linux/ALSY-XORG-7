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
XORG_PREFIX="$XORG_VIRTUAL"
XORG_CONFIG="--prefix=\$XORG_PREFIX               \
             --sysconfdir=\$XORG_PREFIX/etc       \
             --localstatedir=\$XORG_PREFIX/var    \
             --disable-static"
export XORG_PREFIX XORG_CONFIG
PATH="$XORG_PREFIX/bin:$PATH"
PKG_CONFIG_PATH="$XORG_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"   
PKG_CONFIG_PATH="$XORG_PREFIX/share/pkgconfig:$PKG_CONFIG_PATH" 
LIBRARY_PATH="$XORG_PREFIX/lib:$LIBRARY_PATH"
C_INCLUDE_PATH="$XORG_PREFIX/include:$C_INCLUDE_PATH"
CPLUS_INCLUDE_PATH="$XORG_PREFIX/include:$CPLUS_INCLUDE_PATH"
ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"
export PATH PKG_CONFIG_PATH ACLOCAL LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH
EOF
chmod 744 $XORG_PREFIX/etc/profile.d/xorg.sh
echo "$XORG_PREFIX/lib" >> /etc/ld.so.conf
cp -a /etc/ld.so.conf $XORG_PREFIX/etc/ld.so.conf
sed "s@/usr/X11R6@$XORG_PREFIX@g" -i /etc/man_db.conf
cp -a /etc/man_db.conf $XORG_PREFIX/etc/man_db.conf
# Some applications look for shared files in /usr/share/X11. Create a symbolic link to the proper location as the root user:
mkdir -p $XORG_PREFIX/usr/share
ln -svf $XORG_PREFIX/share/X11 $XORG_PREFIX/usr/share/X11
# If building KDE, some cmake files look for Xorg in places other than $XORG_PREFIX. Allow cmake to find Xorg with:
ln -svf $XORG_PREFIX $XORG_PREFIX/usr/X11R6
ln -svf $XORG_PREFIX $XORG_PREFIX/$XORG_VIRTUAL