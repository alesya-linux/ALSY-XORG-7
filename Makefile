.PHONY: all install 
.IGNORE: clean
XORG_PREFIX="/usr/X11R7"
BUILD="build"
all:
	mkdir -p /usr/src/tools/.install
	mv -t /usr/src/tools/.install ${PREFIX}
install:
	mv -t /usr/src/tools /usr/src/tools/.install/*
	./install.sh ${PREFIX} ${XORG_PREFIX}
clean:
	rm -rfd ${BUILD}
