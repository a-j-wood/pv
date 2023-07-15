Things still to do.  (GH#n) indicates the Github issue tracker number.

Bugs
----

 * (GH#5) Transfer IPC leadership on exit of leader
 * (GH#13) Use `clock_gettime()` in ETA calculation to cope with machine suspend/resume (Mateju Miroslav)
 * (GH#16) Show days in same format in ETA as in elapsed time
 * (GH#18) No output in Cygwin from 1.6.19 onwards (Jacek M. Holeczek)
 * (GH#20) Terminal state is not restored correctly in all cases (VA)
 * (GH#23) No output with "`-f`" when run in background after 1.6.6 (gray)
 * (GH#24) Race condition with multiple "`pv -c`" leaves terminal state inconsistent (Lars Ellenberg, Viktor Ashirov)
 * (GH#26) Correct "`-n`" behaviour when going past 100% of "`-s`" size (Marcel)
 * (GH#27) Rate limit downgrade can take a long time to take effect (Stephen Kitt)
 * (GH#31) No output written from inside zsh `<()` construct (Frederik Eaton - Dec 2015)
 * (GH#32) Apply rate limits instantaneously, not averaged over the whole transfer (Jered Floyd - Dec 2018)
 * (GH#33) Fix compilation problems due to `stat64()` on Apple Silicon (Filippo Valsorda - Jan 2021)
 * (GH#34) Continue timer even if input or output is blocking (Martin Probst - Jun 2017)

Feature requests
----------------

 * (GH#3) Option ("`-x`"?) to use xterm title line for status (Joachim Haga)
 * (GH#4) Option for process title (Martin Sarsale) as "`pv - name:FooProcess -xyz - transferred: 1.3GB - 500KB/s - running: 10:15:30s`"
 * (GH#6) Look at effect of *O_SYNC* or `fsync` on performance; update counters during buffer flush
 * (GH#9) Option to switch rate to per minute if really slow
 * (GH#10) Add watchfd tests
 * (GH#11) Option "`--progress-from FILE`", read last number and use it as bytes read (Jacek Wielemborek)
 * (GH#12) Allow multiple "`-d`" options (Linus Heckemann for multiple PID:FD; Jacek Wielemborek)
 * (GH#14) Momentary ETA option (Luc Gommans)
 * (GH#15) Use Unicode for more granular progress bar (Alexander Petrossian)
 * (GH#17) Allow "`-r`" with "`-l`" and "`-n`" to output lines/sec (Roland Kletzing)
 * (GH#21) Options to change the units in the rate display (Jeffrey Paul, John W. O'Brien, David Henderson)
 * (GH#22) Options to skip input and seek on output (Jason A. Pfeil, Feb 2022)
 * (GH#25) Normalise progress to 100% on overrun (Andrej Gantvorg)
 * (GH#28) Calculate ETA based on current average rate instead of global average (Matt, Christoph Biedl)
 * (GH#29) Option to enable *O_DIRECT* (Romain Kang, Jacek Wielemborek)
 * (GH#30) Option for dynamic interval to improve ETA predictions for long-running transfers (Christoph Biedl)
 * (GH#35) Allow decimal values for "`-s`", "`-L`", "`-B`" (Thomas Watson - Aug 2020)
 * (GH#36) Ignore SIGWINCH (window size change) if "`-w`" / "`-H`" provided
 * (GH#37) Allow "`-E`" to take a block size argument so errors cause a skip to the next block (Anthony DeRobertis - Oct 2016)
 * (GH#38) Reset ETA on *SIGUSR1* (Jacek Wielemborek - Jan 2019)
 * (GH#39) Use `posix_fadvise()` like `cat`(1) does (Jacek Wielemborek - Oct 2015)
 * (GH#40) Permit "`-c`" with "`-d PID:FD`", reject "`-N`" with "`-d PID`" (Norman Rasmussen - Nov 2020)
 * (GH#41) Improve how backwards-moving reads are shown in "`--watchfd`" (Ryan Cooley - Dec 2017)
 * (GH#42) Option to discard stdin so nothing is written to stdout (André Stapf - Apr 2017)
 * (GH#43) Differentiate between "`--eta`" and "`--fineta`" in display (André Stapf - Apr 2017)
 * (GH#44) Specify size for "`-s`" by pointing to a filename to use the size of
 * (GH#45) Option "`--sparse`" (with block size option) to write sparse output (Andriy Galetski - Apr 2019)
 * (GH#46) Option to show speed gauge (% max speed) if progress not known (Ryan Cooley - Jun 2019)
 * (GH#47) Analyse splice and buffer usage to improve performance
 * (GH#48) Option to show multiple files with individual sizes and a cumulative total (Zach Riggle - Jul 2021)
 * (GH#49) Option to provide stats for avg/min/max/stddev throughput (Venky.N.Iyer)
 * (GH#50) Allow pv to report on a whole pipeline at once (Will Entriken - Feb 2011)

Any assistance would be appreciated.
