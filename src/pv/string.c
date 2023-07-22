/*
 * Functions for converting strings to numbers.
 *
 * Copyright 2023 Andrew Wood
 *
 * Distributed under the Artistic License v2.0; see `doc/COPYING'.
 */

#include "config.h"
#include "pv.h"

#include <stdio.h>
#include <stdarg.h>

/*
 * Wrapper for sprintf(), with less safe fallbacks for systems without that
 * function.
 *
 * Returns -1 if "str" or "format" are NULL or if "size" is 0.
 *
 * Otherwise, ensures that the buffer "str" is always terminated with a '\0'
 * byte, before returning whatever the system's vsnprintf() or vsprintf()
 * returned.
 */
int pv_snprintf(char *str, size_t size, const char *format, ...)
{
	va_list ap;
	int ret;

	if (NULL == str)
		return -1;
	if (0 == size)
		return -1;
	if (NULL == format)
		return -1;

	str[0] = '\0';

	va_start(ap, format);
#ifdef HAVE_VSNPRINTF
	ret = vsnprintf(str, size, format, ap);
#else				/* ! HAVE_VSNPRINTF */
	ret = vsprintf(str, format, ap);
#endif				/* HAVE_VSNPRINTF */
	va_end(ap);

	str[size - 1] = '\0';

	return ret;
}

/* EOF */
