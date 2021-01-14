.PHONY: all install 
.IGNORE: clean
XORG_PREFIX="/usr/X11R7"
all:
	echo "successfull make all"
install:
	# XORG LIB, Proto and Util-macros
	cd util-macros-1.19.2        && make install
	cd xorgproto-2020.1          && make install
	cd libXau-1.0.9              && make install
	cd libXdmcp-1.1.3            && make install
	cd xcb-proto-1.14.1          && make install
	cd libxcb-1.14               && make install
	cd xtrans-1.4.0              && make install
	cd libX11-1.7.0              && make install
	cd libXext-1.3.4             && make install
	cd libFS-1.0.8               && make install
	cd libICE-1.0.10             && make install
	cd libSM-1.2.3               && make install
	cd libXScrnSaver-1.2.3       && make install
	cd libXt-1.2.0               && make install
	cd libXmu-1.1.3              && make install
	cd libXpm-3.5.13             && make install
	cd libXaw-1.0.13             && make install
	cd libXfixes-5.0.3           && make install
	cd libXcomposite-0.4.5       && make install
	cd libXrender-0.9.10         && make install
	cd libXcursor-1.2.0          && make install
	cd libXdamage-1.1.5          && make install
	cd libfontenc-1.1.4          && make install
	cd freetype-2.10.4           && make install
	cd util-linux-2.36           && make install
	cd fontconfig-2.13.1         && make install
	cd harfbuzz-2.7.4            && make install
	cd libXfont2-2.0.4           && make install
	cd libXft-2.3.3              && make install
	cd libXi-1.7.10              && make install
	cd libXinerama-1.1.4         && make install
	cd libXrandr-1.5.2           && make install
	cd libXres-1.2.0             && make install
	cd libXtst-1.2.3             && make install
	cd libXv-1.0.11              && make install
	cd libXvMC-1.0.12            && make install
	cd libXxf86dga-1.1.5         && make install
	cd libXxf86vm-1.1.4          && make install
	cd libdmx-1.1.4              && make install
	cd libpciaccess-0.16         && make install
	cd libxkbfile-1.1.0          && make install
	cd libxshmfence-1.3          && make install
	cd xcb-util-0.4.0            && make install
	cd xcb-util-image-0.4.0      && make install
	cd xcb-util-keysyms-0.4.0    && make install
	cd xcb-util-renderutil-0.3.9 && make install
	cd xcb-util-wm-0.4.1         && make install
	cd xcb-util-cursor-0.1.3     && make install
	cd xbitmaps-1.1.2            && make install
	cd glproto-1.4.17            && make install
	cd libdrm-2.4.104            && make install
	cd mesa-20.3.2               && make install
	cd libepoxy-1.5.5            && make install
	cd zlib-1.2.11               && make install
	cd libpng-1.6.37             && make install
	cd nettle-3.7                && make install
	# XORG-Application 
	cd iceauth-1.0.8                 && make install
	cd luit-1.1.1                    && make install
	cd mkfontscale-1.2.1             && make install
	cd sessreg-1.1.2                 && make install
	cd setxkbmap-1.3.2               && make install
	cd smproxy-1.0.6                 && make install
	cd x11perf-1.6.1                 && make install
	cd xauth-1.1                     && make install
	cd xbacklight-1.2.3              && make install
	cd xcmsdb-1.0.5                  && make install
	cd xcursorgen-1.0.7              && make install
	cd xdpyinfo-1.3.2                && make install
	cd xdriinfo-1.0.6                && make install
	cd xev-1.2.4                     && make install
	cd xgamma-1.0.6                  && make install
	cd xhost-1.0.8                   && make install
	cd xinput-1.6.3                  && make install
	cd xkbcomp-1.4.4                 && make install
	cd xkbevd-1.1.4                  && make install
	cd xkbutils-1.0.4                && make install
	cd xkill-1.0.5                   && make install
	cd xlsatoms-1.1.3                && make install
	cd xlsclients-1.1.4              && make install
	cd xmessage-1.0.5                && make install
	cd xmodmap-1.0.10                && make install
	cd xpr-1.0.5                     && make install
	cd xprop-1.2.5                   && make install
	cd xrandr-1.5.1                  && make install
	cd xrdb-1.2.0                    && make install
	cd xrefresh-1.0.6                && make install
	cd xset-1.2.4                    && make install
	cd xsetroot-1.1.2                && make install
	cd xvinfo-1.1.4                  && make install
	cd xwd-1.0.7                     && make install
	cd xwininfo-1.1.5                && make install
	cd xwud-1.0.5                    && make install
	cd xcursor-themes-1.0.6          && make install
	# XORG-Font
	cd font-util-1.3.2               && make install
	cd encodings-1.0.5               && make install
	cd font-alias-1.0.4              && make install
	cd font-adobe-utopia-type1-1.0.4 && make install
	cd font-bh-ttf-1.0.3             && make install
	cd font-bh-type1-1.0.3           && make install
	cd font-ibm-type1-1.0.3          && make install
	cd font-misc-ethiopic-1.0.4      && make install
	cd font-xfree86-type1-1.0.4      && make install
	cd xkeyboard-config-2.31         && make install
	cd pixman-0.40.0                 && make install
	cd libunwind-1.5.0               && make install
	cd xorg-server-1.20.10           && make install
	./install.sh ${PREFIX} ${XORG_PREFIX}
	mkdir -p ${PREFIX}/share	
	mkdir -p ${PREFIX}/usr/share/
	mkdir -p ${PREFIX}/var/lib/
	ln -s ${PREFIX}/share       ${PREFIX}/share/X11	
	ln -s ${PREFIX}             ${PREFIX}/X11R7
	ln -s ${PREFIX}             ${PREFIX}/X11
	ln -s ${PREFIX}/lib/xkb     ${PREFIX}/var/lib/xkb 
clean:
	rm -rfd ${PREFIX}
