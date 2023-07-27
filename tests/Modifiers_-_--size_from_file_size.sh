#!/bin/sh
#
# Similar to the "--size" check but, instead, using another file's size with
# "--size @".

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"

# Process 100 bytes at 100 bytes per second, interval 0.1 seconds, with the
# size set from a file of $1 bytes and expecting a percentage of $2 at the
# end.
sizeCheck () {
	# Make a file of size $1 bytes, for reference.
	dd if=/dev/zero bs="$1" count=1 2>/dev/null >"${workFile2}"

	# Run 100 bytes through the program, using the reference file's size
	# as the percentage reference.
	dd if=/dev/zero bs=100 count=1 2>/dev/null \
	| "${testSubject}" -s "@${workFile2}" -n -i 0.1 -L 100 >/dev/null 2>"${workFile1}"

	lineCount=$(wc -l < "${workFile1}" | tr -dc '0-9')
	finalLine=$(sed -n '$p' < "${workFile1}")

	# The number of output lines should be >5 and <13, and the final
	# percentage should be $2.
	#
	if ! test "${lineCount}" -gt 5; then
		echo "(reference size=$1) fewer than 6 output lines (${lineCount})"
		exit 1
	fi
	if ! test "${lineCount}" -lt 13; then
		echo "(reference size=$1) more than 12 output lines (${lineCount})"
		exit 1
	fi
	if ! test "${finalLine}" = "$2"; then
		echo "(reference size=$1): final percentage was not $2 (${finalLine})"
		ls -l "${workFile2}"
		cat "${workFile1}"
		exit 1
	fi
}

sizeCheck 100 100
sizeCheck 200 50
sizeCheck 50 200

exit 0

# EOF
