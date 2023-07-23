#!/bin/sh
#
# Check that the -q option shuts everything up.

dd if=/dev/zero bs=1000 count=5 2>/dev/null \
| "${testSubject}" -f -q -i 0.1 -L 5000 >/dev/null 2>"${workFile1}"
test ! -s "${workFile1}"

# EOF
