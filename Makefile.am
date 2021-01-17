#!/bin/make
.PHONY: all install 
.IGNORE: clean
XORG_PREFIX="/usr/X11R7"
BUILD="build"
PREFIX_X=/usr/src/tools/XORG-7
CURR_DIR=${CURRDIR}
all:
	mkdir -p ${PWD}/.install
install:
	pushd ${CURR_DIR} && popd
	mv -t .install ${PREFIX_X}
	mkdir -p ${PREFIX_X}
	cd ${PREFIX_X}/.. && mv -t . ${CURR_DIR}/.install/*
	./install.sh ${PREFIX_X} ${XORG_PREFIX}
clean:
	rm -rfd ${BUILD}
	rm -rfd .install