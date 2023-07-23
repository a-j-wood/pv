#!/bin/sh
#
# Make sure that files larger than 2GB are supported.

# Check there is enough free space for this test.
workFile1DIR="${workFile1%/*}"
workFile1SPACEKB=$(df -kP "${workFile1DIR}" | sed -n '$p' | awk '{print $(NF-2)}')
test -n "${workFile1SPACEKB}" || workFile1SPACEKB=0
if ! test "${workFile1SPACEKB}" -gt 3300000 2>/dev/null; then
	echo "need >3GB free on ${workFile1DIR}"
	exit 2
fi

# Generate a 3GB sparse file - we don't really need 3GB of free space unless
# sparse files are not supported.
echo -n > "${workFile1}"
if ! dd if="/dev/zero" of="${workFile1}" count=1 bs=1048576 seek=3072 2>/dev/null; then
	echo "failed to create 3GB specimen file"
	exit 2
fi

# NB the "stat" command is not portable - BSD stat(1) has a different syntax
# to GNU stat(1) - so we have to parse the output of ls(1).
FILESIZE=$(ls -nl "${workFile1}" 2>/dev/null | awk '{print $5}')
test -n "${FILESIZE}" || FILESIZE=0
if ! test "${FILESIZE}" -gt 3000000; then
	echo "failed to validate specimen file size"
	exit 2
fi

# Transfer the file, and count how many bytes came through.
TRANSFERRED=$("${testSubject}" -n -b "${workFile1}" 2>"${workFile2}" | wc -c 2>/dev/null | tr -dc '0-9')
test -n "${TRANSFERRED}" || TRANSFERRED=0
COUNTED=$(sed -n '$p' "${workFile2}" | tr -dc '0-9')
test -n "${COUNTED}" || COUNTED=0
if ! test "${TRANSFERRED}" -eq "${FILESIZE}"; then
	echo "transferred ${TRANSFERRED} of ${FILESIZE} bytes"
	exit 1
fi
if ! test "${COUNTED}" -eq "${FILESIZE}"; then
	echo "counted ${TRANSFERRED} of ${FILESIZE} bytes"
	exit 1
fi

# Transfer the file from stdin, and count how many bytes came through.
TRANSFERRED=$("${testSubject}" -n -b < "${workFile1}" 2>"${workFile2}" | wc -c 2>/dev/null | tr -dc '0-9')
test -n "${TRANSFERRED}" || TRANSFERRED=0
COUNTED=$(sed -n '$p' "${workFile2}" | tr -dc '0-9')
test -n "${COUNTED}" || COUNTED=0
if ! test "${TRANSFERRED}" -eq "${FILESIZE}"; then
	echo "stdin - transferred ${TRANSFERRED} of ${FILESIZE} bytes"
	exit 1
fi
if ! test "${COUNTED}" -eq "${FILESIZE}"; then
	echo "stdin - counted ${TRANSFERRED} of ${FILESIZE} bytes"
	exit 1
fi

# Use the file as a size value and transfer its size of bytes from dev/zero,
# and count how many bytes came through.
TRANSFERRED=$("${testSubject}" -n -b -S -s "@${workFile1}" /dev/zero 2>"${workFile2}" | wc -c 2>/dev/null | tr -dc '0-9')
test -n "${TRANSFERRED}" || TRANSFERRED=0
COUNTED=$(sed -n '$p' "${workFile2}" | tr -dc '0-9')
test -n "${COUNTED}" || COUNTED=0
if ! test "${TRANSFERRED}" -eq "${FILESIZE}"; then
	echo "size read - transferred ${TRANSFERRED} of ${FILESIZE} bytes"
	exit 1
fi
if ! test "${COUNTED}" -eq "${FILESIZE}"; then
	echo "size read - counted ${COUNTED} of ${FILESIZE} bytes"
	exit 1
fi

echo -n > "${workFile1}"
echo -n > "${workFile2}"

exit 0

# EOF
