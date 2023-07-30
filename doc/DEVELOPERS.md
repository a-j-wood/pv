Notes for developers and translators
====================================

The following "`configure`" options will be of interest to developers and
translators:

 * `--enable-debugging` - build in debugging support
 * `--enable-profiling` - build in support for profiling
 * `--enable-static-nls` - compile translations directly into the program

These "`make`" targets are available:

 * `make help` - describe all of the "`.PHONY`" targets
 * `make index` - generate a source code index
 * `make analyse` - run _splint_ and _flawfinder_ on all C source files


Debugging and profiling support
-------------------------------

When "`./configure --enable-debugging`" is used, the "`pv`" produced by
"`make`" will support an extra option, "`--debug FILE`", which will cause
debugging output to be written to *FILE*.  This is not recommended for
production builds due to the extra processing it introduces, and the
potential size of the output.

Within the code, "`debug()`" is used in a similar way to "`printf()`".  It
will automatically include the calling function, source file, and line
number, so they don't need to be included in the parameters.  When debugging
support is not enabled, it evaluates to a null statement.

This does mean that if you call "`debug()`", make sure it has no side
effects, as they won't be present in builds without debugging support.

Builds produced after "`./configure --enable-profiling`" will write profile
data when run, to be used with _gprof_.  See "`man gprof`" for details.


Source code indexing
--------------------

Running "`make index`" calls a script which uses _cproto_ and _ctags_ to
generate a single file, "`index.html`", which lists all C source files, all
functions within them, and all TODOs marked in the code.

It relies on each function having a comment block directly before it,
describing what it does.

The indexing script pre-dates the author's knowledge of documentation
generation tools like Doxygen, and is over 20 years old.  If it contains
bugs, then rather than fixing them, it may be worth looking at how to alter
the C sources to better suit widely available documentation generation
tools.  Please open issues or start discussions about this if it comes up.


Source code analysis
--------------------

Running "`make analyse`" runs _splint_ and _flawfinder_ on all C sources,
writing the output of both programs to files named "`*.e`" for each "`*.c`".

There are no dependency rules set up for these "`.e`" files, so if a header
file is altered, either run "`make analysisclean`", manually remove the
relevant "`.e`" files, or update the timestamp of the relevant "`.c`" files
before running "`make analyse`" again.

The eventual goal is for all C source files to generate zero warnings from
either tool.


Translation notes
-----------------

The message catalogues used to translate program messages into other
languages are in the "`src/nls/`" directory, named "`xx.po`", where "`xx`"
is the ISO 639-1 2-letter language code, such as "`fr`" for French.

Each of these files contains lines like this:

    #: src/pv/cursor.c:85
    msgid "failed to get terminal name"
    msgstr "erro ao ler o nome do terminal"

The comment line, starting "`#`", shows the source filename and line number
at which this message can be found.  The "`msgid`" is the original message
in the program, in English.  The "`msgstr`" is the translated text.

It is the "`msgstr`" lines which need to be updated by translators.

Message catalogue files should all be encoded as UTF-8.

To quickly test translations, use "`./configure --enable-static-nls`".  This
is not recommended for production use, because it replaces the system
internationalisation libraries with some very simplistic alternatives, but
it has the benefit of compiling the message catalogues directly into the
program.

This means that after making a change to a "`.po`" file, do this:

    make
    LANG=de LC_ALL=en_GB.UTF-8 ./pv --help

Replace "`--help`" with whatever is appropriate for your test.  In this
example, the language being tested is "`de`" (German), on a system which is
otherwise running in English with UTF-8 support.

To add a new language, edit "`autoconf/configure.in`".  Look for this line:

    for lang in de fr pl pt; do

Add the new language code before the "`; do`".

Create the new message catalogue file under "`src/nls/`" by copying
"`src/nls/pv.pot`" to "`src/nls/xx.po`", where "`xx`" is the language code,
and adjusting it.

Then run "`./generate.sh`" to generate a new "`configure`" script; you will
need to run "`./configure --enable-static-nls`" and "`make`" afterwards.

When the source code is updated, running "`make`" will update the "`pv.pot`"
file so that it lists where all the messages are in the source, and running
"`make update-po`" will use _msgmerge_ to update all of the "`.po`" files
from the updated "`pv.pot`" file.  After doing this, look for missing
translations (empty "`msgstr`" lines) or translations marked as "fuzzy", as
these will need to be corrected by translators.
