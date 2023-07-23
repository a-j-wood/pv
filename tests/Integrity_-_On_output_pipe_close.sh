#!/bin/sh
#
# Check that there is no SIGPIPE or dropped data on bigger data transfers.

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
COUNT1=100000000
#COUNT2=`"${testSubject}" -B 100000 -q /dev/zero | $HEAD -c $COUNT1 | wc -c | tr -d ' '`
# Remove \n to fix the test on AIX
COUNT2=$("${testSubject}" -B 100000 -q /dev/zero | "${HEAD}" -c $COUNT1 | tr -d '\n' | wc -c | tr -d ' ')

#echo "[$COUNT1] [$COUNT2]"

test "x${COUNT1}" = "x${COUNT2}"

# EOF
