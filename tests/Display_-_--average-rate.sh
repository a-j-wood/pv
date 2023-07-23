#!/bin/sh
#
# Check that the average transfer rate counter changes, but not more than it
# should.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Transfer 210 bytes as 100 bytes, a 1 second gap, 110 bytes, and another 1
# second gap.
#
(dd if=/dev/zero bs=100 count=1 2>/dev/null;
 sleep 1;
 dd if=/dev/zero bs=110 count=1 2>/dev/null;
 sleep 1;
) | "${testSubject}" -f -i 0.5 -a >/dev/null 2>"${workFile1}"

# Count the number of rates output that are below 80.
#
lineCount=$(tr '\r' '\n' < "${workFile1}" | tr -dc '0-9.\n' | sed '/^$/d' | awk '$1<80{print}' | wc -l | tr -dc '0-9')

# Nearly all of the output rates should be above 80 since the average rate
# will always be around 100 bytes per second, except for pauses.
#
test "${lineCount}" -lt 2 && exit 0

echo "average rate varied more than expected"
tr '\r' '\n' < "${workFile1}"
exit 1

# EOF
