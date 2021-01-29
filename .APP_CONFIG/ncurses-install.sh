#!/bin/bash
INSTALLDIR=$1
echo "INPUT(-lncursesw)" > ${INSTALLDIR}/usr/lib/libncurses.so
mv -v ${INSTALLDIR}/usr/lib/libncursesw.so.6* ${INSTALLDIR}/lib
ln -sfv ../../lib/$(readlink ${INSTALLDIR}/usr/lib/libncursesw.so) ${INSTALLDIR}/usr/lib/libncursesw.so 
