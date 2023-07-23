#!/bin/sh
#
# Try changing the format of a transfer remotely.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"; workFile3="${workFile3:-.tmp3}"; workFile4="${workFile4:-.tmp4}"

# Do nothing if IPC is not supported.
if ! "${testSubject}" -h 2>/dev/null | grep -Eq "^  -R,"; then
	echo "IPC is not supported on this platform"
	exit 2
fi

# Generate an empty test file.
dd if=/dev/zero of="${workFile1}" bs=1024 count=10240 2>/dev/null

(
sleep 1
"${testSubject}" -R "$(cat "${workFile4}")" -a
sleep 2
"${testSubject}" -R "$(cat "${workFile4}")" -L 10M
) &

"${testSubject}" -L 2M -f -P "${workFile4}" "${workFile1}" > "${workFile2}" 2>"${workFile3}"

# Make sure there is more than one length of line (excluding blank lines).
line_lengths=$(tr '\r' '\n' < "${workFile3}" | awk '{print length($0)}' | grep -Fvx 0 | sort -n | uniq | wc -l | tr -dc '0-9')

if ! test "${line_lengths}" -gt 1; then
	echo "only one line length seen - format change failed"
	exit 1
fi

exit 0

# EOF
