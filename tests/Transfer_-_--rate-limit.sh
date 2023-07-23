#!/bin/sh
#
# A simple test of rate limiting.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"

# Transfer 102 bytes at 100 bytes/sec. It should take at least 1 second.
#
startTime=$(date +%S)
dd if=/dev/zero bs=102 count=1 2>/dev/null | "${testSubject}" -L 100 2>/dev/null | cat >/dev/null
endTime=$(date +%S)

if test "${startTime}" = "${endTime}"; then
	echo "transfer took zero seconds"
	exit 1
fi

exit 0

# EOF
