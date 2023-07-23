#!/bin/sh
#
# Check that data can be just passed straight through.

# Dummy assignment for "shellcheck".
testSubject="${testSubject:-false}"

inputString="TESTING"
outputString=$(printf "%s" "${inputString}" | "${testSubject}" 2>/dev/null) || { echo "unexpected failure code"; exit 1; }

test "${inputString}" = "${outputString}" && exit 0
echo "output did not match input"
exit 1

# EOF
