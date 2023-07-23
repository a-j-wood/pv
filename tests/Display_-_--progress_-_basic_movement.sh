#!/bin/sh
#
# Check that the progress bar moves when data is coming in.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -f -p -i 0.1 -L 500 >/dev/null 2>"${workFile1}"

# There should be more than 2 different lines of output.
#
lineCount=$(tr '\r' '\n' < "${workFile1}" | sort | uniq -u | wc -l | tr -dc '0-9')
if ! test "${lineCount}" -gt 2; then
	echo "fewer than 3 different progress lines (${lineCount})"
	tr '\r' '\n' < "${workFile1}" | sort | uniq -u
	exit 1
fi

exit 0

# EOF
