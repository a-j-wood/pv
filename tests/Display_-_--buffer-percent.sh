#!/bin/sh
#
# Check that "--buffer-percent" displays correctly.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# The output should show 100% and 0% as the buffer initially fills up due to
# there being nowhere to write it to, and then empties.
( dd if=/dev/zero bs=1024 count=1024; sleep 2; ) 2>/dev/null \
| "${testSubject}" -f -T -i 0.5 -B 1024 2>"${workFile1}" \
| (sleep 1; dd bs=1024 count=512; sleep 1; cat; ) >/dev/null 2>&1

differentLines=$(tr '\r' '\n' < "${workFile1}" | sed '/^ *$/d' | sort | uniq | wc -l | tr -dc '0-9')
test "${differentLines}" -gt 1 && exit 0

echo "expected output changes not seen"
tr '\r' '\n' < "${workFile1}" | sed 's/^ *$/d' | sort | uniq
exit 1

# EOF
