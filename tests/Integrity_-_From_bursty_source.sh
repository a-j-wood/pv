#!/bin/sh
#
# Transfer a large chunk of data through pv using pipes, sending it in a
# bursty fashion, and check data correctness afterwards.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"

# generate some data
dd if=/dev/urandom of="${workFile1}" bs=1024 count=10240 2>/dev/null

inputChecksum=$(cksum "${workFile1}" | awk '{print $1}')

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

outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')

if ! test "${inputChecksum}" = "${outputChecksum}"; then
	echo "checksum mismatch with dd | pv | cat"
	exit 1
fi

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

outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')

if ! test "${inputChecksum}" = "${outputChecksum}"; then
	echo "checksum mismatch with dd | pv > file"
	exit 1
fi

exit 0

# EOF
