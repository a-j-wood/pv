#!/bin/sh
#
# Test that "make install" installs the expected minimum set of files.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

makeDir="${testSubject%/*}"
if ! test -d "${makeDir}"; then
	echo "could not find the directory to run \`make' in"
	exit 2
fi

makeCommand=$(command -v gmake 2>/dev/null)
test -z "${makeCommand}" && makeCommand="make"

testInstallDir=$(mktemp -d)
if ! test -n "${testInstallDir}"; then
	echo "failed to create temporary installation directory"
	exit 2
fi

export DESTDIR="${testInstallDir}"
if ! ${makeCommand} -C "${makeDir}" install DESTDIR="${testInstallDir}" >"${workFile1}" 2>&1; then
	echo "\`make install' exited $?"
	rm -rf "${testInstallDir}"
	exit 1
fi

exitStatus=0
if ! find "${testInstallDir}" -type f -name "pv.1*" | grep -Fq "pv.1"; then
	echo "installation of man page failed"
	exitStatus=1
fi
if ! find "${testInstallDir}" -type f -name "pv*" | grep -Fv "pv.1" | grep -Fq "pv"; then
	echo "installation of binary failed"
	exitStatus=1
fi

# Only check for message catalogue files if any were defined in the Makefile.
if grep "^CATALOGS" "${makeDir}/Makefile" 2>/dev/null | cut -d = -f 2 | grep -Fq .mo; then
	if ! find "${testInstallDir}" -type f -name "*.mo" | grep -Fq ".mo"; then
		echo "installation of localisation files failed"
		exitStatus=1
	fi
else
	# There should always be some message catalogue files defined.
	echo "no localisation files defined in the Makefile (\$CATALOGS is empty)"
	exitStatus=1
fi

rm -rf "${testInstallDir}"
exit "${exitStatus}"

# EOF
