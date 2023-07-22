/*
 * Output version information to stdout.
 *
 * Copyright 2002-2008, 2010, 2012-2015, 2017, 2021, 2023 Andrew Wood
 *
 * Distributed under the Artistic License v2.0; see `doc/COPYING'.
 */

#include "config.h"
#include <stdio.h>

/*
 * Display current package version as per GNU standards.
 */
void display_version(void)
{
        /* GNU standard first line format: program and version only */
	printf("%s %s\n", PROGRAM_NAME, VERSION);
	/* GNU standard second line format - "Copyright" always in English */
	printf("Copyright %s %s\n",
	       COPYRIGHT_YEAR, COPYRIGHT_HOLDER);
        /* GNU standard license line and free software notice */
	printf("%s\n", _("License: Artistic v2.0 <https://opensource.org/license/artistic-2-0/>"));
	printf("%s\n", _("This is free software: you are free to change and redistribute it."));
	printf("%s\n", _("There is NO WARRANTY, to the extent permitted by law."));
	/* Project web site link */
	printf("\n%s: <%s>\n", _("Project web site"), PROJECT_HOMEPAGE);
}

/* EOF */
