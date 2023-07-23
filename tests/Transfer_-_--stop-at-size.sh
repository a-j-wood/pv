#!/bin/sh
#
# Make sure -S stops at the given size.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"

# generate some data
dd if=/dev/urandom of="${workFile1}" bs=1024 count=10 2>/dev/null

# read through pv and test afterwards
"${testSubject}" -S -s 5120 -q "${workFile1}" > "${workFile2}"

outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')

# take the first 5120 bytes of workFile1 and cksum them
dd if="${workFile1}" of="${workFile2}" bs=1024 count=5 2>/dev/null
inputChecksum=$(cksum "${workFile2}" | awk '{print $1}')

if ! test "${inputChecksum}" = "${outputChecksum}"; then
	echo "input and output checksums differ"
	exit 1
fi

exit 0

# EOF
