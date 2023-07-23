#!/bin/sh
#
# Make sure -S stops at the given size.

rm -f "${workFile1}" "${workFile2}" 2>/dev/null

# exit on non-zero return codes
set -e

# generate some data
dd if=/dev/urandom of="${workFile1}" bs=1024 count=10 2>/dev/null

# read through pv and test afterwards
"${testSubject}" -S -s 5120 -q "${workFile1}" > "${workFile2}"

CKSUM2=$(cksum "${workFile2}" | awk '{print $1}')

# take the first 5120 bytes of workFile1 and cksum them
rm -f "${workFile2}"
dd if="${workFile1}" of="${workFile2}" bs=1024 count=5 2>/dev/null
CKSUM1=$(cksum "${workFile2}" | awk '{print $1}')

test "x$CKSUM1" = "x$CKSUM2"

# clean up
rm -f "${workFile1}" "${workFile2}" 2>/dev/null

# EOF
