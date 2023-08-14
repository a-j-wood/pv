/*
 * Main program entry point - read the command line options, then perform
 * the appropriate actions.
 *
 * Copyright 2002-2008, 2010, 2012-2015, 2017, 2021, 2023 Andrew Wood
 *
 * Distributed under the Artistic License v2.0; see `doc/COPYING'.
 */

#include "config.h"
#include "options.h"
#include "pv.h"

/* #undef MAKE_STDOUT_NONBLOCKING */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/types.h>


int pv_remote_set(opts_t);
void pv_remote_init(void);
void pv_remote_fini(void);


/*
 * Process command-line arguments and set option flags, then call functions
 * to initialise, and finally enter the main loop.
 */
int main(int argc, char **argv)
{
	struct termios t, t_save;
	/*@only@ */ opts_t opts = NULL;
	/*@only@ */ pvstate_t state = NULL;
	bool t_saved, t_needs_reset;
	int retcode = 0;

#ifdef ENABLE_NLS
	(void) setlocale(LC_ALL, "");
	(void) bindtextdomain(PACKAGE, LOCALEDIR);
	(void) textdomain(PACKAGE);
#endif

	opts = opts_parse(argc >= 0 ? (unsigned int) argc : 0, argv);
	if (NULL == opts) {
		debug("%s: %d", "exiting with status", 64);
		return 64;
	}

	if (opts->do_nothing) {
		debug("%s", "nothing to do - exiting with status 0");
		opts_free(opts);
		return 0;
	}

	/*
	 * -R specified - send the message, then exit.
	 */
	if (opts->remote > 0) {
		retcode = pv_remote_set(opts);
		opts_free(opts);
		return retcode;
	}

	/*
	 * Allocate our internal state buffer.
	 */
	state = pv_state_alloc(opts->program_name);
	if (NULL == state) {
		/*@-mustfreefresh@ */
		/*
		 * splint note: the gettext calls made by _() cause memory
		 * leak warnings, but in this case it's unavoidable, and
		 * mitigated by the fact we only translate each string once.
		 */
		fprintf(stderr, "%s: %s: %s\n", opts->program_name, _("state allocation failed"), strerror(errno));
		opts_free(opts);
		debug("%s: %d", "exiting with status", 64);
		return 64;
		/*@+mustfreefresh@ */
	}

	/*
	 * Write a PID file if -P was specified.
	 */
	if (opts->pidfile != NULL) {
		FILE *pidfptr;
		pidfptr = fopen(opts->pidfile, "w");
		if (NULL == pidfptr) {
			/*@-mustfreefresh@ *//* see above */
			fprintf(stderr, "%s: %s: %s\n", opts->program_name, opts->pidfile, strerror(errno));
			pv_state_free(state);
			opts_free(opts);
			return 1;
			/*@+mustfreefresh@ */
		}
		fprintf(pidfptr, "%d\n", getpid());
		if (0 != fclose(pidfptr)) {
			fprintf(stderr, "%s: %s: %s\n", opts->program_name, opts->pidfile, strerror(errno));
		}
	}

	/*
	 * If no files were given, pretend "-" was given (stdin).
	 */
	if (0 == opts->argc) {
		debug("%s", "no files given - adding fake argument `-'");
		if (!opts_add_file(opts, "-")) {
			pv_state_free(state);
			opts_free(opts);
			return 64;
		}
	}

	/*
	 * Put our list of files into the PV internal state.
	 */
	if (NULL != opts->argv) {
		pv_state_inputfiles(state, opts->argc, (const char **) (opts->argv));
	}

	if (0 == opts->watch_pid) {
		/*
		 * If no size was given, and we're not in line mode, try to
		 * calculate the total size.
		 */
		if ((0 == opts->size) && (false == opts->linemode)) {
			opts->size = pv_calc_total_size(state);
			debug("%s: %llu", "no size given - calculated", opts->size);
		}

		/*
		 * If the size is unknown, we cannot have an ETA.
		 */
		if (opts->size < 1) {
			opts->eta = false;
			debug("%s", "size unknown - ETA disabled");
		}
	}

	/*
	 * If stderr is not a terminal and we're neither forcing output nor
	 * outputting numerically, we will have nothing to display at all.
	 */
	if ((0 == isatty(STDERR_FILENO))
	    && (false == opts->force)
	    && (false == opts->numeric)) {
		opts->no_op = true;
		debug("%s", "nothing to display - setting no_op");
	}

	/*
	 * Auto-detect width or height if either are unspecified.
	 */
	if ((0 == opts->width) || (0 == opts->height)) {
		unsigned int width, height;
		width = 0;
		height = 0;
		pv_screensize(&width, &height);
		if (0 == opts->width) {
			opts->width = width;
			debug("%s: %u", "auto-detected terminal width", width);
		}
		if (0 == opts->height) {
			opts->height = height;
			debug("%s: %u", "auto-detected terminal height", height);
		}
	}

	/*
	 * Width and height bounds checking (and defaults).
	 */
	if (opts->width < 1)
		opts->width = 80;
	if (opts->height < 1)
		opts->height = 25;
	if (opts->width > 999999)
		opts->width = 999999;
	if (opts->height > 999999)
		opts->height = 999999;

	/*
	 * Interval must be at least 0.1 second, and at most 10 minutes.
	 */
	if (opts->interval < 0.1)
		opts->interval = 0.1;
	if (opts->interval > 600)
		opts->interval = 600;

	/*
	 * Copy parameters from options into main state.
	 */
	pv_state_interval_set(state, opts->interval);
	pv_state_width_set(state, opts->width);
	pv_state_height_set(state, opts->height);
	pv_state_no_op_set(state, opts->no_op);
	pv_state_force_set(state, opts->force);
	pv_state_cursor_set(state, opts->cursor);
	pv_state_numeric_set(state, opts->numeric);
	pv_state_wait_set(state, opts->wait);
	pv_state_delay_start_set(state, opts->delay_start);
	pv_state_linemode_set(state, opts->linemode);
	pv_state_bits_set(state, opts->bits);
	pv_state_null_set(state, opts->null);
	pv_state_skip_errors_set(state, opts->skip_errors);
	pv_state_stop_at_size_set(state, opts->stop_at_size);
	pv_state_sync_after_write_set(state, opts->sync_after_write);
	pv_state_direct_io_set(state, opts->direct_io);
	pv_state_rate_limit_set(state, opts->rate_limit);
	pv_state_target_buffer_size_set(state, opts->buffer_size);
	pv_state_no_splice_set(state, opts->no_splice);
	pv_state_size_set(state, opts->size);

	if (NULL != opts->name)
		pv_state_name_set(state, opts->name);

	if (NULL != opts->format)
		pv_state_format_string_set(state, opts->format);

	pv_state_watch_pid_set(state, opts->watch_pid);
	pv_state_watch_fd_set(state, opts->watch_fd);
	pv_state_average_rate_window_set(state, opts->average_rate_window);

	pv_state_set_format(state, opts->progress, opts->timer, opts->eta,
			    opts->fineta, opts->rate, opts->average_rate,
			    opts->bytes, opts->bufpercent, opts->lastwritten, opts->name);

#ifdef MAKE_STDOUT_NONBLOCKING
	/*
	 * Try and make standard output use non-blocking I/O.
	 *
	 * Note that this can cause problems with (broken) applications
	 * such as dd.
	 */
	fcntl(STDOUT_FILENO, F_SETFL, O_NONBLOCK | fcntl(STDOUT_FILENO, F_GETFL));
#endif				/* MAKE_STDOUT_NONBLOCKING */

	/*
	 * Keep track of whether we've saved the terminal attributes and
	 * whether we need to reset them at the end.
	 */
	t_saved = false;
	t_needs_reset = false;

	/*
	 * Set terminal option TOSTOP so we get signal SIGTTOU if we try to
	 * write to the terminal while backgrounded.
	 *
	 * Also, save the current terminal attributes for later restoration.
	 */
	memset(&t, 0, sizeof(t));
	if (0 != isatty(STDERR_FILENO)) {
		if (0 == tcgetattr(STDERR_FILENO, &t)) {
			debug("%s", "saved terminal attributes");
			t_saved = true;
		} else {
			/*@-mustfreefresh@ *//* see above */
			fprintf(stderr, "%s: %s: %s\n", opts->program_name,
				_("failed to read terminal attributes"), strerror(errno));
			/*@+mustfreefresh@ */
		}
	}
	t_save = t;
	if (t_saved && pv_in_foreground()) {
		t.c_lflag |= TOSTOP;
		(void) tcsetattr(STDERR_FILENO, TCSANOW, &t);
		t_needs_reset = true;
		debug("%s", "set terminal TOSTOP attribute");
	}

	if (0 != opts->watch_pid) {
		if (0 <= opts->watch_fd) {
			pv_sig_init(state);
			retcode = pv_watchfd_loop(state);
			if (t_needs_reset && pv_in_foreground()) {
				(void) tcsetattr(STDERR_FILENO, TCSANOW, &t_save);
			}
			if (opts->pidfile != NULL) {
				if (0 != remove(opts->pidfile)) {
					fprintf(stderr, "%s: %s: %s\n",
						opts->program_name, opts->pidfile, strerror(errno));
				}
			}
			pv_sig_fini(state);
		} else {
			pv_sig_init(state);
			retcode = pv_watchpid_loop(state);
			if (t_needs_reset && pv_in_foreground()) {
				(void) tcsetattr(STDERR_FILENO, TCSANOW, &t_save);
			}
			if (opts->pidfile != NULL) {
				if (0 != remove(opts->pidfile)) {
					fprintf(stderr, "%s: %s: %s\n",
						opts->program_name, opts->pidfile, strerror(errno));
				}
			}
			pv_sig_fini(state);
		}
	} else {
		pv_sig_init(state);
		pv_remote_init();
		retcode = pv_main_loop(state);
		pv_remote_fini();
		if (t_needs_reset && pv_in_foreground()) {
			(void) tcsetattr(STDERR_FILENO, TCSANOW, &t_save);
		}
		if (opts->pidfile != NULL) {
			if (0 != remove(opts->pidfile)) {
				fprintf(stderr, "%s: %s: %s\n", opts->program_name, opts->pidfile, strerror(errno));
			}
		}
		pv_sig_fini(state);
	}

	pv_state_free(state);

	opts_free(opts);

	debug("%s: %d", "exiting with status", retcode);

	return retcode;
}

/* EOF */
