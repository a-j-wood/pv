#!/bin/sh
#
# Check that numeric output outputs some percentages.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Process 100 bytes at 100 bytes per second, updating every 0.1 seconds for
# around 10 output lines.
#
dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -s 100 -n -i 0.1 -L 100 >/dev/null 2>"${workFile1}"

lineCount=$(wc -l < "${workFile1}" | tr -dc '0-9')
finalLine=$(sed -n '$p' < "${workFile1}")

# The number of output lines should be >8 and <13, and the final percentage
# should be 100.
#
if ! test "${lineCount}" -gt 8; then
	echo "fewer than 9 output lines (${lineCount})"
	exit 1
fi
if ! test "${lineCount}" -lt 13; then
	echo "more than 12 output lines (${lineCount})"
	exit 1
fi
if ! test "${finalLine}" = "100"; then
	echo "final percentage was not 100 (${finalLine})"
	exit 1
fi

exit 0

# EOF
