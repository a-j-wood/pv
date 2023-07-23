#!/bin/sh
#
# Check that the elapsed time counter does count up.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Transfer a zero amount of data, but take 3 seconds to do it.
#
(sleep 3 | "${testSubject}" -f -t >/dev/null) 2>&1 | tr '\r' '\n' > "${workFile1}"

# Count the number of different timer values; it should be >1.
#
valueCount=$(sort < "${workFile1}" | uniq -u | wc -l | tr -dc '0-9')
if ! test "${valueCount}" -gt 1; then
	echo "timer value did not change"
	exit 1
fi

exit 0

# EOF
