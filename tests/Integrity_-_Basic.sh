#!/bin/sh
#
# Check that data can be just passed straight through.

# Dummy assignment for "shellcheck".
testSubject="${testSubject:-false}"

inputString="TESTING"
outputString=$(printf "%s" "${inputString}" | "${testSubject}" 2>/dev/null) || { echo "unexpected failure code"; exit 1; }

if ! test "${inputString}" = "${outputString}"; then
	echo "output did not match input"
	exit 1
fi

# Test again with --force.
inputString="TESTINGAGAIN"
outputString=$(printf "%s" "${inputString}" | "${testSubject}" -f 2>/dev/null) || { echo "unexpected failure code"; exit 1; }

if ! test "${inputString}" = "${outputString}"; then
	echo "output did not match input when using --force"
	exit 1
fi

exit 0

# EOF
