#!/bin/sh
#
# Script to autogenerate the `configure' script, and rebuild the dependency
# list.

set -e

cd `dirname $0`

cd autoconf
autoconf configure.in > ../configure
cd ..
chmod 755 configure

echo > autoconf/make/depend.mk~
echo > autoconf/make/filelist.mk~
echo > autoconf/make/modules.mk~

MAKE=make
which gmake >/dev/null 2>&1 && MAKE=gmake

rm -rf .gen
mkdir .gen
cd .gen
sh ../configure
$MAKE make
$MAKE dep
cd ..
rm -rf .gen
rm -rf autoconf/autom4te.cache

# EOF
