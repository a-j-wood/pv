#!/bin/sh
#
# Generate Makefile components "filelist.mk~" (list source, object, and
# dependency files) and "modules.mk~" (linking rules for each directory's
# overall object file) by scanning the directory "src" for files ending in
# ".c", and for subdirectories not starting with "_".
#
# Modules live inside subdirectories called [^_]* - i.e. a directory "foo" will
# have a rule created which links all code inside it to "foo.o".
#
# The directory "src/include" is never scanned; neither are CVS or SVN
# directories.
#

listingsFile="$1"
linkingRulesFile="$2"

FIND="find"
GREP="grep"
command -v gfind 2>/dev/null | grep /gfind >/dev/null && FIND="gfind"
command -v which ggrep 2>/dev/null | grep /ggrep >/dev/null && GREP="ggrep"

{
echo '# Automatically generated file listings'
echo '#'
echo "# Creation time: $(date)"
echo
} > "${listingsFile}"

{
echo '# Automatically generated module linking rules'
echo '#'
echo "# Creation time: $(date)"
echo
} > "${linkingRulesFile}"

printf "%s" "Scanning for source files: "

allsrc=$("${FIND}" src -type f -name "*.c" -print)
allobj=$(echo "${allsrc}" | tr ' ' '\n' | sed 's/\.c$/.o/')
alldep=$(echo "${allsrc}" | tr ' ' '\n' | sed 's/\.c$/.d/')

echo "$(echo "${allsrc}" | wc -w | tr -d ' ') found"

printf "%s" "Scanning for modules: "

modules=$("${FIND}" src -type d -print \
         | "${GREP}" -v '^src$' \
         | "${GREP}" -v '/_' \
         | "${GREP}" -v '^src/include' \
         | "${GREP}" -v 'CVS' \
         | "${GREP}" -v '.svn' \
         | while read -r DIR; do \
           CONTENT=$(/bin/ls -d "${DIR}"/* \
                     | "${GREP}" -v '.po$' \
                     | "${GREP}" -v '.gmo$' \
                     | "${GREP}" -v '.mo$' \
                     | "${GREP}" -v '.h$' \
                     | sed -n '$p'); \
           [ -n "$CONTENT" ] || continue; \
           echo "${DIR}"; \
	   done
         )

echo "up to $(echo "${modules}" | wc -w | tr -d ' ') found"

echo "Writing module linking rules"

printf "%s" "["
for i in ${modules}; do printf "%s" " "; done
printf "%s\r%s" "]" "["

for i in ${modules}; do
  printf "%s" "."
  allobj="${allobj} ${i}.o"
  deps=""
  for j in "${i}"/*.c; do
    [ -f "$j" ] || continue
    newobj=$(echo "$j" | sed -e 's@\.c$@.o@')
    deps="$deps $newobj"
  done
  for j in "${i}"/*; do
    [ -d "$j" ] || continue
    [ "$(basename "$j")" = "CVS" ] && continue
    [ "$(basename "$j")" = ".svn" ] && continue
    CONTENT=$(/bin/ls -d "$j"/* \
             | "${GREP}" -v '.po$' \
             | "${GREP}" -v '.gmo$' \
             | "${GREP}" -v '.mo$' \
             | "${GREP}" -v '.h$' \
             | sed -n '$p')
    [ -n "$CONTENT" ] || continue
    deps="$deps $j.o"
  done
  [ -n "$deps" ] || continue
  {
  echo "$i.o: $deps"
  echo "	\$(LD) \$(LDFLAGS) -o \$@ $deps"
  echo
  } >> "${linkingRulesFile}"
done

echo ']'

echo "Listing source, object and dependency files"

{
printf "%s" "allsrc = "
echo "$allsrc" | tr '\n' ' ' | sed 's,src/nls/cat-id-tbl.c,,' | sed -e 's/ $//;s/ / \\!/g' \
| tr '!' '\n'
echo
echo
printf "%s" "allobj = "
echo "$allobj" | tr '\n' ' ' | sed -e 's/ $//;s/ / \\!/g' | tr '!' '\n'
echo
echo
printf "%s" "alldep = "
echo "$alldep" | tr '\n' ' ' | sed -e 's/ $//;s/ / \\!/g' | tr '!' '\n'
echo
echo
} >> "${listingsFile}"

echo >> "${linkingRulesFile}"

# EOF
