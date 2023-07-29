/*
 * Output command-line help to stdout.
 *
 * Copyright 2002-2008, 2010, 2012-2015, 2017, 2021, 2023 Andrew Wood
 *
 * Distributed under the Artistic License v2.0; see `doc/COPYING'.
 */

#include "config.h"
#include "pv.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#if defined(ENABLE_NLS) && defined(HAVE_WCHAR_H)
#include <wchar.h>
#if defined(HAVE_WCTYPE_H)
#include <wctype.h>
#endif
#endif


/*
 * Return the number of display columns needed to show the given string.
 *
 * To do this, we convert it to a wide character string, and use the wide
 * character display width function "wcswidth()" on it.
 *
 * If NLS is disabled, or the string cannot be converted, this is just the
 * same as "strlen()".
 */
static size_t display_width(const char *string)
{
	size_t width;

#if defined(ENABLE_NLS) && defined(HAVE_WCHAR_H)
	size_t wide_char_count;
	size_t wide_string_buffer_size;
	wchar_t *wide_string;

	if (NULL == string)
		return 0;

	/*@-nullpass@ */
	/*
	 * splint note: mbstowcs() manual page on Linux explicitly says it
	 * takes NULL.
	 */
	wide_char_count = mbstowcs(NULL, string, 0);
	/*@+nullpass@ */
	if (wide_char_count == (size_t) -1) {
		debug("%s: %s: %s", "mbstowcs", string, strerror(errno));
		return strlen(string);	    /* flawfinder: ignore */
		/*
		 * flawfinder rationale: we have already checked for NULL,
		 * and we don't know the size of the originating buffer so
		 * can't use strnlen(); it is up to the caller to provide a
		 * terminated string.
		 */
	}

	wide_string_buffer_size = sizeof(*wide_string) * (1 + wide_char_count);
	wide_string = malloc(wide_string_buffer_size);
	if (NULL == wide_string) {
		perror("malloc");
		return strlen(string);	    /* flawfinder: ignore */
		/* flawfinder rationale: see above. */
	}
	memset(wide_string, 0, wide_string_buffer_size);

	if (mbstowcs(wide_string, string, 1 + wide_char_count) == (size_t) -1) {
		debug("%s: %s: %s", "mbstowcs", string, strerror(errno));
		width = strlen(string);	    /* flawfinder: ignore */
		/* flawfinder rationale: see above. */
	} else if (NULL != wide_string) {
		/*@-unrecog @ */
		/* splint seems unable to see the prototype. */
		width = wcswidth(wide_string, wide_char_count);
		/*@+unrecog @ */
	} else {
		width = 0;
	}

	free(wide_string);

#else				/* ! defined(ENABLE_NLS) && defined(HAVE_WCHAR_H) */
	if (NULL == string)
		return 0;

	width = strlen(string);		    /* flawfinder: ignore */
	/* flawfinder rationale: see above. */
#endif				/* defined(ENABLE_NLS) && defined(HAVE_WCHAR_H) */

	return width;
}


/*
 * The 7-bit ASCII version of display_word_wrap() below - does not
 * understand multi-byte characters.
 */
static void display_word_wrap_7bit(const char *string, size_t display_width, size_t left_margin)
{
	const char *start;
	const char *end;

	if (NULL == string)
		return;

	start = string;

	while (strlen(start) > display_width) {	/* flawfinder: ignore */
		/* flawfinder rationale: see above. */

		end = start + display_width;
		while ((end > start) && (end[0] != ' '))
			end--;
		if (end == start) {
			end = start + display_width;
		} else {
			end++;
		}
		printf("%.*s", (int) (end - start), start);
		if (end == start)
			end++;
		start = end;
		if (start[0] != '\0')
			printf("\n%*s", (int) left_margin, "");
	}

	printf("%s", start);
}


/*
 * Output a string to standard output, word wrapping to "display_width"
 * display character positions, and left-padding any new lines after the
 * first one with "left_margin" spaces.
 *
 * Wide characters are handled if NLS is enabled, but if they can't be, this
 * falls back to a version which just counts bytes as characters.
 */
static void display_word_wrap(const char *string, size_t display_width, size_t left_margin)
{
#if defined(ENABLE_NLS) && defined(HAVE_WCHAR_H)
	size_t wide_char_count;
	size_t wide_string_buffer_size;
	wchar_t *wide_string;
	size_t start_idx, end_idx, chars_remaining;

	if (NULL == string)
		return;

	/*@-nullpass@ */
	/* splint note: see earlier mbstowcs() call. */
	wide_char_count = mbstowcs(NULL, string, 0);
	/*@+nullpass@ */
	if (wide_char_count == (size_t) -1) {
		debug("%s: %s: %s", "mbstowcs", string, strerror(errno));
		display_word_wrap_7bit(string, display_width, left_margin);
		return;
	}

	wide_string_buffer_size = sizeof(*wide_string) * (1 + wide_char_count);
	wide_string = malloc(wide_string_buffer_size);
	if (NULL == wide_string) {
		perror("malloc");
		display_word_wrap_7bit(string, display_width, left_margin);
		return;
	}
	memset(wide_string, 0, wide_string_buffer_size);

	if (mbstowcs(wide_string, string, 1 + wide_char_count) == (size_t) -1) {
		debug("%s: %s: %s", "mbstowcs", string, strerror(errno));
		free(wide_string);
		display_word_wrap_7bit(string, display_width, left_margin);
		return;
	}

	start_idx = 0;
	chars_remaining = wide_char_count;

	while (chars_remaining > 0 && wcswidth(&(wide_string[start_idx]), chars_remaining) > display_width) {
		size_t next_idx;

		end_idx = start_idx + display_width;
		while ((end_idx > start_idx) && (!iswspace(wide_string[end_idx])))
			end_idx--;
		if (end_idx == start_idx) {
			end_idx = start_idx + display_width;
		} else {
			end_idx++;
		}

		next_idx = end_idx;
		if (end_idx == start_idx)
			next_idx++;

		while (start_idx < end_idx && start_idx < wide_char_count) {
			char multi_byte_string[MB_CUR_MAX + 1];	/* flawfinder: ignore */
			/*
			 * flawfinder rationale: array is explicitly
			 * cleared, large enough according to the wctomb()
			 * manual, and we explicitly terminate the string.
			 */
			memset(multi_byte_string, 0, MB_CUR_MAX + 1);
			if (wctomb(multi_byte_string, wide_string[start_idx]) >= 0) {
				multi_byte_string[MB_CUR_MAX] = '\0';
				printf("%s", multi_byte_string);
			}
			start_idx++;
		}

		start_idx = next_idx;
		if (start_idx < wide_char_count)
			printf("\n%*s", (int) left_margin, "");

		chars_remaining = wide_char_count - start_idx;
	}

	while (start_idx < wide_char_count) {
		char multi_byte_string[MB_CUR_MAX + 1];	/* flawfinder: ignore */
		/* flawfinder rationale as above. */
		memset(multi_byte_string, 0, MB_CUR_MAX + 1);
		if (wctomb(multi_byte_string, wide_string[start_idx]) >= 0) {
			multi_byte_string[MB_CUR_MAX] = '\0';
			printf("%s", multi_byte_string);
		}
		start_idx++;
	}

	free(wide_string);

#else				/* ! defined(ENABLE_NLS) && defined(HAVE_WCHAR_H) */
	display_word_wrap_7bit(string, display_width, left_margin);
#endif				/* defined(ENABLE_NLS) && defined(HAVE_WCHAR_H) */
}


/*
 * Structure holding the displayed descriptions of each option - the short
 * option such as "-s", its long counterpart such as "--size", the name of
 * its argument such as "SIZE", and the description of what the option does. 
 * Any of them may be NULL.
 *
 * In the initialiser for this structure, translatable strings are wrapped
 * with N_() to indicate that they are to be translated into the operator's
 * language by this function at run-time.
 *
 * Note that "opt_short" and "opt_long" should never be marked as
 * translatable, as they must remain consistent across all locales.
 *
 * The list is terminated with a NULL opt_short value - to leave a gap, set
 * opt_short to an empty string instead.
 */
struct option_definition_s {
	/*@null@ */ const char *opt_short;
	/*@null@ */ const char *opt_long;
	/*@null@ *//*@observer@ */ const char *opt_argument;
	/*@null@ *//*@observer@ */ const char *opt_description;
	struct {
		/*
		 * Structure holding the width, in display character
		 * positions, of the individual parts of the description of
		 * each option - calculated after initialisation, so that
		 * translation can be performed.
		 */
		size_t opt_short;
		size_t opt_long;
		size_t opt_argument;
		size_t opt_description;
	} width;
};


/*
 * Display command-line help.
 */
void display_help(void)
{
	struct option_definition_s option_definitions[] = {
		{ "-p", "--progress", NULL,
		 N_("show progress bar"),
		 { 0, 0, 0, 0} },
		{ "-t", "--timer", NULL,
		 N_("show elapsed time"),
		 { 0, 0, 0, 0} },
		{ "-e", "--eta", NULL,
		 N_("show estimated time of arrival (completion)"),
		 { 0, 0, 0, 0} },
		{ "-I", "--fineta", NULL,
		 N_("show absolute estimated time of arrival (completion)"),
		 { 0, 0, 0, 0} },
		{ "-r", "--rate", NULL,
		 N_("show data transfer rate counter"),
		 { 0, 0, 0, 0} },
		{ "-a", "--average-rate", NULL,
		 N_("show data transfer average rate counter"),
		 { 0, 0, 0, 0} },
		{ "-m", "--average-rate-window", N_("SEC"),
		 N_("compute average rate over past SEC seconds (default 30s)"),
		 { 0, 0, 0, 0} },
		{ "-b", "--bytes", NULL,
		 N_("show number of bytes transferred"),
		 { 0, 0, 0, 0} },
		{ "-8", "--bits", NULL,
		 N_("show number of bits transferred"),
		 { 0, 0, 0, 0} },
		{ "-T", "--buffer-percent", NULL,
		 N_("show percentage of transfer buffer in use"),
		 { 0, 0, 0, 0} },
		{ "-A", "--last-written", _("NUM"),
		 N_("show NUM bytes last written"),
		 { 0, 0, 0, 0} },
		{ "-F", "--format", N_("FORMAT"),
		 N_("set output format to FORMAT"),
		 { 0, 0, 0, 0} },
		{ "-n", "--numeric", NULL,
		 N_("output percentages, not visual information"),
		 { 0, 0, 0, 0} },
		{ "-q", "--quiet", NULL,
		 N_("do not output any transfer information at all"),
		 { 0, 0, 0, 0} },
		{ "", NULL, NULL, NULL, { 0, 0, 0, 0} },
		{ "-W", "--wait", NULL,
		 N_("display nothing until first byte transferred"),
		 { 0, 0, 0, 0} },
		{ "-D", "--delay-start", N_("SEC"),
		 N_("display nothing until SEC seconds have passed"),
		 { 0, 0, 0, 0} },
		{ "-s", "--size", N_("SIZE"),
		 N_("set estimated data size to SIZE bytes"),
		 { 0, 0, 0, 0} },
		{ "-l", "--line-mode", NULL,
		 N_("count lines instead of bytes"),
		 { 0, 0, 0, 0} },
		{ "-0", "--null", NULL,
		 N_("lines are null-terminated"),
		 { 0, 0, 0, 0} },
		{ "-i", "--interval", N_("SEC"),
		 N_("update every SEC seconds"),
		 { 0, 0, 0, 0} },
		{ "-w", "--width", N_("WIDTH"),
		 N_("assume terminal is WIDTH characters wide"),
		 { 0, 0, 0, 0} },
		{ "-H", "--height", N_("HEIGHT"),
		 N_("assume terminal is HEIGHT rows high"),
		 { 0, 0, 0, 0} },
		{ "-N", "--name", N_("NAME"),
		 N_("prefix visual information with NAME"),
		 { 0, 0, 0, 0} },
		{ "-f", "--force", NULL,
		 N_("output even if standard error is not a terminal"),
		 { 0, 0, 0, 0} },
		{ "-c", "--cursor", NULL,
		 N_("use cursor positioning escape sequences"),
		 { 0, 0, 0, 0} },
		{ "", NULL, NULL, NULL, { 0, 0, 0, 0} },
		{ "-L", "--rate-limit", N_("RATE"),
		 N_("limit transfer to RATE bytes per second"),
		 { 0, 0, 0, 0} },
		{ "-B", "--buffer-size", N_("BYTES"),
		 N_("use a buffer size of BYTES"),
		 { 0, 0, 0, 0} },
		{ "-C", "--no-splice", NULL,
		 N_("never use splice(), always use read/write"),
		 { 0, 0, 0, 0} },
		{ "-E", "--skip-errors", NULL,
		 N_("skip read errors in input"),
		 { 0, 0, 0, 0} },
		{ "-S", "--stop-at-size", NULL,
		 N_("stop after --size bytes have been transferred"),
		 { 0, 0, 0, 0} },
		{ "-Y", "--sync", NULL,
		 N_("flush cache to disk after every write"),
		 { 0, 0, 0, 0} },
		{ "-K", "--direct-io", NULL,
		 N_("use direct I/O to bypass cache"),
		 { 0, 0, 0, 0} },
#ifdef HAVE_IPC
		{ "-R", "--remote", N_("PID"),
		 N_("update settings of process PID"),
		 { 0, 0, 0, 0} },
#endif				/* HAVE_IPC */
		{ "", NULL, NULL, NULL, { 0, 0, 0, 0} },
		{ "-P", "--pidfile", N_("FILE"),
		 N_("save process ID in FILE"),
		 { 0, 0, 0, 0} },
		{ "", NULL, NULL, NULL, { 0, 0, 0, 0} },
		{ "-d", "--watchfd", N_("PID[:FD]"),
		 N_("watch file FD opened by process PID"),
		 { 0, 0, 0, 0} },
		{ "", NULL, NULL, NULL, { 0, 0, 0, 0} },
		{ "-h", "--help", NULL,
		 N_("show this help and exit"),
		 { 0, 0, 0, 0} },
		{ "-V", "--version", NULL,
		 N_("show version information and exit"),
		 { 0, 0, 0, 0} },
#ifdef ENABLE_DEBUGGING
		{ "-!", "--debug", N_("FILE"),
		 N_("write debug logs to FILE"),
		 { 0, 0, 0, 0} },
#endif
		{ NULL, NULL, NULL, NULL, { 0, 0, 0, 0} }
	};
	unsigned int option_index;
	size_t widest_option_width = 0;
	size_t description_left_margin = 0;
	size_t min_description_width = 50;
	size_t right_margin = 77;
	const char *program_description;
	const char *bug_report_note;
	unsigned int terminal_width = 0, terminal_height = 0;

	pv_screensize(&terminal_width, &terminal_height);
	if (terminal_width > 5) {
		right_margin = (size_t) (terminal_width - 3);
	}

	/*@-formatconst@ */
	/*
	 * splint note: unavoidable use of %s in translated string.  Should
	 * be hard to exploit - the message catalogue would have to be
	 * replaced or forced to load from another location.
	 */
	printf(_("Usage: %s [OPTION] [FILE]..."), PROGRAM_NAME);
	/*@+formatconst@ */

	printf("\n");

	/*@-mustfreefresh@ */
	/*
	 * splint note: the gettext calls made by _() cause memory leak
	 * warnings, but in this case it's unavoidable, and mitigated by the
	 * fact we only translate each string once.
	 */
	program_description = _("Concatenate FILE(s), or standard input, to standard output, with monitoring.");
	if (NULL != program_description) {
		display_word_wrap(program_description, right_margin, 0);
		printf("\n");
	}

	printf("\n");

	/*
	 * Translate the help text, and calculate the displayed width of
	 * each part of each option definition.  The total display width of
	 * the short option, long option, and option argument together form
	 * the "option" width - we look for the widest one to calculate the
	 * left margin for all of the descriptions to start at.
	 */
	for (option_index = 0; NULL != option_definitions[option_index].opt_short; option_index++) {
		struct option_definition_s *definition;
		size_t option_width;

		definition = &(option_definitions[option_index]);
		option_width = 0;

		definition->width.opt_short = display_width(definition->opt_short);
		definition->width.opt_long = 0;
		definition->width.opt_argument = 0;
		definition->width.opt_description = 0;

		if (NULL != definition->opt_long) {
			definition->width.opt_long = display_width(definition->opt_long);
		}

		if (NULL != definition->opt_argument) {
			/*@observer@ */ const char *translated;
			translated = _(definition->opt_argument);
			if (NULL != translated) {
				definition->opt_argument = translated;
			}
			definition->width.opt_argument = display_width(definition->opt_argument);
		}

		if (NULL != definition->opt_description) {
			/*@observer@ */ const char *translated;
			translated = _(definition->opt_description);
			if (NULL != translated) {
				definition->opt_description = translated;
			}
			definition->width.opt_description = display_width(definition->opt_description);
		}

		/*
		 * The option_width is padded with a left margin of 2
		 * spaces, a ", " between the short and long options, a
		 * space between the long option and the argument, and two
		 * spaces after the argument:
		 *
		 * "  <short>, <long> <arg>  <description>"
		 *
		 * If we don't have getopt_long() then ", <long>" is omitted.
		 */
		option_width += 2 + definition->width.opt_short;	/* "  short" */
#ifdef HAVE_GETOPT_LONG
		option_width += 2 + definition->width.opt_long;	/* ", <long>" */
#endif
		option_width += 1 + definition->width.opt_argument;	/* " ARG" */
		option_width += 2;	    /* final 2 spaces */

		if (option_width > widest_option_width) {
			widest_option_width = option_width;
		}
	}

	/*
	 * Set the left margin for the option descriptions, based on the
	 * widest option width, or (right margin - min_description_width),
	 * whichever is less, so that there is always room for
	 * "min_description_width" characters of description.
	 */
	description_left_margin = right_margin - min_description_width;
	if (widest_option_width < description_left_margin) {
		description_left_margin = widest_option_width;
	}

	debug("%s: description_left_margin=%d, widest_option_width=%d, right_margin=%d", "help display",
	      (int) description_left_margin, (int) widest_option_width, (int) right_margin);

	/*
	 * Display each of the option definitions, word wrapping the
	 * descriptions.
	 */
	for (option_index = 0; NULL != option_definitions[option_index].opt_short; option_index++) {
		struct option_definition_s *definition;
		size_t option_width;

		definition = &(option_definitions[option_index]);
		option_width = 0;

		if (definition->width.opt_short > 0 && NULL != definition->opt_short) {
			printf("  %s", definition->opt_short);
			option_width += 2 + definition->width.opt_short;
		}
#ifdef HAVE_GETOPT_LONG
		if (definition->width.opt_long > 0 && NULL != definition->opt_long) {
			printf(", %s", definition->opt_long);
			option_width += 2 + definition->width.opt_long;
		}
#endif
		if (definition->width.opt_argument > 0 && NULL != definition->opt_argument) {
			printf(" %s", definition->opt_argument);
			option_width += 1 + definition->width.opt_argument;
		}

		/* Just start a new line if there's no description. */
		if ((0 == definition->width.opt_description) || (NULL == definition->opt_description)) {
			printf("\n");
			continue;
		}

		/*
		 * If the option is too wide, start a new line for the
		 * description.  In both cases, pad with spaces up to the
		 * description left margin.
		 */
		if (option_width > description_left_margin) {
			printf("\n%*s", (int) description_left_margin, "");
		} else if (option_width < description_left_margin) {
			printf("%*s", (int) (description_left_margin - option_width), "");
		}

		/* Output the description, word wrapped. */
		display_word_wrap(definition->opt_description, right_margin - description_left_margin,
				  description_left_margin);

		printf("\n");
	}

	printf("\n");

	bug_report_note = _("Please report any bugs to %s.");
	if (NULL != bug_report_note) {
		/*@-formatconst@ */
		/*
		 * splint note: see earlier "formatconst" note.
		 * flawfinder: same reason.
		 */
		printf(bug_report_note, BUG_REPORTS_TO);	/* flawfinder: ignore */
		/*@+formatconst@ */
	}

	printf("\n");
}

/* EOF */
