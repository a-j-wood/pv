#!/bin/sh
#
# Script to autogenerate the `configure' script, and the config header
# template if `autoconf' is available, and then rebuild the dependency list.

set -e

cd $(dirname $0)

test -t 1 && echo "${0##*/}: running autoconf"
autoconf autoconf/configure.in > configure
chmod 755 configure

if command -v autoheader >/dev/null; then
	test -t 1 && echo "${0##*/}: running autoheader"
	autoheader autoconf/configure.in
else
	test -t 1 && echo "${0##*/}: autoheader not found, skipping"
fi

echo > autoconf/make/depend.mk~
echo > autoconf/make/filelist.mk~
echo > autoconf/make/modules.mk~

MAKE=make
command -v gmake >/dev/null 2>&1 && MAKE=gmake

rm -rf .gen
mkdir .gen
cd .gen

test -t 1 && echo "${0##*/}: running new \`configure' script"
sh ../configure

test -t 1 && echo "${0##*/}: regenerating Makefile fragments"
$MAKE make
$MAKE dep

test -t 1 && echo "${0##*/}: cleaning up"
cd ..
rm -rf .gen
rm -rf autom4te.cache autoconf/autom4te.cache

# EOF
