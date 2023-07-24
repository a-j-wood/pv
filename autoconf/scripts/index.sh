#!/bin/sh
#
# Script to generate an HTML index of all C code from the current directory
# downwards (skipping directories ending in ~). The header comment in each
# file is listed, and each function's prototype and comment are given. A
# list of "TODO:" comments is also generated.
#
# Outputs the HTML on standard output.
#
# If a parameter is given, it is the prefix to put before any "view file"
# links, eg ".." to link to "../dir/file.c" instead of "dir/file.c".
#
# Skips any files containing the string !NOINDEX.
#
# Requires ctags and cproto.
#

command -v "ctags" >/dev/null 2>&1  || { echo "${0##*/}: ctags: command not found" 1>&2; exit 1; }
command -v "cproto" >/dev/null 2>&1 || { echo "${0##*/}: cproto: command not found" 1>&2; exit 1; }

linkPrefix=$1
test -n "${linkPrefix}" || linkPrefix="."

# Add "/" to the link prefix, and empty it entirely if it ends up just "./".
linkPrefix=$(echo "${linkPrefix}" | sed 's,/*$,,')
test "$linkPrefix" = "." && linkPrefix="" || linkPrefix="${linkPrefix}/"

# Convert the given string to HTML-escaped values (<, >, & escaped) on
# stdout.
#
html_safe () {
	echo "$*" \
	| sed -e 's|&|\&amp;|g;s|<|\&lt;|g;s|>|\&gt;|g'
}


# Convert the given string to HTML-escaped values (<, >, & escaped) on
# stdout, also adding a <BR> to the end of each line.
#
html_safebr () {
	echo "$*" \
	| sed -e 's|&|\&amp;|g;s|<|\&lt;|g;s|>|\&gt;|g;s/$/<BR>/'
}

allEligibleFiles=$(
  find . -name '*~' -prune -o -type f -name '*.c' \
       -exec grep -FL '!NOINDEX' /dev/null '{}' ';'
)

ctagsOutput=$(
  echo "${allEligibleFiles}" \
  | ctags -nRf- -L- --c-types=f \
  | sed 's/	.\//	/;s/;"	.*$//'
)

sourceFiles=$(echo "${ctagsOutput}" | cut -d '	' -f 2 | sort | uniq)

echo '<HTML><HEAD>'
echo '<TITLE>Source Code Index</TITLE>'
echo '</HEAD><BODY>'
echo '<H1><A NAME="top">Source Code Index</A></H1>'
echo '<P><UL>'
echo '<LI><A HREF="#files">File Listing</A></LI>'
echo '<LI><A HREF="#funcs">Function Listing</A></LI>'
echo '<LI><A HREF="#todo">To-Do Listing</A></LI>'
echo '</UL></P>'

echo '<H2><A NAME="files">File Listing</A></H2>'
echo '<P><UL>'
echo "${sourceFiles}" \
| sed -e \
  's|^.*$|<LI><CODE CLASS="filename"><A HREF="#file-\0">\0</A></CODE></LI>|'
echo '</UL></P>'

for sourceFile in ${sourceFiles}; do

	sourceDir="${sourceFile##*/}"
	test "${sourceDir}" = "${sourceFile}" && sourceDir="."
	functionPrototypes=$(
	  cproto -f1 -I. -Isrc/include -I"${sourceDir}" "${sourceFile}" 2>/dev/null \
	  | sed -n 's/^.*[ *]\([^ *(]*\)(.*$/\1/p'
	)
	fileHeaderComment=$(
	  sed -n -e '1,/\*\//{/\/\*/,/\*\//{s/^[\/ *]//;s/^\*[\/]*//;p;};}' \
          < "${sourceFile}"
        )
	fileShortDescription=$(echo "${fileHeaderComment}" | sed -n '1,/^ *$/{/^ *[^ ]*/p;}')
	fileLongDescription=$(echo "${fileHeaderComment}" | sed '1,/^ *$/d')

	echo '<P><HR WIDTH="100%"></P>'
	echo '<P><TABLE BORDER="0"><TR>'
	echo '<TD VALIGN="TOP"><CODE CLASS="filename">'
	echo '<A NAME="file-'"${sourceFile}"'">'"${sourceFile}"'</A></CODE></TD>'
	echo '<TD VALIGN="TOP"> - </TD>'
	echo '<TD VALIGN="TOP">'"$(html_safe "${fileShortDescription}")"'</TD>'
	echo '</TR></TABLE></P>'
	echo '<P><SMALL>[<A HREF="'"${linkPrefix}${sourceFile}"'">View File</A>]</SMALL></P>'
	echo '<P><BLOCKQUOTE>'
	html_safebr "${fileLongDescription}"
	echo '</BLOCKQUOTE></P>'

	if [ -n "${functionPrototypes}" ]; then
		echo '<P>Functions defined:</P>'
		echo '<P><UL>'
		echo "${functionPrototypes}" \
		| sed 's|^.*$|<A HREF="#func-\0---'"${sourceFile}"'">\0</A>|' \
		| sed 's/^/<LI><CODE CLASS="funcname">/;s|$|</CODE></LI>|'
		echo '</UL></P>'
	fi

	echo '<P ALIGN="RIGHT"><SMALL CLASS="navbar">['
	echo '<A HREF="#top">Top</A> |'
	echo '<A HREF="#todo">To Do</A> |'
	echo '<A HREF="#funcs">Functions</A> ]</SMALL></P>'
done

echo '<H2><A NAME="funcs">Function Listing</A></H2>'
echo '<P><UL>'

echo "${ctagsOutput}" | while read -r functionName sourceFile sourceLineNo restOfLine; do
	echo '<LI><CODE CLASS="funcname"><A' \
	  'HREF="#func-'"${functionName}"'---'"${sourceFile}"'">'"${functionName}"'</A></CODE>' \
	  '[<CODE CLASS="filename">'"${sourceFile}"'</CODE>]</LI>'
done
echo '</UL></P>'

# shellcheck disable=SC2034
echo "${ctagsOutput}" | while read -r functionName sourceFile sourceLineNo restOfLine; do

	functionPrototype=$(
	  sed -n "${sourceLineNo},/{/p" < "${sourceFile}" \
	  | tr '\n' ' ' \
	  | tr -d '{'
	)

	lastCommentOpenLineNo=$(sed -n '1,'"${sourceLineNo}"'{/\/\*/=;}' < "${sourceFile}" | sed -n '$p')
	test -n "${lastCommentOpenLineNo}" || lastCommentOpenLineNo=1
	lastCommentCloseLineNo=$(sed -n '1,'"${sourceLineNo}"'{/}/=;}' < "${sourceFile}" | sed -n '$p')
	test -n "${lastCommentCloseLineNo}" || lastCommentCloseLineNo=1
	functionHeaderComment=$(
	  sed -n -e \
	  "${lastCommentOpenLineNo},"'/\*\//{h;s/^[\/ *]//;s/^\*[\/]*//;p;x;/\*\//q;}' \
	  < "${sourceFile}"
	)
	test "${lastCommentOpenLineNo}" -le "${lastCommentCloseLineNo}" && functionHeaderComment=""

	echo '<P><HR WIDTH="100%"></P>'
	echo '<P ALIGN="LEFT">'
	echo '<CODE CLASS="funcname"><A' \
	  'NAME="func-'"${functionName}"'---'"${sourceFile}"'">'"${functionName}"'</A></CODE>' \
	  '[<CODE CLASS="filename"><A HREF="#file-'"${sourceFile}"'">'"${sourceFile}"'</A></CODE>]'
	echo '</P>'

	echo '<P><CODE CLASS="funcdef">'"$(html_safe "${functionPrototype}")"'</CODE></P>'

	echo '<P><BLOCKQUOTE>'
	html_safebr "${functionHeaderComment}"
	echo '</BLOCKQUOTE></P>'

	echo '<P ALIGN="RIGHT"><SMALL CLASS="navbar">['
	echo '<A HREF="#top">Top</A> |'
	echo '<A HREF="#todo">To Do</A> |'
	echo '<A HREF="#files">Files</A> ]</SMALL></P>'
done

echo '<H2><A NAME="todo">To Do Listing</A></H2>'
echo '<P><UL>'
for sourceFile in ${sourceFiles}; do

	todoLineNumbers=$(sed -n \
	               -e '/\/\*.*\*\//!{/\/\*/,/\*\//{/TODO:/{=;};};}' \
	               -e '/\/\*.*\*\//{/TODO:/{=;};}' \
	           < "${sourceFile}")

	test -n "${todoLineNumbers}" || continue

	echo '<LI><CODE CLASS="filename"><A' \
	  'HREF="#file-'"${sourceFile}"'">'"${sourceFile}"'</A></CODE>'
	echo '<UL>'

	for todoLineNo in ${todoLineNumbers}; do
		todoNote=$(sed -n "${todoLineNo}"'{s/^.*TODO://;s/\*\/.*$//;p;}' < "${sourceFile}")
		echo "<LI>[<B>${todoLineNo}</B>] $(html_safe "${todoNote}")</LI>"
	done

	echo '</UL></LI>'
done

echo '</BODY></HTML>'

# EOF
