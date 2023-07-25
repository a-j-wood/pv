#!/bin/sh
#
# Check that process ID can be written to a file as described in the manual.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"

# Check we can run "kill -s 0".
if ! kill -s 0 $$ >/dev/null 2>&1; then
	echo "cannot check process existence with \`kill -s 0'"
	exit 2
fi

dd if=/dev/zero bs=150 count=1 2>/dev/null \
| "${testSubject}" -q -L 50 -P "${workFile1}" >/dev/null 2>/dev/null \
&

testPid="$!"
sleep 1

storedPid=$(cat "${workFile1}" 2>/dev/null)

pidValid="0"
kill -s 0 "${storedPid}" 2>/dev/null && pidValid="1"

wait

sleep 1

if test -s "${workFile1}"; then
	echo "PID file was not removed on exit"
	exit 1
fi

true > "${workFile1}"

if ! test "${testPid}" = "${storedPid}"; then
	echo "stored PID [${storedPid}] did not match actual PID [${testPid}]"
	exit 1
fi

if ! test "${pidValid}" = "1"; then
	echo "stored PID [${storedPid}] was not reachable"
	exit 1
fi

exit 0

# EOF
