#!/bin/sh
#
# Check that the bytes count doesn't increase the line length as it passes
# 1MiB, described here:
# http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=586763

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Transfer 1500kB of data in a bursty fashion.
#
(dd if=/dev/zero bs=1k count=999;
 sleep 1;
 dd if=/dev/zero bs=1k count=1;
 sleep 1;
 dd if=/dev/zero bs=1k count=500;
 sleep 1;
) 2>/dev/null | ("${testSubject}" -btIf -s 1500k >/dev/null) 2>"${workFile1}"

# Count how many different line lengths we've seen.
#
lineLengthCount=$(tr '\r' '\n' < "${workFile1}" | sed 's/ *$//' | awk '{x=length($0);if(x>0)print length($0)}' | sort | uniq | wc -l | tr -dc '0-9')

# There should only be one length (not counting 0).
#
test "${lineLengthCount}" = "1" && exit 0

echo "variable line lengths detected"
tr '\r' '\n' < "${workFile1}"
exit 1

# EOF
