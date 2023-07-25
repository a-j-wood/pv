#!/bin/sh
#
# Check that "--size" affects the percentage shown.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Process 100 bytes at 100 bytes per second, updating every 0.1 seconds for
# around 10 output lines, but set the size to 200.
#
dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -s 200 -n -i 0.1 -L 100 >/dev/null 2>"${workFile1}"

lineCount=$(wc -l < "${workFile1}" | tr -dc '0-9')
finalLine=$(sed -n '$p' < "${workFile1}")

# The number of output lines should be >8 and <13, and the final percentage
# should be 50.
#
if ! test "${lineCount}" -gt 8; then
	echo "part 1: fewer than 9 output lines (${lineCount})"
	exit 1
fi
if ! test "${lineCount}" -lt 13; then
	echo "part 1: more than 12 output lines (${lineCount})"
	exit 1
fi
if ! test "${finalLine}" = "50"; then
	echo "part 1: final percentage was not 50 (${finalLine})"
	exit 1
fi

# Same as above, but this time with a size of 50 for 100 input bytes.
#
dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -s 50 -n -i 0.1 -L 100 >/dev/null 2>"${workFile1}"

lineCount=$(wc -l < "${workFile1}" | tr -dc '0-9')
finalLine=$(sed -n '$p' < "${workFile1}")

if ! test "${lineCount}" -gt 8; then
	echo "part 2: fewer than 9 output lines (${lineCount})"
	exit 1
fi
if ! test "${lineCount}" -lt 13; then
	echo "part 2: more than 12 output lines (${lineCount})"
	exit 1
fi
if ! test "${finalLine}" = "200"; then
	echo "part 2: final percentage was not 200 (${finalLine})"
	exit 1
fi

exit 0

# EOF
