#!/bin/sh
#
# Check that "--last-written" works.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Slowly write a sequence of numbers (rate-limited by another `pv' instance)
# and watch the "--last-written" output of a second `pv' instance to make
# sure the buffer contents are visible (we use "-B" to disable splice mode).
seq -w 3 1 100 \
| "${testSubject}" -qL 200 \
| "${testSubject}" -f -B 1024 -A 16 -i 0.2 >/dev/null 2>"${workFile1}"

differentLines=$(tr '\r' '\n' < "${workFile1}" | sed '/^ *$/d' | sort | uniq | wc -l | tr -dc '0-9')
lastLine=$(tr '\r' '\n' < "${workFile1}" | sed '/^ *$/d' | sed -n '$p')

if ! test "${differentLines}" -gt 5; then
	echo "fewer than 6 different outputs seen"
	tr '\r' '\n' < "${workFile1}" | sed '/^ *$/d' | sort | uniq
	exit 1
fi

expectedLastLine="097.098.099.100."
if ! test "${lastLine}" = "${expectedLastLine}"; then
	echo "final output differs from expected value"
	echo "expected value: [${expectedLastLine}]"
	echo "observed value: [${lastLine}]"
	exit 1
fi

exit 0

# EOF
