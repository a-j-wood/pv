#!/bin/sh
#
# Transfer a large chunk of data through pv and check data correctness
# afterwards.

rm -f "${workFile1}" "${workFile2}" 2>/dev/null

# exit on non-zero return codes
set -e

# generate some data
dd if=/dev/urandom of="${workFile1}" bs=1024 count=10240 2>/dev/null

CKSUM1=$(cksum "${workFile1}" | awk '{print $1}')

# read through pv and test afterwards
"${testSubject}" -B 100000 -q "${workFile1}" > "${workFile2}"

CKSUM2=$(cksum "${workFile2}" | awk '{print $1}')

test "x$CKSUM1" = "x$CKSUM2"

# clean up
rm -f "${workFile1}" "${workFile2}" 2>/dev/null

# EOF
