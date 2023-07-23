#!/bin/sh
#
# Check that numeric output gives a timer when used with -t.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Process 100 bytes at 100 bytes per second, updating every 0.1 seconds for
# around 10 output lines.
#
dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -s 100 -n -t -i 0.1 -L 100 >/dev/null 2>"${workFile1}"

lineCount=$(wc -l < "${workFile1}" | tr -dc '0-9')
timesCount=$(tr ',' '.' < "${workFile1}" | awk '{print int(10*$1)}' | sort -n | uniq | wc -l | tr -dc '0-9')
finalPercentage=$(sed -n '$p' < "${workFile1}" | awk '{print $2}')

# The number of output lines should be >8 and <13, and the number of
# different elapsed times should be at least 7. The last percentage should
# be 100.
#
if ! test "${lineCount}" -gt 8; then
	echo "fewer than 9 output lines (${lineCount})"
	exit 1
fi
if ! test "${lineCount}" -lt 13; then
	echo "more than 12 output lines (${lineCount})"
	exit 1
fi
if ! test "${timesCount}" -gt 7; then
	echo "fewer than 8 different elapsed times (${timesCount})"
	exit 1
fi
if ! test "${finalPercentage}" = "100"; then
	echo "final percentage was not 100 (${finalPercentage})"
	exit 1
fi

exit 0

# EOF
