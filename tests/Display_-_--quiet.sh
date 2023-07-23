#!/bin/sh
#
# Check that the -q option shuts everything up.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

dd if=/dev/zero bs=1000 count=5 2>/dev/null \
| "${testSubject}" -f -q -i 0.1 -L 5000 >/dev/null 2>"${workFile1}"

if test -s "${workFile1}"; then
	echo "output detected when there should be none"
	cat "${workFile1}"
	exit 1
fi

exit 0

# EOF
