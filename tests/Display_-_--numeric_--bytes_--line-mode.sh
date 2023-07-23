#!/bin/sh
#
# Check that numeric output shows line counts instead of percentages, when
# used in line mode together with bytes mode.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"

# Pass through 100 lines.
#
seq -w 3 1 100 \
| "${testSubject}" -bnl -i 0.2 -f -L 100 2>"${workFile1}" > "${workFile2}"

lineCount=$(wc -l < "${workFile1}" | tr -dc '0-9')
finalStdoutLine=$(sed -n '$p' < "${workFile2}")

# The number of output lines should be >3 and <10, and the final line of
# transferred data on stdout should be 100.
#
if ! test "${lineCount}" -gt 3; then
	echo "fewer than 4 output lines (${lineCount})"
	cat "${workFile1}"
	exit 1
fi
if ! test "${lineCount}" -lt 10; then
	echo "more than 9 output lines (${lineCount})"
	cat "${workFile1}"
	exit 1
fi
if ! test "${finalStdoutLine}" = "100"; then
	echo "final transferred line was not 100 (${finalStdoutLine})"
	exit 1
fi

exit 0

# EOF
