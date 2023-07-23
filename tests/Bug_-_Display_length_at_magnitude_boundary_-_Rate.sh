#!/bin/sh
#
# Same as test (1m_boundary_1) but for rate, not bytes transferred.

# Transfer 1500kB of data in a bursty fashion.
#
(dd if=/dev/zero bs=1k count=999;
 sleep 1;
 dd if=/dev/zero bs=1k count=1;
 sleep 1;
 dd if=/dev/zero bs=3 count=1;
 sleep 1;
 dd if=/dev/zero bs=1k count=500;
 sleep 1;
) 2>/dev/null | ("${testSubject}" -rtef -s 1500k >/dev/null) 2>"${workFile1}"

# Count how many different line lengths we've seen.
#
NUM=$(tr '\r' '\n' < "${workFile1}" | awk '{x=length($0);if(x>0)print length($0)}' | sort | uniq | wc -l)

# There should only be one length (not counting 0).
#
test $NUM -eq 1 || { echo; tr '\r' '\n' < "${workFile1}"; exit 1; }

# EOF
