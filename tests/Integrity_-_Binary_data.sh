#!/bin/sh
#
# Transfer a large chunk of data through pv and check data correctness
# afterwards.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"

# generate some data
dd if=/dev/urandom of="${workFile1}" bs=1024 count=10240 2>/dev/null

inputChecksum=$(cksum "${workFile1}" | awk '{print $1}')

# read through pv and test afterwards
"${testSubject}" -B 100000 -q "${workFile1}" > "${workFile2}"

outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')

test "${inputChecksum}" = "${outputChecksum}" || exit 1

exit 0

# EOF
