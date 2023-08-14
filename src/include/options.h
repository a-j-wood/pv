/*
 * Global program option structure and the parsing function prototype.
 *
 * Copyright 2002-2008, 2010, 2012-2015, 2017, 2021, 2023 Andrew Wood
 *
 * Distributed under the Artistic License v2.0; see `doc/COPYING'.
 */

#ifndef _OPTIONS_H
#define _OPTIONS_H 1

#ifdef __cplusplus
extern "C" {
#endif

struct opts_s;
typedef struct opts_s *opts_t;

struct opts_s {           /* structure describing run-time options */
	/*@keep@*/ const char *program_name; /* name the program is running as */
	bool do_nothing;               /* exit-without-doing-anything flag */
	bool progress;                 /* progress bar flag */
	bool timer;                    /* timer flag */
	bool eta;                      /* ETA flag */
	bool fineta;                   /* absolute ETA flag */
	bool rate;                     /* rate counter flag */
	bool average_rate;             /* average rate counter flag */
	bool bytes;                    /* bytes transferred flag */
	bool bits;                     /* report transfer size in bits */
	bool bufpercent;               /* transfer buffer percentage flag */
	unsigned int lastwritten;      /* show N bytes last written */
	bool force;                    /* force-if-not-terminal flag */
	bool cursor;                   /* whether to use cursor positioning */
	bool numeric;                  /* numeric output only */
	bool wait;                     /* wait for transfer before display */
	bool linemode;                 /* count lines instead of bytes */
	bool null;                     /* lines are null-terminated */
	bool no_op;                    /* do nothing other than pipe data */
	unsigned long long rate_limit; /* rate limit, in bytes per second */
	unsigned long long buffer_size;/* buffer size, in bytes (0=default) */
	unsigned int remote;           /* PID of pv to update settings of */
	unsigned long long size;       /* total size of data */
	bool no_splice;                /* flag set if never to use splice */
	unsigned int skip_errors;      /* skip read errors counter */
	bool stop_at_size;             /* set if we stop at "size" bytes */
	bool sync_after_write;         /* set if we sync after every write */
	bool direct_io;                /* set if O_DIRECT is to be used */
	double interval;               /* interval between updates */
	double delay_start;            /* delay before first display */
	unsigned int watch_pid;	       /* process to watch fds of */
	int watch_fd;		       /* fd to watch */
	unsigned int average_rate_window; /* time window in seconds for average rate calculations */
	unsigned int width;            /* screen width */
	unsigned int height;           /* screen height */
	/*@keep@*/ /*@null@*/ char *name;    /* display name, if any */
	/*@keep@*/ /*@null@*/ char *format;  /* output format, if any */
	/*@keep@*/ /*@null@*/ char *pidfile; /* PID file, if any */
	unsigned int argc;             /* number of non-option arguments */
	/*@keep@*/ /*@null@*/ char **argv;   /* array of non-option arguments */
	unsigned int argv_length;      /* allocated array size */
};

/*@-exportlocal@*/
/* splint thinks opts_free is exported but not used - it is used. */

extern /*@null@*/ /*@only@*/ opts_t opts_parse(unsigned int, char **);
extern void opts_free(/*@only@*/ opts_t);
extern bool opts_add_file(opts_t, char *);

#ifdef __cplusplus
}
#endif

#endif /* _OPTIONS_H */

/* EOF */
