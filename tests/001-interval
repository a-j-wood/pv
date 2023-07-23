#!/bin/sh
#
# Check that the update interval can be set.

sleep 1 | "${testSubject}" -f -i 0.1 >/dev/null 2>"${workFile1}"

# There should be more than 6 lines of output.
#
NUM=$(tr '\r' '\n' < "${workFile1}" | wc -l | tr -d ' ')
test $NUM -gt 6

# EOF
