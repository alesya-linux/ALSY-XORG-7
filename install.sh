# Choose your installation prefix, and set the XORG_PREFIX variable with the following command:
export XORG_PREFIX="$1"
export XORG_VIRTUAL="$2"

# Throughout these instructions, you will use the following configure switches 
# for all of the packages. 

# Create the XORG_CONFIG variable to use for this parameter substitution:
export XORG_CONFIG="--prefix=$XORG_VIRTUAL \
                    --sysconfdir=/etc      \
                    --localstatedir=/var   \
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
XORG_CONFIG="--prefix=\$XORG_PREFIX  \
             --sysconfdir=/etc       \
             --localstatedir=/var    \
             --disable-static"
export XORG_PREFIX XORG_CONFIG
PATH="$XORG_VIRTUAL/bin:$PATH"
PKG_CONFIG_PATH="$XORG_VIRTUAL/lib/pkgconfig:$PKG_CONFIG_PATH"   
PKG_CONFIG_PATH="$XORG_VIRTUAL/share/pkgconfig:$PKG_CONFIG_PATH" 
LIBRARY_PATH="$XORG_VIRTUAL/lib:$LIBRARY_PATH"
C_INCLUDE_PATH="$XORG_VIRTUAL/include:$C_INCLUDE_PATH"
CPLUS_INCLUDE_PATH="$XORG_VIRTUAL/include:$CPLUS_INCLUDE_PATH"
ACLOCAL="aclocal -I $XORG_VIRTUAL/share/aclocal"
export PATH PKG_CONFIG_PATH ACLOCAL LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH
EOF
chmod 744 $XORG_PREFIX/etc/profile.d/xorg.sh
 
