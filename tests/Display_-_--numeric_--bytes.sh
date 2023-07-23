#!/bin/sh
#
# Check that numeric output gives a byte count instead of a percentage when
# used with -b.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Process 500 bytes at 500 bytes per second, updating every 0.1 seconds for
# around 10 output lines.
#
dd if=/dev/zero bs=500 count=1 2>/dev/null \
| "${testSubject}" -s 500 -n -b -i 0.1 -L 500 >/dev/null 2>"${workFile1}"

lineCount=$(wc -l < "${workFile1}" | tr -dc '0-9')
finalLine=$(sed -n '$p' < "${workFile1}")

# The number of output lines should be >8 and <13, and the final byte count
# should be 500.
#
if ! test "${lineCount}" -gt 8; then
	echo "fewer than 9 output lines (${lineCount})"
	exit 1
fi
if ! test "${lineCount}" -lt 13; then
	echo "more than 12 output lines (${lineCount})"
	exit 1
fi
if ! test "${finalLine}" = "500"; then
	echo "final byte count was not 500 (${finalLine})"
	exit 1
fi

# EOF
