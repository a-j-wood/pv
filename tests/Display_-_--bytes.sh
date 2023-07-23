#!/bin/sh
#
# Check that the byte counter counts.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -f -b >/dev/null 2>"${workFile1}"

counterValue=$(tr '\r' '\n' < "${workFile1}" | tr -d ' ')
test "${counterValue}" = "100B" && exit 0

echo "unexpected byte counter value: ${counterValue}"
exit 1

# EOF
