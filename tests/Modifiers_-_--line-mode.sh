#!/bin/sh
#
# Check that line mode counts lines instead of bytes.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Pass through 100 lines.
#
seq 1 100 \
| "${testSubject}" -bl -i 0.2 -f -L 50 >/dev/null 2>"${workFile1}"

lineCount=$(tr '\r' '\n' < "${workFile1}" | sort | uniq -u | wc -l | tr -dc '0-9')
lastNumber=$(tr '\r' '\n' < "${workFile1}" | awk '/[0-9]/{printf "%.0f\n",$1}' | sed -n '$p')

# The last number output should be the number of input lines.
if ! test "${lastNumber}" = "100"; then
	echo "line counter was incorrect (${lastNumber} instead of 100)"
	tr '\r' '\n' < "${workFile1}"
	exit 1
fi

# There should be more than 3 output lines as the counter increased.
if ! test "${lineCount}" -gt 3; then
	echo "fewer than 4 line counter values (${lineCount})"
	tr '\r' '\n' < "${workFile1}"
	exit 1
fi

exit 0

# EOF
