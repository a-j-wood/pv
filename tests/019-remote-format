#!/bin/sh
#
# Try changing the format of a transfer remotely.

# Do nothing if IPC is not supported.
if ! "${testSubject}" -h 2>/dev/null | grep -Eq "^  -R,"; then
	echo "IPC is not supported on this platform"
	exit 2
fi

rm -f "${workFile1}" "${workFile2}" "${workFile3}" "${workFile4}" 2>/dev/null

# Exit on non-zero return codes.
set -e

# Generate an empty test file.
dd if=/dev/zero of="${workFile1}" bs=1024 count=10240 2>/dev/null

(
sleep 1
"${testSubject}" -R $(cat "${workFile4}") -a
sleep 2
"${testSubject}" -R $(cat "${workFile4}") -L 10M
) &

"${testSubject}" -L 2M -f -P "${workFile4}" "${workFile1}" > "${workFile2}" 2>"${workFile3}"

# Make sure there is more than one length of line (excluding blank lines).
line_lengths=$(tr '\r' '\n' < "${workFile3}" | awk '{print length($0)}' | grep -Fvx 0 | sort -n | uniq | wc -l)
test $line_lengths -gt 1

# EOF
