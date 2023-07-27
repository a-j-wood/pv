#!/bin/sh
#
# Transfer a large chunk of data with "--direct-io" and check data
# correctness afterwards, both with and without rate limits.  Note that this
# doesn't check that O_DIRECT is actually being used, it just checks that
# data is not being corrupted.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"

# generate some data
dd if=/dev/urandom of="${workFile1}" bs=1024 count=2560 2>/dev/null

inputChecksum=$(cksum "${workFile1}" | awk '{print $1}')
doubleInputChecksum=$(cat "${workFile1}" "${workFile1}" | cksum - | awk '{print $1}')

# read through pv and test afterwards
"${testSubject}" -q "${workFile1}" > "${workFile2}"
outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')

if ! test "${inputChecksum}" = "${outputChecksum}"; then
	echo "checksum mismatched even without \"--direct-io\""
	exit 1
fi

# Same again but with "--direct-io"

"${testSubject}" -K -q "${workFile1}" > "${workFile2}"
outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')
if ! test "${inputChecksum}" = "${outputChecksum}"; then
	echo "checksum mismatched with \"--direct-io\""
	exit 1
fi

# Now with "--direct-io" and "--rate-limit"

"${testSubject}" -K -L 800K -q "${workFile1}" > "${workFile2}"
outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')
if ! test "${inputChecksum}" = "${outputChecksum}"; then
	echo "checksum mismatched with \"--direct-io\" + \"--rate-limit\""
	exit 1
fi

# Now with "--direct-io" on the same file twice

"${testSubject}" -K -q "${workFile1}" "${workFile1}" > "${workFile2}"
outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')
if ! test "${doubleInputChecksum}" = "${outputChecksum}"; then
	echo "checksum mismatched with \"--direct-io\" on two files"
	exit 1
fi

exit 0

# EOF
