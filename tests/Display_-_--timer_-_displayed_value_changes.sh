#!/bin/sh
#
# Check that the elapsed time counter does count up.

# Transfer a zero amount of data, but take 3 seconds to do it.
#
(sleep 3 | "${testSubject}" -f -t >/dev/null) 2>&1 | tr '\r' '\n' > "${workFile1}"

# Count the number of different timer values; it should be >1.
#
NUM=$(sort < "${workFile1}" | uniq -u | wc -l | tr -d ' ')
test $NUM -gt 1

# EOF
