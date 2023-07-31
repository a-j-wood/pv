#!/bin/sh
#
# Check that the terminal width is detected on startup.

# Dummy assignments for "shellcheck".
testSubject="${testSubject:-false}"; workFile1="${workFile1:-.tmp1}"; workFile2="${workFile2:-.tmp2}"

# Skip the test if `tmux' is not available.
if ! command -v tmux >/dev/null 2>&1; then
	echo "test requires \`tmux'"
	exit 2
fi

# Skip the test if `tmux' does not have "-C".
if echo "kill-server" | tmux -C -L pvtest 2>&1 | grep -Fq "tmux: unknown option"; then
	echo "test requires a newer \`tmux'"
	exit 2
fi

# Run a progress meter inside a terminal of the given width, and output the
# longest number of characters seen between "[" and "]".
#
runWidthTest () {
	terminalWidth="$1"

	{
	echo "set remain-on-exit on"
	echo "new-session -d"
	echo "resize-window -x ${terminalWidth} -y 5"
	echo "pipe-pane 'cat > ${workFile1}'"
	echo "respawn-pane -k sh -c \"${testSubject} -pSs 1K </dev/zero >/dev/null\""
	sleep 1
	echo "kill-server"
	sleep 1
	} \
	| tmux -C -L pvtest >/dev/null

	tr '\r' '\n' < "${workFile1}" \
	| sed -n 's/^.*\[//;s/\].*$//p' \
	| awk 'BEGIN {m=0} {n=length($0); m=(n>m?n:m)} END {print m}'
}


# Perform a test run of the given width and exit on failure.  The longest
# bar found by runWidthTest() should be the width of the terminal minus the
# "[] 100%" characters, i.e. 7 less.
#
widthTest () {
	terminalWidth="$1"
	longestBar=$(runWidthTest "${terminalWidth}")
	if test -z "${longestBar}"; then
		echo "no output from test at width=${terminalWidth}"
		exit 1
	elif ! test "${longestBar}" -eq $((terminalWidth-7)); then
		echo "bar size incorrect (${longestBar}) at width=${terminalWidth})"
		exit 1
	fi
}

widthTest 80
widthTest 120
widthTest 400
widthTest 20

exit 0

# EOF
