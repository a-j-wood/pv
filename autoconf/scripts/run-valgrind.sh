#!/bin/sh
#
# Function to launch the test subject under valgrind.
#
# If valgrind is unavailable, exits the script with status 2, after writing
# a note to file descriptor 4.
#
# If valgrind finds an error, writes the error to "valgrind.out" in the
# current directory, and exits the script with status 1 after writing a note
# to file descriptor 4.
#
# If valgrind does not find any errors, the function returns with the exit
# status of the test subject.
#
# Source this file from test scripts that use valgrind.
#
# Requires ${testSubject} and ${workFile4}.  This means that the caller must
# not use file ${workFile4}, as this function will overwrite it.
#

# Output file for failures.
valgrindOutputFile="valgrind.out"

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile4="${workFile4:-.tmp4}"

if ! command -v valgrind >/dev/null 2>&1; then
	echo "test requires \`valgrind'"
	exit 2
fi

runWithValgrind () {

	valgrind --tool=memcheck \
	  --verbose --show-error-list=yes --log-fd=3 \
	  --error-exitcode=125 \
	  --track-fds=yes \
	  --leak-check=full \
	  "${testSubject}" "$@" \
	  3>"${workFile4}" 4<&-

	returnValue=$?

	if test "${returnValue}" -eq 125; then
		{
		echo "================================================"
		date
		echo "Command: ${testSubject} $*"
		echo
		cat "${workFile4}"
		echo "================================================"
		echo
		} >> "${valgrindOutputFile}"
		echo "memory check failed - see file \`valgrind.out'." 1>&4
		exit 1
	fi

	return "${returnValue}"
}

# EOF
