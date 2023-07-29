/*
 * Replacement gettext library header file. Include this within config.h,
 * like this:
 *
 *   #ifdef ENABLE_NLS
 *   # include "library/gettext.h"
 *   #else
 *   # define _(String) (String)
 *   # define N_(String) (String)
 *   #endif
 *
 * Copyright 2002-2008, 2010, 2012-2015, 2017, 2021, 2023 Andrew Wood
 *
 * Distributed under the Artistic License v2.0; see `doc/COPYING'.
 */

#ifndef _LIBRARY_GETTEXT_H
#define _LIBRARY_GETTEXT_H 1

#ifdef HAVE_GETTEXT
# ifdef HAVE_LIBINTL_H
#  include <libintl.h>
# endif
# ifdef HAVE_LOCALE_H
#  include <locale.h>
# endif
# define _(String)	gettext (String)
# define N_(String)	(String)
#else
# define _(String)	minigettext (String)
# define N_(String)	(String)
# ifdef HAVE_LOCALE_H
#  include <locale.h>
# else
#  define setlocale	minisetlocale
#  ifndef LC_ALL
#   define LC_ALL	""
#  endif
# endif
# define bindtextdomain	minibindtextdomain
# define textdomain	minitextdomain
#endif

#ifdef __cplusplus
extern "C" {
#endif

char *minisetlocale(const char *, const char *);
char *minibindtextdomain(const char *, const char *);
char *minitextdomain(const char *);
char *minigettext(const char *);

#ifdef __cplusplus
}
#endif

#endif /* _LIBRARY_GETTEXT_H */

/* EOF */
