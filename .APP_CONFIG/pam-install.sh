#!/bin/bash
XORG_PREFIX=$1
mkdir -pv ${XORG_PREFIX}/include/security
cp -av ${XORG_PREFIX}/include/pam*.h ${XORG_PREFIX}/include/security
cp -av ${XORG_PREFIX}/include/_pam*.h ${XORG_PREFIX}/include/security

chmod -v 4755 ${XORG_PREFIX}/sbin/unix_chkpwd &&
for file in pam pam_misc pamc
do
  mv -v ${XORG_PREFIX}/usr/lib/lib${file}.so.* ${XORG_PREFIX}/lib &&
  ln -sfv ../../lib/$(readlink ${XORG_PREFIX}/usr/lib/lib${file}.so) ${XORG_PREFIX}/usr/lib/lib${file}.so
done
