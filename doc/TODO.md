Things still to do.  (GH#n) indicates the Github issue tracker number.

Bugs
----

 * ([GH#5](https://github.com/a-j-wood/pv/issues/5)) Transfer IPC leadership on exit of leader
 * ([GH#13](https://github.com/a-j-wood/pv/issues/13)) Use `clock_gettime()` in ETA calculation to cope with machine suspend/resume (Mateju Miroslav)
 * ([GH#16](https://github.com/a-j-wood/pv/issues/16)) Show days in same format in ETA as in elapsed time
 * ([GH#18](https://github.com/a-j-wood/pv/issues/18)) No output in Cygwin from 1.6.19 onwards (Jacek M. Holeczek)
 * ([GH#20](https://github.com/a-j-wood/pv/issues/20)) Terminal state is not restored correctly in all cases (VA)
 * ([GH#24](https://github.com/a-j-wood/pv/issues/24)) Race condition with multiple "`pv -c`" leaves terminal state inconsistent (Lars Ellenberg, Viktor Ashirov)
 * ([GH#26](https://github.com/a-j-wood/pv/issues/26)) Correct "`-n`" behaviour when going past 100% of "`-s`" size (Marcel)
 * ([GH#27](https://github.com/a-j-wood/pv/issues/27)) Rate limit downgrade can take a long time to take effect (Stephen Kitt)
 * ([GH#33](https://github.com/a-j-wood/pv/issues/33)) Fix compilation problems due to `stat64()` on Apple Silicon (Filippo Valsorda - Jan 2021)
 * ([GH#34](https://github.com/a-j-wood/pv/issues/34)) Continue timer even if input or output is blocking (Martin Probst - Jun 2017)

Feature requests
----------------

 * ([GH#3](https://github.com/a-j-wood/pv/issues/3)) Option ("`-x`"?) to use xterm title line for status (Joachim Haga)
 * ([GH#4](https://github.com/a-j-wood/pv/issues/4)) Option for process title (Martin Sarsale) as "`pv - name:FooProcess -xyz - transferred: 1.3GB - 500KB/s - running: 10:15:30s`"
 * ([GH#6](https://github.com/a-j-wood/pv/issues/6)) Look at effect of *O_SYNC* or `fsync` on performance; update counters during buffer flush
 * ([GH#9](https://github.com/a-j-wood/pv/issues/9)) Option to switch rate to per minute if really slow
 * ([GH#10](https://github.com/a-j-wood/pv/issues/10)) Add watchfd tests
 * ([GH#11](https://github.com/a-j-wood/pv/issues/11)) Option "`--progress-from FILE`", read last number and use it as bytes read (Jacek Wielemborek)
 * ([GH#12](https://github.com/a-j-wood/pv/issues/12)) Allow multiple "`-d`" options (Linus Heckemann for multiple PID:FD; Jacek Wielemborek)
 * ([GH#15](https://github.com/a-j-wood/pv/issues/15)) Use Unicode for more granular progress bar (Alexander Petrossian)
 * ([GH#17](https://github.com/a-j-wood/pv/issues/17)) Allow "`-r`" with "`-l`" and "`-n`" to output lines/sec (Roland Kletzing)
 * ([GH#21](https://github.com/a-j-wood/pv/issues/21)) Options to change the units in the rate display (Jeffrey Paul, John W. O'Brien, David Henderson)
 * ([GH#22](https://github.com/a-j-wood/pv/issues/22)) Options to skip input and seek on output (Jason A. Pfeil, Feb 2022)
 * ([GH#25](https://github.com/a-j-wood/pv/issues/25)) Normalise progress to 100% on overrun (Andrej Gantvorg)
 * ([GH#29](https://github.com/a-j-wood/pv/issues/29)) Option to enable *O_DIRECT* (Romain Kang, Jacek Wielemborek)
 * ([GH#35](https://github.com/a-j-wood/pv/issues/35)) Allow decimal values for "`-s`", "`-L`", "`-B`" (Thomas Watson - Aug 2020)
 * ([GH#36](https://github.com/a-j-wood/pv/issues/36)) Ignore *SIGWINCH* (window size change) if "`-w`" / "`-H`" provided
 * ([GH#37](https://github.com/a-j-wood/pv/issues/37)) Allow "`-E`" to take a block size argument so errors cause a skip to the next block (Anthony DeRobertis - Oct 2016)
 * ([GH#38](https://github.com/a-j-wood/pv/issues/38)) Reset ETA on *SIGUSR1* (Jacek Wielemborek - Jan 2019)
 * ([GH#39](https://github.com/a-j-wood/pv/issues/39)) Use `posix_fadvise()` like `cat`(1) does (Jacek Wielemborek - Oct 2015)
 * ([GH#40](https://github.com/a-j-wood/pv/issues/40)) Permit "`-c`" with "`-d PID:FD`", reject "`-N`" with "`-d PID`" (Norman Rasmussen - Nov 2020)
 * ([GH#41](https://github.com/a-j-wood/pv/issues/41)) Improve how backwards-moving reads are shown in "`--watchfd`" (Ryan Cooley - Dec 2017)
 * ([GH#42](https://github.com/a-j-wood/pv/issues/42)) Option to discard stdin so nothing is written to stdout (André Stapf - Apr 2017)
 * ([GH#43](https://github.com/a-j-wood/pv/issues/43)) Differentiate between "`--eta`" and "`--fineta`" in display (André Stapf - Apr 2017)
 * ([GH#45](https://github.com/a-j-wood/pv/issues/45)) Option "`--sparse`" (with block size option) to write sparse output (Andriy Galetski - Apr 2019)
 * ([GH#46](https://github.com/a-j-wood/pv/issues/46)) Option to show speed gauge (% max speed) if progress not known (Ryan Cooley - Jun 2019)
 * ([GH#47](https://github.com/a-j-wood/pv/issues/47)) Analyse splice and buffer usage to improve performance
 * ([GH#48](https://github.com/a-j-wood/pv/issues/48)) Option to show multiple files with individual sizes and a cumulative total (Zach Riggle - Jul 2021)
 * ([GH#49](https://github.com/a-j-wood/pv/issues/49)) Option to provide stats for avg/min/max/stddev throughput (Venky.N.Iyer)
 * ([GH#50](https://github.com/a-j-wood/pv/issues/50)) Allow pv to report on a whole pipeline at once (Will Entriken - Feb 2011)
 * ([GH#54](https://github.com/a-j-wood/pv/issues/54)) Run command every n percent ([haarp](https://github.com/haarp))
 * ([GH#56](https://github.com/a-j-wood/pv/issues/56)) Support for backgrounding pv, and allowing it to be monitored separately ([jimbobmcgee](https://github.com/jimbobmcgee))
 * ([GH#67](https://github.com/a-j-wood/pv/issues/67)) Wrap another process to monitor its stdin & stdout ([Alex Mason](https://github.com/axman6))

Any assistance would be appreciated.
