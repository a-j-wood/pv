#!/bin/sh
#
# Check that there is no SIGPIPE or dropped data on bigger data transfers.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"

# We nead GNU head. On some platforms it is named ghead instead of head.
HEAD="head"
for checkPath in $(echo "${PATH}" | tr ':' '\n')
do
        if test -x "${checkPath}/ghead"
        then
                HEAD="${checkPath}/ghead"
                break
        fi
done

# Check that it really is GNU head, and skip the test if not.
if ! echo | "${HEAD}" -c 10 >/dev/null 2>&1; then
	echo "GNU \`head' is required"
	exit 2
fi

# Don't use dd. See http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=324308
stopAtByteCount="100000000"
#COUNT2=`"${testSubject}" -B 100000 -q /dev/zero | $HEAD -c $COUNT1 | wc -c | tr -d ' '`
# We have to remove \n here, to fix the test on AIX.
bytesTransferred=$("${testSubject}" -B 100000 -q /dev/zero | "${HEAD}" -c "${stopAtByteCount}" | tr -d '\n' | wc -c | tr -dc '0-9')

if ! test "${stopAtByteCount}" = "${bytesTransferred}"; then
	echo "number bytes transferred was not the expected value"
	echo "transferred: ${bytesTransferred}"
	echo "expected: ${stopAtByteCount}"
	exit 1
fi

exit 0

# EOF
