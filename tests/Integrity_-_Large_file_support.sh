#!/bin/sh
#
# Make sure that files larger than 2GB are supported.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"

# Check there is enough free space for this test.
workFile1Dir="${workFile1%/*}"
workFile1FreeKiB=$(df -kP "${workFile1Dir}" | sed -n '$p' | awk '{print $(NF-2)}')
test -n "${workFile1FreeKiB}" || workFile1FreeKiB=0
if ! test "${workFile1FreeKiB}" -gt 3300000 2>/dev/null; then
	echo "test requires at least 3GB free on ${workFile1Dir}"
	exit 2
fi

# Generate a 3GB sparse file - we don't really need 3GB of free space unless
# sparse files are not supported.
true > "${workFile1}"
if ! dd if="/dev/zero" of="${workFile1}" count=1 bs=1048576 seek=3072 2>/dev/null; then
	echo "failed to create 3GB specimen file"
	exit 2
fi

# NB the "stat" command is not portable - BSD stat(1) has a different syntax
# to GNU stat(1) - so we have to parse the output of ls(1).
# shellcheck disable=SC2012
fileSize=$(ls -nl "${workFile1}" 2>/dev/null | awk '{print $5}')
test -n "${fileSize}" || fileSize=0
if ! test "${fileSize}" -gt 3000000; then
	echo "failed to validate specimen file size"
	exit 2
fi

# Transfer the file, and count how many bytes came through.
bytesTransferred=$("${testSubject}" -n -b "${workFile1}" 2>"${workFile2}" | wc -c 2>/dev/null | tr -dc '0-9')
test -n "${bytesTransferred}" || bytesTransferred=0
bytesReported=$(sed -n '$p' "${workFile2}" | tr -dc '0-9')
test -n "${bytesReported}" || bytesReported=0
if ! test "${bytesTransferred}" -eq "${fileSize}"; then
	echo "transferred ${bytesTransferred} of ${fileSize} bytes"
	exit 1
fi
if ! test "${bytesReported}" -eq "${fileSize}"; then
	echo "counted ${bytesTransferred} of ${fileSize} bytes"
	exit 1
fi

# Transfer the file from stdin, and count how many bytes came through.
bytesTransferred=$("${testSubject}" -n -b < "${workFile1}" 2>"${workFile2}" | wc -c 2>/dev/null | tr -dc '0-9')
test -n "${bytesTransferred}" || bytesTransferred=0
bytesReported=$(sed -n '$p' "${workFile2}" | tr -dc '0-9')
test -n "${bytesReported}" || bytesReported=0
if ! test "${bytesTransferred}" -eq "${fileSize}"; then
	echo "stdin - transferred ${bytesTransferred} of ${fileSize} bytes"
	exit 1
fi
if ! test "${bytesReported}" -eq "${fileSize}"; then
	echo "stdin - counted ${bytesTransferred} of ${fileSize} bytes"
	exit 1
fi

# Use the file as a size value and transfer its size of bytes from dev/zero,
# and count how many bytes came through.
bytesTransferred=$("${testSubject}" -n -b -S -s "@${workFile1}" /dev/zero 2>"${workFile2}" | wc -c 2>/dev/null | tr -dc '0-9')
test -n "${bytesTransferred}" || bytesTransferred=0
bytesReported=$(sed -n '$p' "${workFile2}" | tr -dc '0-9')
test -n "${bytesReported}" || bytesReported=0
if ! test "${bytesTransferred}" -eq "${fileSize}"; then
	echo "size read - transferred ${bytesTransferred} of ${fileSize} bytes"
	exit 1
fi
if ! test "${bytesReported}" -eq "${fileSize}"; then
	echo "size read - counted ${bytesReported} of ${fileSize} bytes"
	exit 1
fi

exit 0

# EOF
