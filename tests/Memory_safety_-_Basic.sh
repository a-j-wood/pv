#!/bin/sh
#
# Run valgrind's memory checker against a process using various different
# transfer options.

# Dummy assignments for "shellcheck".
sourcePath="${sourcePath:-.}"; testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"; workFile3="${workFile3:-.tmp3}"; workFile4="${workFile4:-.tmp4}"

# Load the valgrind function.
. "${sourcePath}/autoconf/scripts/run-valgrind.sh"

# Plain, no options.
{ echo "testing" | runWithValgrind >/dev/null 2>&1; } 4>&1 || exit 1

# With --force.
{ echo "testing" | runWithValgrind -f >/dev/null 2>&1; } 4>&1 || exit 1

# Check "--average-rate".
(dd if=/dev/zero bs=100 count=1 2>/dev/null;
 sleep 1;
 dd if=/dev/zero bs=110 count=1 2>/dev/null;
 sleep 1;
) | { runWithValgrind -f -i 0.5 -a >/dev/null 2>"${workFile1}"; } 4>&1 || exit 1

# Check "--buffer-size" and "--buffer-percent".
{ \
  ( dd if=/dev/zero bs=1024 count=1024; sleep 2; ) 2>/dev/null \
  | runWithValgrind -f -T -i 0.5 -B 1024 2>"${workFile1}" \
  | (sleep 1; dd bs=1024 count=512; sleep 1; cat; ) >/dev/null 2>&1; \
} 4>&1 || exit 1

# Check "--numeric" "--bytes" "--line-mode".
seq -w 3 1 100 \
| { runWithValgrind -bnl -i 0.2 -f -L 100 2>"${workFile1}" > "${workFile2}"; } 4>&1 || exit 1

exit 0

# EOF
