/*
 * Output debugging information.
 *
 * Copyright 2002-2008, 2010, 2012-2015, 2017, 2021, 2023 Andrew Wood
 *
 * Distributed under the Artistic License v2.0; see `doc/COPYING'.
 */

#include "config.h"
#include "pv.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>


#ifdef ENABLE_DEBUGGING
/*
 * Output debugging information to the file given in the DEBUG environment
 * variable, if it is defined.
 */
void debugging_output(const char *function, const char *file, int line,
		      const char *format, ...)
{
	static bool tried_open = false;
	static FILE *debugfptr = NULL;
	char *debugfile;
	va_list ap;
	time_t t;
	struct tm *tm;
	char tbuf[128];

	if (false == tried_open) {
		debugfile = getenv("DEBUG");
		if (NULL != debugfile)
			debugfptr = fopen(debugfile, "a");
		tried_open = true;
	}

	if (NULL == debugfptr)
		return;

	(void) time(&t);
	tm = localtime(&t);
	tbuf[0] = '\0';
	if (0 == strftime(tbuf, sizeof(tbuf), "%Y-%m-%d %H:%M:%S", tm))
		tbuf[0] = '\0';

	(void) fprintf(debugfptr, "[%s] (%d) %s (%s:%d): ", tbuf, getpid(),
		       function, file, line);

	va_start(ap, format);
	(void) vfprintf(debugfptr, format, ap);
	va_end(ap);

	(void) fprintf(debugfptr, "\n");
	(void) fflush(debugfptr);
}

#else				/* ! ENABLE_DEBUGGING */

/*
 * Stub debugging output function.
 */
void debugging_output( __attribute__ ((unused))
		      const char *function, __attribute__ ((unused))
		      const char *file, __attribute__ ((unused))
		      int line, __attribute__ ((unused))
		      const char *format, ...)
{
}

#endif				/* ENABLE_DEBUGGING */

/* EOF */
