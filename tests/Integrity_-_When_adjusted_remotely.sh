#!/bin/sh
#
# Try repeatedly messaging a transfer process, and make sure the data stays
# intact.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"; workFile3="${workFile3:-.tmp3}"; workFile4="${workFile4:-.tmp4}"

# Do nothing if IPC is not supported.
if ! "${testSubject}" -h 2>/dev/null | grep -Eq "^  -R,"; then
	echo "IPC is not supported on this platform"
	exit 2
fi

# Generate some data.
dd if=/dev/urandom of="${workFile1}" bs=1024 count=10240 2>/dev/null

# Run a few remote control commands in the background.
#
echo FAIL > "${workFile3}"
(
set +e
sleep 2
for loopCount in 1 2 3; do
	"${testSubject}" -R "$(cat "${workFile4}")" -apterb	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R "$(cat "${workFile4}")" -p		|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R "$(cat "${workFile4}")" -N "test"	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R "$(cat "${workFile4}")" -F "%e"	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R "$(cat "${workFile4}")" -N "."	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	echo "${loopCount}" >/dev/null	# dummy for shellcheck
done
"${testSubject}" -R "$(cat "${workFile4}")" -L 10M
echo OK > "${workFile3}"
) &

# Run our data transfer.
"${testSubject}" -L 100k -i 0.1 -f -P "${workFile4}" "${workFile1}" > "${workFile2}" 2>/dev/null

# Check our remote control calls ran OK.
backgroundStatus=$(cat "${workFile3}")
if ! test "${backgroundStatus}" = "OK"; then
	echo "remote control calls failed"
	exit 1
fi

# Check data integrity.
inputChecksum=$(cksum "${workFile1}" | awk '{print $1}')
outputChecksum=$(cksum "${workFile2}" | awk '{print $1}')
if ! test "${inputChecksum}" = "${outputChecksum}"; then
	echo "input and output checksums differ"
	exit 1
fi

exit 0

# EOF
