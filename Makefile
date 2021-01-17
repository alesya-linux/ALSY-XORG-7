.PHONY: all install 
.IGNORE: clean
XORG_PREFIX="/usr/X11R7"
BUILD="build"
PREFIX="/usr/src/tools/XORG-7"
all:
	echo /usr/src/tools/XORG-7
	mkdir -p /usr/src/tools/.install
	mv -t /usr/src/tools/.install /usr/src/tools/XORG-7
install:
	mv -t /usr/src/tools /usr/src/tools/.install/*
	./install.sh /usr/src/tools/XORG-7 ${XORG_PREFIX}
clean:
	rm -rfd ${BUILD}
