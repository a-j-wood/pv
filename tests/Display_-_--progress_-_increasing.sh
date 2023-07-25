#!/bin/sh
#
# Check that the progress bar increases in size when data is coming in.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -f -p -i 0.1 -L 50 -s 100 >/dev/null 2>"${workFile1}"

# There should be more than 5 different lines of output.
#
lineCount=$(tr '\r' '\n' < "${workFile1}" | sort | uniq -u | wc -l | tr -dc '0-9')
if ! test "${lineCount}" -gt 5; then
	echo "fewer than 6 different progress lines (${lineCount})"
	tr '\r' '\n' < "${workFile1}" | sort | uniq -u
	exit 1
fi

# Counting the "=" characters in each line that make up the progress bar
# should give at least 5 different line lengths.
#
differentBarLengthsCount=$(tr '\r' '\n' < "${workFile1}" | tr -dc '=\n' | awk '{print length($1)}' | sort | uniq -u | wc -l | tr -dc '0-9')
if ! test "${differentBarLengthsCount}" -gt 5; then
	echo "fewer than 6 different progress bar lengths detected (${differentBarLengthsCount})"
	tr '\r' '\n' < "${workFile1}" | sort | uniq -u
	exit 1
fi

exit 0

# EOF
