The following people have contributed to this project, and their assistance
is acknowledged and greatly appreciated:

 * Antoine Beaupré <anarcat@debian.org> - Debian package maintainer
 * Kevin Coyner <kcoyner@debian.org> - previous Debian package maintainer
 * Cédric Delfosse <cedric@debian.org> - previous Debian package maintainer
 * Jakub Hrozek <jhrozek@redhat.com> - Fedora package maintainer
 * Eduardo Aguiar <eduardo.oliveira@sondabrasil.com.br> - provided Portuguese (Brazilian) translation
 * Stéphane Lacasse <stephane@gorfou.ca> - provided French translation
 * Marcos Kreinacke <public@kreinacke.com> - provided German translation
 * Bartosz Feński <fenio@o2.pl> <http://skawina.eu.org/> - provided Polish translation along with Krystian Zubel
 * Joshua Jensen - reported RPM installation bug
 * Boris Folgmann <http://www.folgmann.com/en/> - reported cursor handling bug
 * Mathias Gumz - reported NLS bug
 * Daniel Roethlisberger - submitted patch to use lockfiles for "`-c`" if terminal locking fails
 * Adam Buchbinder - lots of help with a Cygwin port of "`-c`"
 * Mark Tomich <http://metuchen.dyndns.org> - suggested "`-B`" option
 * Gert Menke - reported bug when piping to `dd` with a large input buffer size
 * Ville Herva <Ville.Herva@iki.fi> - informative bug report about rate limiting performance
 * Elias Pipping - patch to compile properly on Darwin 9; potential NULL deref report
 * Patrick Collison - similar patch for OS X
 * Boris Lohner - reported problem that "`-L`" does not complain if given non-numeric value
 * Sebastian Kayser - supplied testing for *SIGPIPE*, demonstrated internationalisation problem
 * Laszlo Ersek <http://phptest11.atw.hu/> - reported shared memory leak on *SIGINT* with "`-c`"
 * Phil Rutschman <http://bandgap.rsnsoft.com/> - provided a patch for fully restoring terminal state on exit
 * Henry Precheur <http://henry.precheur.org/> - reporting and suggestions for "`--rate-limit`" bug when rate is under 10
 * E. Rosten <http://mi.eng.cam.ac.uk/~er258/> - supplied patch for block buffering in line mode
 * Kjetil Torgrim Homme - reported compilation error with default *CFLAGS* on non-GCC compilers
 * Alexandre de Verteuil - reported bug in OS X build and supplied test environment to fix in
 * Martin Baum - supplied patch to return nonzero exit status if terminated by signal
 * Sam Nelson <http://www.siliconfuture.net/> - supplied patch to fix trailing slash on *DESTDIR*
 * Daniel Pape - reported Cygwin installation problem due to *DESTDIR*
 * Philipp Beckers - ported to the Syabas PopcornHour A-100 series
 * Henry Gebhard <hsggebhardt@googlemail.com> - supplied patches to improve SI prefixes and add "`--average-rate`"
 * Vladimir Kokarev, Alexander Leo - reported that exit status did not reflect file errors
 * Thomas Rachel - submitted patches for IEEE1541 (MiB suffixes), 1+e03 bug
 * Guillaume Marcais - submitted speedup patch for line mode
 * Moritz Barsnick - submitted patch for compile warning in size calculation
 * Pawel Piatek - submitted RPM and patches for AIX
 * Sami Liedes - submitted patch for "`--timer`" and "`--bytes`" with "`--numeric`"
 * Steven Willis - reported problem with "`-R`" killing non-PV remote processes
 * Vladimir Pal, Vladimir Ermakov - submitted patch which led to development of "`--format`" option
 * Peter Samuelson <peter@p12n.org> - submitted patch to calculate size if stdout is a block device
 * Miguel Diaz - much Cygwin help (and packaging), found narrow-terminal bug
 * Jim Salter <http://ubuntuwiki.net> - commissioned work on the "`--skip-errors`" option
 * Wouter Pronk - reported build problem on SCO
 * Bryan Dongray <http://www.dongrays.com> - provided patches for test scripts failing on older Red Hats
 * Zev Weiss <www.bewilderbeest.net> - provided patch to fix `splice()` not using stdin
 * Zing Shishak - provided patch for "`--null`" / "`-0`" (count null terminated lines)
 * Jacek Wielemborek <http://deetah.jogger.pl/kategorie/english> - implemented fdwatch in Python, suggested PV port; reported bug with "`-l`" and ETA / size; many other contributions
 * Kim Krecht - suggested buffer fill status and last bytes output display options
 * Cristian Ciupitu <http://ciupicri.github.io>, Josh Stone - pointed out file descriptor leak with helpful suggestions (Josh Stone initially noticed the missing close)
 * Jan Seda - found issue with `splice()` and *SPLICE_F_NONBLOCK* causing slowdown
 * André Stapf - pointed out formatting problem e.g. 13GB -> 13.1GB which should be shown 13.0GB -> 13.1GB; highlighted on-startup row swapping in "`-c`"
 * Damon Harper <http://www.usrbin.ca/> - suggested "`-D`" / "`--delay-start`" option
 * Ganaël Laplanche <http://www.martymac.org> - provided patch for `lstat64()` on systems that do not support it
 * Peter Korsgaard <http://www.buildroot.net/> - provided similar patch for `lstat64()`, specifically for uClibc support; provided AIX cross-compilation patch to fix bug in "`-lc128`" check
 * Ralf Ramsauer <https://blog.ramses-pyramidenbau.de/> - reported bug which dropped transfer rate on terminal resize
 * Michiel Van Herwegen - reported and discussed bug with "`-l`" and ETA / size
 * Erkki Seppälä <http://www.inside.org/~flux/> - provided patch implementing "`-I`"
 * Eric A. Borisch - provided details of compatibility fix for "`%Lu`" in watchpid code
 * Jan Venekamp - reported MacOS buffer size interactions with pipes
 * Matt <https://github.com/lemonsqueeze/pv> - provided "rate-window" patches for rate calculation
 * Filippo Valsorda - provided patch for stat64 issue on Apple Silicon
 * Matt Koscica, William Dillon - also reported stat64 issue on Apple Silicon
 * Norman Rasmussen - suggested "`-c`" with "`-d PID:FD`", reject "`-N`" with "`-d PID`"
 * Andriy Gapon, Jonathan Elchison - reported bug where "`pv /dev/zero >/dev/null &`" stops immediately
 * Marcelo Chiesa - reported unused-result warnings when compiling PV 1.6.6
 * Jered Floyd - provided patches to improve "`--rate-limit`"
 * Christoph Biedl - provided ETA and dynamic interval patches
 * Richard Fonfara - provided German translations for "`pv --help`"
 * Johannes Gerer <http://johannesgerer.com> - suggested that "`-B`" should enable "`-C`"
 * Sam James - provided fix for number.c build issue caused by missing stddef.h
 * Jakub Wilk <jwilk@jwilk.net> - corrected README encoding
 * [Luc Gommans](https://github.com/lgommans) / https://lgms.nl/ - provided a "momentary ETA" patch
 * [ikasty](https://github.com/ikasty) - added relative filename display to "`--watchfd`"
 * [Michael Weiß](https://github.com/quitschbo) - corrected behaviour when not attached to a terminal
 * [christoph-zededa](https://github.com/christoph-zededa) - provided OS X support for "`--watchfd`"
 * [Dave Beckett](https://github.com/dajobe) - added "`@filename`" syntax to "`--size`", and corrected an autoconf problem with stat64 on OS X
 * [Volodymyr Bychkovyak](https://github.com/vbychkoviak) - provided fix for rate limit behaviour with bursty traffic

---
