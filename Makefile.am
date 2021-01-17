#!/bin/make
.PHONY: all install 
.IGNORE: clean
XORG_PREFIX="/usr/X11R7"
BUILD="build"
PREFIX_X="${PREFIX}"
all:
	mkdir -p ${PWD}/.install
install:
	mv -t .install ${PREFIX_X}
	mkdir -p ${PREFIX_X}
	mv -t ${PREFIX_X}/../../ .install/*
	./install.sh ${PREFIX_X} ${XORG_PREFIX}
clean:
	rm -rfd ${BUILD}
	rm -rfd .install