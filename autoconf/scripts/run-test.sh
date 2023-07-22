#!/bin/sh
#
# Run a test. Parameters are program name and source directory; if
# additional parameters are given, they are the tests to run, otherwise all
# tests are run.
#
# Test scripts should exit 0 if the test passed.
#
# If a test exits with status 2, it is listed as being skipped.
#
# Anything output by a test script on stdout or stderr is captured and shown
# after the "OK"/"FAILED"/"skipped" status.
#

PROG="$1"
SRCDIR="$2"
shift
shift
TESTS="$*"

# Temporary working files
#
TMP1=$(mktemp 2>/dev/null) || TMP1=.tmp1
TMP2=$(mktemp 2>/dev/null) || TMP2=.tmp2
TMP3=$(mktemp 2>/dev/null) || TMP3=.tmp3
TMP4=$(mktemp 2>/dev/null) || TMP4=.tmp4

trap "rm -f ${TMP1} ${TMP2} ${TMP3} ${TMP4}" EXIT

export PROG TMP1 TMP2 TMP3 TMP4	# variables used by test scripts

FAIL=0

test -n "$TESTS" || TESTS=$(ls "$SRCDIR/tests" | sort -n)

MAXNAMESIZE=$(echo "$TESTS" | tr ' ' '\n' | sed 's,^.*/,,;s/-/ - /' | awk 'BEGIN{m=0} {n=length($0);if (n>m) m=n} END{print m}')
test -n "$MAXNAMESIZE" || MAXNAMESIZE=1
test "$MAXNAMESIZE" -lt 10 && MAXNAMESIZE=10
test "$MAXNAMESIZE" -gt 60 && MAXNAMESIZE=60

for SCRIPT in $TESTS; do
	test -f "$SCRIPT" || SCRIPT="$SRCDIR/tests/$SCRIPT"
	test -f "$SCRIPT" || SCRIPT=$(ls "$SRCDIR/tests/$SCRIPT"*)
	test -f "$SCRIPT" || continue

	printf "%-${MAXNAMESIZE}.${MAXNAMESIZE}s " "$(echo "${SCRIPT}" | sed 's,^.*/,,;s/-/ - /')"

	TESTEXITSTATUS=0
	TESTOUTPUT=""
	TESTOUTPUT=$(sh -e "$SCRIPT" 2>&1)
	TESTEXITSTATUS=$?

	TESTRESULT=""
	if test $TESTEXITSTATUS -eq 0; then
		TESTRESULT="OK"
	elif test $TESTEXITSTATUS -eq 2; then
		TESTRESULT="skipped"
	else
		TESTRESULT="FAILED"
		FAIL=1
	fi

	test -n "${TESTOUTPUT}" && TESTOUTPUT=" - ${TESTOUTPUT}"

	printf "%s%s\n" "${TESTRESULT}" "${TESTOUTPUT}"
done

rm -f "$TMP1" "$TMP2" "$TMP3" "$TMP4"
trap "" EXIT

exit $FAIL

# EOF
