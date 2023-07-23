#!/bin/sh
#
# Check that the update interval can be set.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

sleep 1 | "${testSubject}" -f -i 0.1 >/dev/null 2>"${workFile1}"

# There should be more than 6 lines of output.
#
lineCount=$(tr '\r' '\n' < "${workFile1}" | wc -l | tr -dc '0-9')
if ! test "${lineCount}" -gt 6; then
	echo "fewer than 7 lines of output"
	tr '\r' '\n' < "${workFile1}"
	exit 1
fi

exit 0

# EOF
