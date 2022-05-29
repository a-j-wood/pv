Introduction
------------

This is the README for **pv** ("Pipe Viewer"), a terminal-based tool for
monitoring the progress of data through a pipeline.  It can be inserted into
any normal pipeline between two processes to give a visual indication of how
quickly data is passing through, how long it has taken, how near to
completion it is, and an estimate of how long it will be until completion.


Documentation
-------------

A manual page is included in this distribution.  See "`man ./doc/quickref.1`",
or "`man pv`" after installation.


Compilation
-----------

If this is not a packaged release, first run "`./generate.sh`".

To compile the package, type "`sh ./configure`", which should generate a
Makefile for your system.  You may then type "`make`" to build everything.
Note that GNU _make_ is required; this may be installed as _gmake_ on some
systems, so if typing "`make`" gives an error, try "`gmake`" instead.

See the file "doc/INSTALL" for more about the _configure_ script.

Developers note that you can run "`./configure --enable-debugging`" to cause
debugging support to be built in, and the `--enable-profiling` option builds
in profiling support (see "`man gprof`").  Also note that running
"`make index`" will generate an HTML code index (using _ctags_ and
_cproto_); this index lists all files used, all functions defined, and all
TODOs marked in the code.


Author and acknowledgements
---------------------------

This package is copyright 2022 Andrew Wood, and is being distributed under
the terms of the Artistic License 2.0.  For more details of this license,
see the file "doc/COPYING".

Report bugs in **pv** using the contact form linked from the home page, or
though the [project issue tracker](https://github.com/a-j-wood/pv/issues).

The `pv' home page is at:

  http://www.ivarch.com/programs/pv.shtml

The latest version can always be found here.

**Please see "[doc/ACKNOWLEDGEMENTS.md](./doc/ACKNOWLEDGEMENTS.md)" for a list of contributors.**

---
