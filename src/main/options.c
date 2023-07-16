/*
 * Parse command-line options.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include "options.h"
#include "library/getopt.h"
#include "pv.h"
#include "pv-internal.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <unistd.h>


void display_help(void);
void display_version(void);


/*
 * Free an opts_t object.
 */
void opts_free(opts_t opts)
{
	if (!opts)
		return;
	if (NULL != opts->argv)
		free(opts->argv);
	free(opts);
}


/*
 * Parse the given command-line arguments into an opts_t object, handling
 * "help", "license" and "version" options internally.
 *
 * Returns an opts_t, or 0 on error.
 *
 * Note that the contents of *argv[] (i.e. the command line parameters)
 * aren't copied anywhere, just the pointers are copied, so make sure the
 * command line data isn't overwritten or argv[1] free()d or whatever.
 */
opts_t opts_parse(int argc, char **argv)
{
#ifdef HAVE_GETOPT_LONG
	struct option long_options[] = {
		{"help", 0, NULL, (int) 'h'},
		{"version", 0, NULL, (int) 'V'},
		{"progress", 0, NULL, (int) 'p'},
		{"timer", 0, NULL, (int) 't'},
		{"eta", 0, NULL, (int) 'e'},
		{"fineta", 0, NULL, (int) 'I'},
		{"rate", 0, NULL, (int) 'r'},
		{"average-rate", 0, NULL, (int) 'a'},
		{"bytes", 0, NULL, (int) 'b'},
		{"buffer-percent", 0, NULL, (int) 'T'},
		{"last-written", 1, NULL, (int) 'A'},
		{"force", 0, NULL, (int) 'f'},
		{"numeric", 0, NULL, (int) 'n'},
		{"quiet", 0, NULL, (int) 'q'},
		{"cursor", 0, NULL, (int) 'c'},
		{"wait", 0, NULL, (int) 'W'},
		{"delay-start", 1, NULL, (int) 'D'},
		{"size", 1, NULL, (int) 's'},
		{"line-mode", 0, NULL, (int) 'l'},
		{"null", 0, NULL, (int) '0'},
		{"interval", 1, NULL, (int) 'i'},
		{"width", 1, NULL, (int) 'w'},
		{"height", 1, NULL, (int) 'H'},
		{"name", 1, NULL, (int) 'N'},
		{"format", 1, NULL, (int) 'F'},
		{"rate-limit", 1, NULL, (int) 'L'},
		{"buffer-size", 1, NULL, (int) 'B'},
		{"no-splice", 0, NULL, (int) 'C'},
		{"skip-errors", 0, NULL, (int) 'E'},
		{"stop-at-size", 0, NULL, (int) 'S'},
		{"remote", 1, NULL, (int) 'R'},
		{"pidfile", 1, NULL, (int) 'P'},
		{"watchfd", 1, NULL, (int) 'd'},
		{NULL, 0, NULL, 0}
	};
	int option_index = 0;
#endif
	char *short_options =
	    "hVpteIrabTA:fnqcWD:s:l0i:w:H:N:F:L:B:CESR:P:d:";
	int c, numopts;
	unsigned int check_pid;
	int check_fd;
	opts_t opts;
	char *ptr;

	opts = calloc(1, sizeof(*opts));
	if (!opts) {
		fprintf(stderr, "%s: %s: %s\n", argv[0],
			_("option structure allocation failed"),
			strerror(errno));
		return NULL;
	}

	opts->program_name = argv[0];
	ptr = strrchr(opts->program_name, '/');
	if (NULL != ptr)
		opts->program_name = 1 + ptr;

	opts->argc = 0;
	opts->argv = calloc((size_t) (argc + 1), sizeof(char *));
	if (NULL == opts->argv) {
		fprintf(stderr, "%s: %s: %s\n", opts->program_name,
			_("option structure argv allocation failed"),
			strerror(errno));
		opts_free(opts);
		return NULL;
	}

	numopts = 0;

	opts->interval = 1;
	opts->delay_start = 0;
	opts->watch_pid = 0;
	opts->watch_fd = -1;

	do {
#ifdef HAVE_GETOPT_LONG
		c = getopt_long(argc, argv,
				short_options, long_options,
				&option_index);
#else
		c = getopt(argc, argv, short_options);
#endif
		if (c < 0)
			continue;

		/*
		 * Check that any numeric arguments are of the right type.
		 */
		switch (c) {
		case 's':
			/* "-s @" is valid, so allow it. */
			if ('@' == *optarg)
				break;
		case 'A':
		case 'w':
		case 'H':
		case 'L':
		case 'B':
		case 'R':
			if (pv_getnum_check(optarg, PV_NUMTYPE_INTEGER) !=
			    0) {
				fprintf(stderr, "%s: -%c: %s\n",
					opts->program_name, c,
					_("integer argument expected"));
				opts_free(opts);
				return NULL;
			}
			break;
		case 'i':
		case 'D':
			if (pv_getnum_check(optarg, PV_NUMTYPE_DOUBLE) !=
			    0) {
				fprintf(stderr, "%s: -%c: %s\n",
					opts->program_name, c,
					_("numeric argument expected"));
				opts_free(opts);
				return NULL;
			}
			break;
		case 'd':
			if (sscanf(optarg, "%u:%d", &check_pid, &check_fd)
			    < 1) {
				fprintf(stderr, "%s: -%c: %s\n",
					opts->program_name, c,
					_
					("process ID or pid:fd pair expected"));
				opts_free(opts);
				return NULL;
			}
			if (check_pid < 1) {
				fprintf(stderr, "%s: -%c: %s\n",
					opts->program_name, c,
					_("invalid process ID"));
				opts_free(opts);
				return NULL;
			}
			break;
		default:
			break;
		}

		/*
		 * Parse each command line option.
		 */
		switch (c) {
		case 'h':
			display_help();
			opts->do_nothing = true;
			return opts;	    /* early return */
		case 'V':
			display_version();
			opts->do_nothing = true;
			return opts;	    /* early return */
		case 'p':
			opts->progress = true;
			numopts++;
			break;
		case 't':
			opts->timer = true;
			numopts++;
			break;
		case 'I':
			opts->fineta = true;
			numopts++;
			break;
		case 'e':
			opts->eta = true;
			numopts++;
			break;
		case 'r':
			opts->rate = true;
			numopts++;
			break;
		case 'a':
			opts->average_rate = true;
			numopts++;
			break;
		case 'b':
			opts->bytes = true;
			numopts++;
			break;
		case 'T':
			opts->bufpercent = true;
			numopts++;
			opts->no_splice = true;
			break;
		case 'A':
			opts->lastwritten = pv_getnum_ui(optarg);
			numopts++;
			opts->no_splice = true;
			break;
		case 'f':
			opts->force = true;
			break;
		case 'n':
			opts->numeric = true;
			numopts++;
			break;
		case 'q':
			opts->no_op = true;
			numopts++;
			break;
		case 'c':
			opts->cursor = true;
			break;
		case 'W':
			opts->wait = true;
			break;
		case 'D':
			opts->delay_start = pv_getnum_d(optarg);
			break;
		case 's':
			/* Permit "@<filename>" as well as just a number. */
			if ('@' == *optarg) {
				const char *size_file = 1 + optarg;
				struct stat64 sb;
				int rc;

				rc = 0;
				memset(&sb, 0, sizeof(sb));
				rc = stat64(size_file, &sb);
				if (0 == rc) {
					opts->size = sb.st_size;
				} else {
					fprintf(stderr, "%s: %s %s: %s\n",
						opts->program_name,
						_("failed to stat file"),
						size_file, strerror(errno));
					opts_free(opts);
					return NULL;
				}
			} else {
				opts->size = pv_getnum_ull(optarg);
			}
			break;
		case 'l':
			opts->linemode = true;
			break;
		case '0':
			opts->null = true;
			opts->linemode = true;
			break;
		case 'i':
			opts->interval = pv_getnum_d(optarg);
			break;
		case 'w':
			opts->width = pv_getnum_ui(optarg);
			break;
		case 'H':
			opts->height = pv_getnum_ui(optarg);
			break;
		case 'N':
			opts->name = optarg;
			break;
		case 'L':
			opts->rate_limit = pv_getnum_ull(optarg);
			break;
		case 'B':
			opts->buffer_size = pv_getnum_ull(optarg);
			opts->no_splice = true;
			break;
		case 'C':
			opts->no_splice = true;
			break;
		case 'E':
			opts->skip_errors++;
			break;
		case 'S':
			opts->stop_at_size = true;
			break;
		case 'R':
			opts->remote = pv_getnum_ui(optarg);
			break;
		case 'P':
			opts->pidfile = optarg;
			break;
		case 'F':
			opts->format = optarg;
			break;
		case 'd':
			opts->watch_pid = 0;
			opts->watch_fd = -1;
			/* No syntax check here, already done earlier */
			(void) sscanf(optarg, "%u:%d", &(opts->watch_pid),
				      &(opts->watch_fd));
			break;
		default:
#ifdef HAVE_GETOPT_LONG
			fprintf(stderr,
				_("Try `%s --help' for more information."),
				opts->program_name);
#else
			fprintf(stderr,
				_("Try `%s -h' for more information."),
				opts->program_name);
#endif
			fprintf(stderr, "\n");
			opts_free(opts);
			return NULL;	    /* early return */
		}

	} while (c != -1);

	if (0 != opts->watch_pid) {
		if (opts->linemode || opts->null || opts->stop_at_size
		    || (opts->skip_errors > 0) || (opts->buffer_size > 0)
		    || (opts->rate_limit > 0)) {
			fprintf(stderr, "%s: %s\n", opts->program_name,
				_
				("cannot use line mode or transfer modifier options when watching file descriptors"));
			opts_free(opts);
			return NULL;
		}

		if (opts->cursor) {
			fprintf(stderr, "%s: %s\n", opts->program_name,
				_
				("cannot use cursor positioning when watching file descriptors"));
			opts_free(opts);
			return NULL;
		}

		if (0 != opts->remote) {
			fprintf(stderr, "%s: %s\n", opts->program_name,
				_
				("cannot use remote control when watching file descriptors"));
			opts_free(opts);
			return NULL;
		}

		if (optind < argc) {
			fprintf(stderr, "%s: %s\n", opts->program_name,
				_
				("cannot transfer files when watching file descriptors"));
			opts_free(opts);
			return NULL;
		}

#ifndef __APPLE__
		if (0 != access("/proc/self/fdinfo", X_OK)) {
			fprintf(stderr, "%s: -d: %s\n", opts->program_name,
				_
				("not available on systems without /proc/self/fdinfo"));
			opts_free(opts);
			return NULL;
		}
#endif
	}

	/*
	 * Default options: -pterb
	 */
	if (0 == numopts) {
		opts->progress = true;
		opts->timer = true;
		opts->eta = true;
		opts->rate = true;
		opts->bytes = true;
	}

	/*
	 * Store remaining command-line arguments.
	 */
	while (optind < argc) {
		opts->argv[opts->argc++] = argv[optind++];
	}

	return opts;
}

/* EOF */
