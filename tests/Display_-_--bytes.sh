#!/bin/sh
#
# Check that the byte counter counts.

dd if=/dev/zero bs=100 count=1 2>/dev/null \
| LANG=C "${testSubject}" -f -b >/dev/null 2>"${workFile1}"
NUM=$(tr '\r' '\n' < "${workFile1}" | tr -d ' ')
test "$NUM" = "100B"

# EOF
