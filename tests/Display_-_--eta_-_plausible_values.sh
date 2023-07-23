#!/bin/sh
#
# Check that the estimated time counter counts.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -f -e -s 100 -i 0.1 -L 25 >/dev/null 2>"${workFile1}"

# Count the number of different ETA values there have been.
#
valueCount=$(tr '\r' '\n' < "${workFile1}" | tr -d ' ' | sed '/^$/d' | sort | uniq | wc -l | tr -dc '0-9')

# 3 or less - not OK, since it should have taken 4 seconds.
#
if ! test "${valueCount}" -gt 3; then
	echo "fewer than 4 ETA values seen"
	tr '\r' '\n' < "${workFile1}" | sed '/^ *$/d' | sort | uniq
	exit 1
fi

# 12 or more - not OK, since even on a heavily loaded system that's too long.
#
if ! test "${valueCount}" -lt 12; then
	echo "more than 11 ETA values seen"
	tr '\r' '\n' < "${workFile1}" | sed '/^ *$/d' | sort | uniq
	exit 1
fi

exit 0

# EOF
