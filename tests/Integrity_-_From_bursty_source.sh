#!/bin/sh
#
# Transfer a large chunk of data through pv using pipes, sending it in a
# bursty fashion, and check data correctness afterwards.

rm -f "${workFile1}" "${workFile2}" 2>/dev/null

# exit on non-zero return codes
set -e

# generate some data
dd if=/dev/urandom of="${workFile1}" bs=1024 count=10240 2>/dev/null

CKSUM1=$(cksum "${workFile1}" | awk '{print $1}')

# read through pv and test afterwards
(
dd if="${workFile1}" bs=1 count=9000
sleep 1
dd if="${workFile1}" bs=1 skip=9000 count=1240
sleep 1
dd if="${workFile1}" bs=1024 skip=10 count=1014
sleep 1
dd if="${workFile1}" bs=1024 skip=1024 count=1024
sleep 1
dd if="${workFile1}" bs=1024 skip=2048
) 2>/dev/null | "${testSubject}" -q -L 2M | cat > "${workFile2}"

CKSUM2=$(cksum "${workFile2}" | awk '{print $1}')

test "x$CKSUM1" = "x$CKSUM2"

# same again but with one less pipe
(
dd if="${workFile1}" bs=1 count=9000
sleep 1
dd if="${workFile1}" bs=1 skip=9000 count=1240
sleep 1
dd if="${workFile1}" bs=1024 skip=10 count=1014
sleep 1
dd if="${workFile1}" bs=1024 skip=1024 count=1024
sleep 1
dd if="${workFile1}" bs=1024 skip=2048
) 2>/dev/null | "${testSubject}" -q -L 2M > "${workFile2}"

CKSUM2=$(cksum "${workFile2}" | awk '{print $1}')

test "x$CKSUM1" = "x$CKSUM2"

# clean up
rm -f "${workFile1}" "${workFile2}" 2>/dev/null

# EOF
