#!/bin/sh
#
# Run valgrind's memory checker while receiving remote control commands.

# Dummy assignments for "shellcheck".
sourcePath="${sourcePath:-.}"; testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"; workFile3="${workFile3:-.tmp3}"; workFile4="${workFile4:-.tmp4}"

# Do nothing if IPC is not supported.
if ! "${testSubject}" -h 2>/dev/null | grep -Eq "^  -R,"; then
	echo "IPC is not supported on this platform"
	exit 2
fi

# Load the valgrind function.
. "${sourcePath}/autoconf/scripts/run-valgrind.sh"

dd if=/dev/urandom of="${workFile1}" bs=1024 count=10240 2>/dev/null

# Check from the POV of the process being controlled.
true > "${workFile3}"
(
set +e
while ! test -s "${workFile3}"; do usleep 200000 2>/dev/null || sleep 1; done
for loopCount in 1 2 3; do
	"${testSubject}" -R "$(cat "${workFile3}")" -apterb	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R "$(cat "${workFile3}")" -p		|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R "$(cat "${workFile3}")" -N "test"	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R "$(cat "${workFile3}")" -F "%e"	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	"${testSubject}" -R "$(cat "${workFile3}")" -N "."	|| exit 1
	(usleep 200000 || sleep 1) 2>/dev/null
	echo "${loopCount}" >/dev/null	# dummy for shellcheck
done
"${testSubject}" -R "$(cat "${workFile3}")" -L 10M
) &
{ runWithValgrind -L 100k -i 0.1 -f -P "${workFile3}" "${workFile1}" > "${workFile2}" 2>/dev/null; } 4>&1 || exit 1

exit 0

# EOF
