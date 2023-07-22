/*
 * Replacement getopt function's header file. Include this AFTER config.h.
 *
 * Copyright 2002-2008, 2010, 2012-2015, 2017, 2021, 2023 Andrew Wood
 *
 * Distributed under the Artistic License v2.0; see `doc/COPYING'.
 */

#ifndef _LIBRARY_GETOPT_H
#define _LIBRARY_GETOPT_H 1

#ifdef HAVE_GETOPT_H
#include <getopt.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef HAVE_GETOPT

int minigetopt(int, char **, char *);
extern char *minioptarg;
extern int minioptind, miniopterr, minioptopt;

#define getopt minigetopt	/* Flawfinder: ignore */
#define optarg minioptarg
#define optind minioptind
#define opterr miniopterr
#define optopt minioptopt

#endif				/* !HAVE_GETOPT */

#ifdef __cplusplus
}
#endif

#endif /* _LIBRARY_GETOPT_H */

/* EOF */
