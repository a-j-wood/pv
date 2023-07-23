#!/bin/sh
#
# Try repeatedly messaging a transfer process, and make sure the data stays
# intact.

# Do nothing if IPC is not supported.
if ! "${testSubject}" -h 2>/dev/null | grep -Eq "^  -R,"; then
	echo "IPC is not supported on this platform"
	exit 2
fi

rm -f "${workFile1}" "${workFile2}" "${workFile3}" "${workFile4}" 2>/dev/null

# Exit on non-zero return codes.
set -e

# Generate some data.
dd if=/dev/urandom of="${workFile1}" bs=1024 count=10240 2>/dev/null

# Run a few remote control commands in the background.
#
echo FAIL > "${workFile3}"
(
set +e
sleep 2
for x in 1 2 3; do
	"${testSubject}" -R $(cat "${workFile4}") -apterb	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R $(cat "${workFile4}") -p	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R $(cat "${workFile4}") -N "test"	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R $(cat "${workFile4}") -F "%e"	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R $(cat "${workFile4}") -N "."	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
done
"${testSubject}" -R $(cat "${workFile4}") -L 10M
echo OK > "${workFile3}"
) &

# Run our data transfer.
"${testSubject}" -L 100k -i 0.1 -f -P "${workFile4}" "${workFile1}" > "${workFile2}" 2>/dev/null

# Check our remote control calls ran OK.
BGSTATUS=$(cat "${workFile3}")
test "x$BGSTATUS" = "xOK"

# Check data integrity.
CKSUM1=$(cksum "${workFile1}" | awk '{print $1}')
CKSUM2=$(cksum "${workFile2}" | awk '{print $1}')
test "x$CKSUM1" = "x$CKSUM2"

# EOF
