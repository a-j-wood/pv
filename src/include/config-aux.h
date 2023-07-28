/*
 * Standard definitions to make use of the config.h values set by the
 * `configure' script.  Include this after config.h and before anything
 * else.
 *
 * Copyright 2002-2008, 2010, 2012-2015, 2017, 2021, 2023 Andrew Wood
 *
 * Distributed under the Artistic License v2.0; see `doc/COPYING'.
 */
 
#ifdef ENABLE_NLS
# include "library/gettext.h"
#else
# define _(String) (String)
# define N_(String) (String)
#endif

#undef HAVE_IPC
#ifdef HAVE_SYS_IPC_H
#define HAVE_IPC 1
#endif

#undef CURSOR_ANSWERBACK_BYTE_BY_BYTE
#ifndef _AIX
#define CURSOR_ANSWERBACK_BYTE_BY_BYTE 1
#endif

/* Boolean type support */
#ifdef HAVE_STDBOOL_H
# include <stdbool.h>
#else
# ifndef HAVE__BOOL
#  ifdef __cplusplus
typedef bool _Bool;
#  else
#   define _Bool signed char
#  endif
# endif
# define bool _Bool
# define false 0
# define true 1
# define __bool_true_false_are_defined 1
#endif

/* EOF */
