#!/bin/sh
#
# Check that the progress bar is produced when "--force" is used, and is not
# when it is not, providing stderr is a file.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}";

dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -f -p -i 0.1 -L 100 >/dev/null 2>"${workFile1}"

# There should be more than 2 different lines of output.
#
lineCount=$(tr '\r' '\n' < "${workFile1}" | sort | uniq -u | wc -l | tr -dc '0-9')
if ! test "${lineCount}" -gt 2; then
	echo "fewer than 3 different progress lines with \"--force\" (${lineCount})"
	tr '\r' '\n' < "${workFile1}" | sort | uniq -u
	exit 1
fi

# Now try again without "--force".

dd if=/dev/zero bs=100 count=1 2>/dev/null \
| "${testSubject}" -p -i 0.1 -L 100 >/dev/null 2>"${workFile1}"

# There should be no output without "--force".
#
if test -s "${workFile1}"; then
	echo "unexpected output when not using \"--force\""
	tr '\r' '\n' < "${workFile1}" | sort | uniq -u
	exit 1
fi

exit 0

# EOF
