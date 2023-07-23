#!/bin/sh
#
# Check that the transfer rate counter changes.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Transfer 200 bytes as two 100-byte blocks with a 2-second gap between.
#
(dd if=/dev/zero bs=100 count=1 2>/dev/null;
 sleep 2;
 dd if=/dev/zero bs=100 count=1 2>/dev/null;
) | "${testSubject}" -f -i 0.5 -r >/dev/null 2>"${workFile1}"

# Count the number of different rates output.
#
rateCount=$(tr '\r' '\n' < "${workFile1}" | sort | uniq -u | wc -l | tr -dc '0-9')

# There should be more than 2 different rates counted (around 100 bytes/sec
# for the each block, 0 bytes/sec for the gap in the middle, and around 50
# bytes/sec for the average time reported at the end).
#
if ! test "${rateCount}" -gt 2; then
	echo "fewer than 3 different rates detected (${rateCount})"
	tr '\r' '\n' < "${workFile1}" | sort | uniq -u
	exit 1
fi

exit 0

# EOF
