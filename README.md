Project has left GitHub
-----------------------

It is now here: [https://codeberg.org/a-j-wood/pv](https://codeberg.org/a-j-wood/pv)

This project was briefly hosted on GitHub.  GitHub is a proprietary,
trade-secret system that is not Free and Open Source Software (FOSS).

Read about the [Give up GitHub](https://GiveUpGitHub.org) campaign from
[the Software Freedom Conservancy](https://sfconservancy.org) to understand
some of the reasons why GitHub is not a good place to host FOSS projects.

Any use of this project's code by GitHub Copilot, past or present, is done
without permission.  The project owner does not consent to GitHub's use of
this project's code in Copilot.

![Logo of the GiveUpGitHub campaign](https://sfconservancy.org/img/GiveUpGitHub.png)


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

Changes are listed in "[doc/NEWS.md](./doc/NEWS.md)".  The to-do list is "[doc/TODO.md](./doc/TODO.md)".

Developers and translators, please see "[doc/DEVELOPERS.md](./doc/DEVELOPERS.md)".


Compilation
-----------

If this is not a packaged release, first run "`./generate.sh`".

To compile the package, type "`sh ./configure`", which should generate a
Makefile for your system.  You may then type "`make`" to build everything.
Note that GNU _make_ is required; this may be installed as _gmake_ on some
systems, so if typing "`make`" gives an error, try "`gmake`" instead.

See the file "[doc/INSTALL](./doc/INSTALL)" for more about the _configure_ script.


Author and acknowledgements
---------------------------

This package is copyright 2023 Andrew Wood, and is being distributed under
the terms of the Artistic License 2.0.  For more details of this license,
see the file "[doc/COPYING](./doc/COPYING)".

Report bugs in **pv** using the contact form linked from the home page, or
though the [project issue tracker](https://codeberg.org/a-j-wood/pv/issues).

The **pv** home page is at:

&nbsp;&nbsp;[http://www.ivarch.com/programs/pv.shtml](http://www.ivarch.com/programs/pv.shtml)

The latest version can always be found here.

**Please see "[doc/ACKNOWLEDGEMENTS.md](./doc/ACKNOWLEDGEMENTS.md)" for a list of contributors.**

---
