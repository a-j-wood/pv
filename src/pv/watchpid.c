/*
 * Functions for watching file descriptors in other processes.
 *
 * Copyright 2002-2008, 2010, 2012-2015, 2017, 2021, 2023 Andrew Wood
 *
 * Distributed under the Artistic License v2.0; see `doc/COPYING'.
 */

#include "config.h"
#include "pv.h"
#include "pv-internal.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define _GNU_SOURCE 1
#include <limits.h>

#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>

#ifdef __APPLE__
#include <libproc.h>
#include <sys/proc_info.h>
#endif

int filesize(pvwatchfd_t info)
{
	if (S_ISBLK(info->sb_fd.st_mode)) {
		int fd;

		/*
		 * Get the size of block devices by opening
		 * them and seeking to the end.
		 */
		fd = open(info->file_fdpath, O_RDONLY);
		if (fd >= 0) {
			info->size = lseek(fd, 0, SEEK_END);
			close(fd);
		} else {
			info->size = 0;
		}
	} else if (S_ISREG(info->sb_fd.st_mode)) {
		if ((info->sb_fd_link.st_mode & S_IWUSR) == 0) {
			info->size = info->sb_fd.st_size;
		}
	} else {
		return 4;
	}

	return 0;
}

#ifdef __APPLE__
int pv_watchfd_info(pvstate_t state, pvwatchfd_t info, int automatic)
{
	struct vnode_fdinfowithpath vnodeInfo = { };

	if (NULL == state)
		return -1;
	if (NULL == info)
		return -1;

	if (kill(info->watch_pid, 0) != 0) {
		if (!automatic)
			pv_error(state, "%s %u: %s",
				 _("pid"),
				 info->watch_pid, strerror(errno));
		return 1;
	}

	int32_t proc_fd = (int32_t) info->watch_fd;
	int size = proc_pidfdinfo(info->watch_pid, proc_fd,
				  PROC_PIDFDVNODEPATHINFO, &vnodeInfo,
				  PROC_PIDFDVNODEPATHINFO_SIZE);
	if (size != PROC_PIDFDVNODEPATHINFO_SIZE) {
		pv_error(state, "%s %u: %s %d: %s",
			 _("pid"),
			 info->watch_pid,
			 _("fd"), info->watch_fd, strerror(errno));
		return 3;
	}

	strlcpy(info->file_fdpath, vnodeInfo.pvip.vip_path,
		sizeof(info->file_fdpath));

	info->size = 0;

	if (!(0 == stat(info->file_fdpath, &(info->sb_fd)))) {
		if (!automatic)
			pv_error(state, "%s %u: %s %d: %s: %s",
				 _("pid"),
				 info->watch_pid,
				 _("fd"),
				 info->watch_fd, info->file_fdpath,
				 strerror(errno));
		return 3;
	}

	if (filesize(info) != 0) {
		if (!automatic)
			pv_error(state, "%s %u: %s %d: %s: %s",
				 _("pid"),
				 info->watch_pid,
				 _("fd"),
				 info->watch_fd,
				 info->file_fdpath,
				 _("not a regular file or block device"));
		return 4;
	}

	return 0;
}

#else

/*
 * Fill in the given information structure with the file paths and stat
 * details of the given file descriptor within the given process (given
 * within the info structure).
 *
 * Returns nonzero on error - error codes are:
 *
 *  -1 - info or state were NULL
 *   1 - process does not exist
 *   2 - readlink on /proc/pid/fd/N failed
 *   3 - stat or lstat on /proc/pid/fd/N failed
 *   4 - file descriptor is not opened on a regular file
 *
 * If "automatic" is nonzero, then this fd was picked automatically, and so
 * if it's not readable or not a regular file, no error is displayed and the
 * function just returns an error code.
 */
int pv_watchfd_info(pvstate_t state, pvwatchfd_t info, int automatic)
{
	if (NULL == state)
		return -1;
	if (NULL == info)
		return -1;

	if (kill(info->watch_pid, 0) != 0) {
		if (!automatic)
			pv_error(state, "%s %u: %s",
				 _("pid"),
				 info->watch_pid, strerror(errno));
		return 1;
	}
	(void) pv_snprintf(info->file_fdinfo, sizeof(info->file_fdinfo),
			   "/proc/%u/fdinfo/%d", info->watch_pid,
			   info->watch_fd);
	(void) pv_snprintf(info->file_fd, sizeof(info->file_fd),
			   "/proc/%u/fd/%d", info->watch_pid,
			   info->watch_fd);

	memset(info->file_fdpath, 0, sizeof(info->file_fdpath));
	if (readlink
	    (info->file_fd, info->file_fdpath,
	     sizeof(info->file_fdpath) - 1) < 0) {
		if (!automatic)
			pv_error(state, "%s %u: %s %d: %s",
				 _("pid"),
				 info->watch_pid,
				 _("fd"), info->watch_fd, strerror(errno));
		return 2;
	}

	if (!((0 == stat(info->file_fd, &(info->sb_fd)))
	      && (0 == lstat(info->file_fd, &(info->sb_fd_link))))) {
		if (!automatic)
			pv_error(state, "%s %u: %s %d: %s: %s",
				 _("pid"),
				 info->watch_pid,
				 _("fd"),
				 info->watch_fd, info->file_fdpath,
				 strerror(errno));
		return 3;
	}

	info->size = 0;

	int ret = filesize(info);
	if (ret != 0) {
		if (!automatic)
			pv_error(state, "%s %u: %s %d: %s: %s",
				 _("pid"),
				 info->watch_pid,
				 _("fd"),
				 info->watch_fd,
				 info->file_fdpath,
				 _("not a regular file or block device"));
		return ret;
	}

	return 0;
}
#endif

#ifdef __APPLE__
int pv_watchfd_changed(pvwatchfd_t info)
{
	return 1;
}
#else
/*
 * Return nonzero if the given file descriptor has changed in some way since
 * we started looking at it (i.e.  changed destination or permissions).
 */
int pv_watchfd_changed(pvwatchfd_t info)
{
	struct stat sb_fd, sb_fd_link;

	if ((0 == stat(info->file_fd, &sb_fd))
	    && (0 == lstat(info->file_fd, &sb_fd_link))) {
		if ((sb_fd.st_dev != info->sb_fd.st_dev)
		    || (sb_fd.st_ino != info->sb_fd.st_ino)
		    || (sb_fd_link.st_mode != info->sb_fd_link.st_mode)
		    ) {
			return 1;
		}
	} else {
		return 1;
	}

	return 0;
}
#endif


/*
 * Return the current file position of the given file descriptor, or -1 if
 * the fd has closed or has changed in some way.
 */
long long pv_watchfd_position(pvwatchfd_t info)
{
	long long position;
#ifdef __APPLE__
	struct vnode_fdinfowithpath vnodeInfo = { };
	int32_t proc_fd = (int32_t) info->watch_fd;

	int size = proc_pidfdinfo(info->watch_pid, proc_fd,
				  PROC_PIDFDVNODEPATHINFO, &vnodeInfo,
				  PROC_PIDFDVNODEPATHINFO_SIZE);
	if (size != PROC_PIDFDVNODEPATHINFO_SIZE) {
		return -1;
	}

	position = (long long) vnodeInfo.pfi.fi_offset;
#else
	FILE *fptr;

	if (pv_watchfd_changed(info))
		return -1;

	fptr = fopen(info->file_fdinfo, "r");
	if (NULL == fptr)
		return -1;
	position = -1;
	if (1 != fscanf(fptr, "pos: %llu", &position))
		position = -1;
	fclose(fptr);
#endif

	return position;
}


#ifdef __APPLE__
static int pidfds(pvstate_t state, unsigned int pid,
		  struct proc_fdinfo **fds, int *count)
{
	int size_needed = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, 0, 0);
	if (size_needed == -1) {
		pv_error(state, "%s: unable to list pid fds: %s", _("pid"),
			 strerror(errno));
		return -1;
	}

	*count = size_needed / PROC_PIDLISTFD_SIZE;

	*fds = (struct proc_fdinfo *) malloc(size_needed);
	if (*fds == NULL) {
		pv_error(state, "%s: alloc failed: %s", _("pid"),
			 strerror(errno));
		return -1;
	}

	proc_pidinfo(pid, PROC_PIDLISTFDS, 0, *fds, size_needed);

	return 0;
}
#endif

/*
 * Scan the given process and update the arrays with any new file
 * descriptors.
 *
 * Returns 0 on success, 1 if the process no longer exists or could not be
 * read, or 2 for a memory allocation error.
 */
int pv_watchpid_scanfds(pvstate_t state, pvstate_t pristine,
			unsigned int watch_pid, int *array_length_ptr,
			pvwatchfd_t * info_array_ptr,
			pvstate_t * state_array_ptr, int *fd_to_idx)
{
	char fd_dir[512] = { 0, };
	int array_length = 0;
	struct pvwatchfd_s *info_array = NULL;
	struct pvstate_s *state_array = NULL;

#ifdef __APPLE__
	struct proc_fdinfo *fd_infos = NULL;
	int fd_infos_count = 0;

	if (pidfds(state, watch_pid, &fd_infos, &fd_infos_count) != 0) {
		pv_error(state, "%s: pidfds failed", _("pid"));
		return -1;
	}
#else
	DIR *dptr;
	struct dirent *d;

	(void) pv_snprintf(fd_dir, sizeof(fd_dir), "/proc/%u/fd",
			   watch_pid);

	dptr = opendir(fd_dir);
	if (NULL == dptr)
		return 1;
#endif

	array_length = *array_length_ptr;
	info_array = *info_array_ptr;
	state_array = *state_array_ptr;

#ifdef __APPLE__
	if (fd_infos_count < 1) {
		pv_error(state, "%s: no fds found", _("pid"));
		return -1;
	}
	for (int i = 0; i < fd_infos_count; i++) {
#else
	while ((d = readdir(dptr)) != NULL) {
#endif
		int fd, check_idx, use_idx, rc;
		long long position_now;

		fd = -1;
#ifdef __APPLE__
		fd = fd_infos[i].proc_fd;
#else
		if (sscanf(d->d_name, "%d", &fd) != 1)
			continue;
		if ((fd < 0) || (fd >= FD_SETSIZE))
			continue;
#endif
		/*
		 * Skip if this fd is already known to us.
		 */
		if (fd_to_idx[fd] != -1) {
			continue;
		}

		/*
		 * See if there's an empty slot we can re-use. An empty slot
		 * has a watch_pid of 0.
		 */
		use_idx = -1;
		for (check_idx = 0; check_idx < array_length; check_idx++) {
			if (info_array[check_idx].watch_pid == 0) {
				use_idx = check_idx;
				break;
			}
		}

		/*
		 * If there's no empty slot, extend the arrays.
		 */
		if (use_idx < 0) {
			struct pvwatchfd_s *new_info_array;
			struct pvstate_s *new_state_array;

			array_length++;
			use_idx = array_length - 1;

			if (NULL == info_array) {
				new_info_array =
				    malloc(array_length *
					   sizeof(*info_array));
			} else {
				new_info_array =
				    realloc(info_array,
					    array_length *
					    sizeof(*info_array));
			}
			if (NULL == new_info_array)
				return 2;
			info_array = new_info_array;
			*info_array_ptr = info_array;
			info_array[use_idx].watch_pid = 0;

			if (NULL == state_array) {
				new_state_array =
				    malloc(array_length *
					   sizeof(*state_array));
			} else {
				new_state_array =
				    realloc(state_array,
					    array_length *
					    sizeof(*state_array));
			}
			if (NULL == new_state_array)
				return 2;
			state_array = new_state_array;
			*state_array_ptr = state_array;

			*array_length_ptr = array_length;

			for (check_idx = 0; check_idx < array_length;
			     check_idx++) {
				state_array[check_idx].name =
				    info_array[check_idx].display_name;
				state_array[check_idx].reparse_display = 1;
			}
		}

		debug("%s: %d => index %d", "found new fd", fd, use_idx);

		/*
		 * Initialise the details of this new entry.
		 */
		memcpy(&(state_array[use_idx]), pristine,
		       sizeof(*pristine));
		memset(&(info_array[use_idx]), 0,
		       sizeof(info_array[use_idx]));

		info_array[use_idx].watch_pid = watch_pid;
		info_array[use_idx].watch_fd = fd;
#ifdef __APPLE__
		if (fd_infos[i].proc_fdtype != PROX_FDTYPE_VNODE) {
			continue;
		}
#endif
		rc = pv_watchfd_info(state, &(info_array[use_idx]), 1);

		/*
		 * Lookup failed - mark this slot as being free for re-use.
		 */
		if ((rc != 0) && (rc != 4)) {
			info_array[use_idx].watch_pid = 0;
			debug("%s %d: %s: %d", "fd", fd,
			      "lookup failed - marking slot for re-use",
			      use_idx);
			continue;
		}

		fd_to_idx[fd] = use_idx;

		/*
		 * Not displayable - set fd to -1 so the main loop doesn't
		 * show it.
		 */
		if (rc != 0) {
			debug("%s %d: %s", "fd", fd,
			      "marking as not displayable");
			info_array[use_idx].watch_fd = -1;
		}

		state_array[use_idx].size = info_array[use_idx].size;
		if (state_array[use_idx].size < 1) {
			char *fmt;
			while (NULL !=
			       (fmt =
				strstr(state_array[use_idx].default_format,
				       "%e"))) {
				debug("%s", "zero size - removing ETA");
				/* strlen-1 here to include trailing NUL */
				memmove(fmt, fmt + 2, strlen(fmt) - 1);
				state_array[use_idx].reparse_display = 1;
			}
		}

		state_array[use_idx].name =
		    info_array[use_idx].display_name;

		pv_watchpid_setname(state, &(info_array[use_idx]));

		state_array[use_idx].reparse_display = 1;

		gettimeofday(&(info_array[use_idx].start_time), NULL);

		state_array[use_idx].initial_offset = 0;
		info_array[use_idx].position = 0;

		position_now = pv_watchfd_position(&(info_array[use_idx]));
		if (position_now >= 0) {
			state_array[use_idx].initial_offset = position_now;
			info_array[use_idx].position = position_now;
		}
	}


#ifdef __APPLE__
	free(fd_infos);
#else
	closedir(dptr);
#endif

	return 0;
}


/*
 * Set the display name for the given watched file descriptor, truncating at
 * the relevant places according to the current screen width.
 *
 * If the file descriptor is pointing to a file under the current working
 * directory, show its relative path, not the full path.
 */
void pv_watchpid_setname(pvstate_t state, pvwatchfd_t info)
{
	int path_length, cwd_length, max_display_length;
	char *file_fdpath = info->file_fdpath;

	memset(info->display_name, 0, sizeof(info->display_name));

	path_length = strlen(info->file_fdpath);
	cwd_length = strlen(state->cwd);
	if (cwd_length > 0 && path_length > cwd_length) {
		if (0 ==
		    strncmp(info->file_fdpath, state->cwd, cwd_length)) {
			file_fdpath += cwd_length + 1;
			path_length -= cwd_length + 1;
		}
	}

	max_display_length = (state->width / 2) - 6;
	if (max_display_length >= path_length) {
		(void) pv_snprintf(info->display_name,
				   sizeof(info->display_name),
				   "%4d:%.498s", info->watch_fd,
				   file_fdpath);
	} else {
		int prefix_length, suffix_length;

		prefix_length = max_display_length / 4;
		suffix_length = max_display_length - prefix_length - 3;

		(void) pv_snprintf(info->display_name,
				   sizeof(info->display_name),
				   "%4d:%.*s...%.*s",
				   info->watch_fd, prefix_length,
				   file_fdpath, suffix_length,
				   file_fdpath + path_length -
				   suffix_length);
	}

	debug("%s: %d: [%s]", "set name for fd", info->watch_fd,
	      info->display_name);
}

/* EOF */
