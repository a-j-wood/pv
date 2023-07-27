#!/bin/sh
#
# Parameters: testSubject sourcePath [testScript...]
#
# Run one or more test scripts.  The ${testSubject} is the path of the test
# subject program, and the ${sourcePath} is the path to the top level of the
# source directory.  If any ${testScript} parameters are given, they are the
# tests to run (each one being either the full path to a script, or the base
# filename of the script in the test directory).  If no test scripts are
# listed, then all tests directly under "${sourcePath}/tests/" are run.
#
# Test scripts should be written to exit 0 if the test passed, 2 if the test
# is to be skipped, or any other exit status to indicate failure.  They are
# run via "sh -e", so any command exiting non-zero will cause the test
# script to exit early.
#
# The test scripts can rely on the environment variables "testSubject",
# "sourcePath", "workFile1", "workFile2", "workFile3", and "workFile4" being
# populated, and should use those work files - which will be present and
# empty - for scratch space.  They should not delete those files.
#
# When the test scripts are called, LANG and LC_ALL are set to "C".
#
# Anything output by a test script on stdout or stderr is captured and shown
# after the "OK" / "FAILED" / "skipped" result description.
#
# The exit status of this script will be 1 if any test failed, 0 otherwise. 
# A skipped test is not counted as a failure.
#

# Parameters.
testSubject="$1"
sourcePath="$2"
shift
shift
selectedTests="$*"

# Constants.
formatCodesPass="setaf 2;bold"	# terminal capabilities for "pass" formatting
formatCodesFail="setaf 1;bold"	# terminal capabilities for "fail" formatting
formatCodesSkip="setaf 3"	# terminal capabilities for "skip" formatting
formatCodesZero="setaf 4"	# terminal capabilities for zero result

# Temporary working files, for the test scripts to use.
workFile1=$(mktemp 2>/dev/null) || workFile1="./.tmp1"
workFile2=$(mktemp 2>/dev/null) || workFile2="./.tmp2"
workFile3=$(mktemp 2>/dev/null) || workFile3="./.tmp3"
workFile4=$(mktemp 2>/dev/null) || workFile4="./.tmp4"

# Clean up the temporary files on exit, in case we are interrupted.
trap 'rm -f "${workFile1}" "${workFile2}" "${workFile3}" "${workFile4}"' EXIT

# Variables used by the test scripts.
export testSubject sourcePath workFile1 workFile2 workFile3 workFile4

# Set everything to the "C" locale.
LANG=C
LC_ALL=C
export LANG LC_ALL

# If no tests were specified, list all test scripts under the source path.
test -n "${selectedTests}" || selectedTests=$(find "${sourcePath}/tests" -maxdepth 1 -type f | sort -n)

# Initial pass to count the number of tests and find the length of the
# longest test name, to use when formatting the output.
#
numberOfTests=0
maxTestNameLength=0
for testScript in ${selectedTests}; do
	# Find the test script, make sure it exists.
	test -f "${testScript}" || testScript="${sourcePath}/tests/${testScript}"
	test -f "${testScript}" || testScript=$(find "${sourcePath}/tests" -maxdepth 1 -type f -name "${testScript##*/}*" | sed -n '1p')
	test -f "${testScript}" || continue

	numberOfTests=$((1+numberOfTests))

	testScriptLeaf="${testScript##*/}"
	testName="$(echo "${testScriptLeaf%.sh}" | tr '_' ' ' | sed 's/ - /: /')"
	testNameLength=${#testName}
	test "${testNameLength}" -gt "${maxTestNameLength}" && maxTestNameLength="${testNameLength}"
done

# Set a minimum and maximum test name length.
test "${maxTestNameLength}" -lt 10 && maxTestNameLength=10
test "${maxTestNameLength}" -gt 60 && maxTestNameLength=60

# Count the number of digits in the number of tests so we know how wide the
# column for the test count should be.
testCountWidth=${#numberOfTests}

# Get the terminal width, for later display formatting calculations.
#
# We have to fiddle with `stty' because $COLUMNS is only in `bash', `resize`
# is not available everywhere, and `stty' itself varies in its output format
# between "columns 158" and "158 cols".
#
terminalWidth=80
test -t 1 && terminalWidth=$(stty -a 2>/dev/null | tr ';' '\n' | grep -e cols -e columns | tr ' ' '\n' | grep '[0-9]' | sed -n 1p)
test -n "${terminalWidth}" || terminalWidth=80

# Remaining space left on each line after the result description.
colsUsed=$((testCountWidth + 1 + testCountWidth + 2 + maxTestNameLength + 2 + 8 + 2))
colsRemaining=0
test "${colsUsed}" -lt "${terminalWidth}" && colsRemaining=$((terminalWidth - colsUsed))

# Run all of the selected test scripts, formatting the output.
#
testPassCount=0
testFailCount=0
testSkipCount=0
testNumber=0
for testScript in ${selectedTests}; do
	# Find the test script, make sure it exists.
	test -f "${testScript}" || testScript="${sourcePath}/tests/${testScript}"
	test -f "${testScript}" || testScript=$(find "${sourcePath}/tests" -maxdepth 1 -type f -name "${testScript##*/}*" | sed -n '1p')
	test -f "${testScript}" || continue

	testNumber=$((1+testNumber))

	testScriptLeaf="${testScript##*/}"
	testName="$(echo "${testScriptLeaf%.sh}" | tr '_' ' ' | sed 's/ - /: /')"
	printf "%${testCountWidth}d/%d: %-${maxTestNameLength}.${maxTestNameLength}s  " "${testNumber}" "${numberOfTests}"  "${testName}"

	# Run the test script, capturing the output and the exit status.
	testExitStatus=0
	testOutput=""
	if test -s "${testScript}"; then
		true > "${workFile1}"
		true > "${workFile2}"
		true > "${workFile3}"
		true > "${workFile4}"
		testOutput=$(sh -e "${testScript}" 2>&1)
		testExitStatus=$?
	else
		testOutput="test script has not yet been written"
		testExitStatus=2
	fi

	# Work out what we're going to say about this test result.
	testResultDescription=""
	resultFormatCodes=""
	if test ${testExitStatus} -eq 0; then
		resultFormatCodes="${formatCodesPass}"
		testResultDescription="OK"
		testPassCount=$((1+testPassCount))
	elif test ${testExitStatus} -eq 2; then
		resultFormatCodes="${formatCodesSkip}"
		testResultDescription="skipped"
		testSkipCount=$((1+testSkipCount))
	else
		resultFormatCodes="${formatCodesFail}"
		testResultDescription="FAILED"
		testFailCount=$((1+testFailCount))
	fi

	# If stdout is not a terminal, don't use terminal format codes.
	test -t 1 || resultFormatCodes=""

	# Show the description of the test result, and start a new line.
	test -n "${resultFormatCodes}" && command -v tput >/dev/null 2>&1 && echo "${resultFormatCodes}" | tr ';' '\n' | tput -S 2>/dev/null
	printf "%s" "${testResultDescription}"

	# If there was any output from the test, display it - either on the
	# current line, if there's space, or the next line, with each line
	# prefixed with the test number.
	if test -n "${testOutput}"; then
		if test "${#testOutput}" -lt "${colsRemaining}" && ! test "$(echo "${testOutput}" | wc -l | tr -dc '0-9')" -gt 1 2>/dev/null; then
			printf " - %s" "${testOutput}"
		else
			printf "\n%s" "$(echo "${testOutput}" | sed "s,^,$(printf "%${testCountWidth}d/%d: - " "${testNumber}" "${numberOfTests}"),")"
		fi
	fi
	printf "\n"

	test -n "${resultFormatCodes}" && command -v tput >/dev/null 2>&1 && tput sgr0 2>/dev/null
done

# Clean up.
rm -f "${workFile1}" "${workFile2}" "${workFile3}" "${workFile4}"
trap '' EXIT

# Report the totals.
printf "\n"
printf "%s: " "Tests passed"
numberFormatting="${formatCodesPass}"
test "${testPassCount}" -gt 0 || numberFormatting="${formatCodesZero}"
test -t 1 && command -v tput >/dev/null 2>&1 && echo "${numberFormatting}" | tr ';' '\n' | tput -S 2>/dev/null
printf "%d" "${testPassCount}"
test -t 1 && command -v tput >/dev/null 2>&1 && tput sgr0 2>/dev/null

printf "   %s: " "Tests failed"
numberFormatting="${formatCodesFail}"
test "${testFailCount}" -gt 0 || numberFormatting="${formatCodesZero}"
test -t 1 && command -v tput >/dev/null 2>&1 && echo "${numberFormatting}" | tr ';' '\n' | tput -S 2>/dev/null
printf "%d" "${testFailCount}"
test -t 1 && command -v tput >/dev/null 2>&1 && tput sgr0 2>/dev/null

printf "   %s: " "Tests skipped"
numberFormatting="${formatCodesSkip}"
test "${testSkipCount}" -gt 0 || numberFormatting="${formatCodesZero}"
test -t 1 && command -v tput >/dev/null 2>&1 && echo "${numberFormatting}" | tr ';' '\n' | tput -S 2>/dev/null
printf "%d" "${testSkipCount}"
test -t 1 && command -v tput >/dev/null 2>&1 && tput sgr0 2>/dev/null
printf "\n"

# Exit with status 1 if any test failed outright, 0 otherwise.
test "${testFailCount}" -eq 0 || exit 1
exit 0

# EOF
