#!/bin/sh
#
# Transfer a large chunk of data with "--sync" and check data correctness
# afterwards, both with and without rate limits.  Note that this doesn't
# check that fdatasync() is actually being called, it just checks that data
# is not being corrupted.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"

# generate some data
dd if=/dev/urandom of="${workFile1}" bs=1024 count=2560 2>/dev/null

inputChecksum=$(cksum "${workFile1}" | awk '{print $1}')

# read through pv and test afterwards
"${testSubject}" -q "${workFile1}" > "${workFile2}"
outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')

if ! test "${inputChecksum}" = "${outputChecksum}"; then
	echo "checksum mismatched even without \"--sync\""
	exit 1
fi

# Same again but with "--sync"

"${testSubject}" -Y -q "${workFile1}" > "${workFile2}"
outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')
if ! test "${inputChecksum}" = "${outputChecksum}"; then
	echo "checksum mismatched with \"--sync\""
	exit 1
fi

# Now with "--sync" and "--rate-limit"

"${testSubject}" -Y -L 800K -q "${workFile1}" > "${workFile2}"
outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')
if ! test "${inputChecksum}" = "${outputChecksum}"; then
	echo "checksum mismatched with \"--sync\" + \"--rate-limit\""
	exit 1
fi

exit 0

# EOF
