#!/bin/sh
#
# Check that the estimated time counter can show the end time of day.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -f -I -s 100 -i 0.1 -L 25 >/dev/null 2>"${workFile1}"

# Count the number of different ETA values there have been.
#
valueCount=$(tr '\r' '\n' < "${workFile1}" | tr -d ' ' | sed '/^$/d' | sort | uniq | wc -l | tr -dc '0-9')

# There should be at least 1 line of output.
#
if ! test "${valueCount}" -gt 0; then
	echo "no output found"
	exit 1
fi

# 8 or more different values - not OK.
#
if ! test "${valueCount}" -lt 8; then
	echo "more than 7 different values (${valueCount})"
	tr '\r' '\n' < "${workFile1}" | sed '/^ *$/d' | sort | uniq
	exit 1
fi

exit 0

# EOF
