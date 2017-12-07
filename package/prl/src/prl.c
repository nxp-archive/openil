#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <stdint.h>
#include <sys/time.h>
#include <time.h>

#define NSEC_PER_SEC  1000000000L
#define NSEC_PER_MSEC 1000000L

enum prl_opt {
	PRL_OPT_COUNT = 0,
	PRL_OPT_EVERY_MS,
	PRL_OPT_HELP,
	PRL_OPT_NULL
};

struct option prl_opts[] = {
	[PRL_OPT_COUNT] = {
		.name = "count",
		.has_arg = 1,
		.flag = NULL,
		.val = PRL_OPT_COUNT
	},
	[PRL_OPT_EVERY_MS] = {
		.name = "every-ms",
		.has_arg = 1,
		.val = PRL_OPT_EVERY_MS
	},
	[PRL_OPT_HELP] = {
		.name = "help",
		.has_arg = 0,
		.val = PRL_OPT_HELP
	},
	[PRL_OPT_NULL] = { NULL, 0, NULL, 0 }
};

int reliable_uint64_from_string(uint64_t *to, char *from, char **endptr)
{
	int   errno_saved = errno;
	int   base = 0;
	int   rc = 0;
	char *p;

	errno = 0;
	if (strncmp(from, "0b", 2) == 0) {
		from += 2;
		base  = 2;
	}
	*to = strtoull(from, &p, base);
	if (endptr != NULL) {
		*endptr = p;
	}
	if (errno) {
		fprintf(stderr, "Integer overflow occured while reading \"%s\"\n", from);
		rc = -1;
		goto out;
	}
	if (from == p) {
		/* Read nothing */
		fprintf(stderr, "No integer stored at \"%s\"\n", from);
		rc = -1;
		goto out;
	}
out:
	errno = errno_saved;
	return rc;
}

int in_contract(struct timespec current_time,
                struct timespec last_time,
                uint64_t every_ms,
                uint64_t count,
                uint64_t *printed_lines)
{
	uint64_t elapsed_ns = (current_time.tv_sec - last_time.tv_sec) * NSEC_PER_SEC +
	                      (current_time.tv_nsec - last_time.tv_nsec);
	if (*printed_lines >= count) {
		return false;
	}
	if (elapsed_ns < every_ms * NSEC_PER_MSEC) {
		return false;
	}
	(*printed_lines)++;
	return true;
}

void main_loop(uint64_t every_ms, uint64_t count)
{
	char *line = NULL;
	size_t len = 0;
	ssize_t read;
	struct timespec current_time;
	struct timespec last_time;
	uint64_t printed_lines = 0;

	clock_gettime(CLOCK_MONOTONIC, &last_time);
	while ((read = getline(&line, &len, stdin)) != -1) {
		clock_gettime(CLOCK_MONOTONIC, &current_time);
		if (in_contract(current_time, last_time, every_ms, count, &printed_lines)) {
			printf("%s", line);
			fflush(stdout);
			last_time = current_time;
			printed_lines = 0;
		}
	}
	free(line);
}

void usage()
{
	printf("PRL (Pipe Rate Limiter) is a C program for pipeline manipulation\n"
	       "that filters stdin per line, and rate limits stdout to a given rate,\n"
	       "dropping excess lines.\n"
	       "It implements a very crude accounting mechanism similar in nature to a\n"
	       "token bucket filter. As long as lines received on stdin are in contract\n"
	       "(no more than \"--count\" lines on \"--every-ms\" millisecond period),\n"
	       "lines on stdin are reproduced per-se on stdout. Stdin lines in excess\n"
	       "of the contract are simply dropped.\n"
	       "\n"
	       "It is useful in situation such as a producer program generating a lot\n"
	       "of output, piped into a consumer that (a) might not need all of it\n"
	       "(b) its own health is more important than consuming input.\n"
	       "If the consumer program is slow to process input, then even having that\n"
	       "extra input data in its stdin buffers will slow it down because it has\n"
	       "to consume time from its event loop just to discard it.\n"
	       "PRL acts as a protection for such slow consumer programs.\n"
	       "\n"
	       "Usage:\n"
	       "prl --count <number of lines> --every-ms <integer>\n");
}

int main(int argc, char **argv)
{
	int opt, opt_index;
	char *opt_every_ms = NULL;
	char *opt_count = NULL;
	uint64_t every_ms;
	uint64_t count;

	while (1) {
		opt = getopt_long(argc, argv, "+c:e:h", prl_opts, &opt_index);
		if (opt == -1)
			break;

		switch (opt) {
		case 'h':
		case PRL_OPT_HELP:
			usage();
			return 0;
		case 'e':
		case PRL_OPT_EVERY_MS:
			if (opt_every_ms) {
				fprintf(stderr, "--every-ms cannot be provided twice!\n");
				return 1;
			}
			opt_every_ms = optarg;
			break;
		case 'c':
		case PRL_OPT_COUNT:
			if (opt_count) {
				fprintf(stderr, "--count cannot be provided twice!\n");
				return 1;
			}
			opt_count = optarg;
			break;
		case '?':
			break;
		default:
			fprintf(stderr, "error: getopt returned character code %d\n", opt);
			return 1;
		}
	}
	if (optind < argc) {
		fprintf(stderr, "error: non-option elements: ");
		while (optind < argc)
			printf("%s ", argv[optind++]);
		printf("\n");
	}
	if (!opt_every_ms) {
		fprintf(stderr, "Please supply a millisecond value to --every-ms\n");
		return 1;
	}
	if (!opt_count) {
		fprintf(stderr, "Please supply a line count to --count\n");
		return 1;
	}

	if (reliable_uint64_from_string(&every_ms, opt_every_ms, NULL) < 0) {
		fprintf(stderr, "Expected integer for --every-ms parameter.\n");
		goto out;
	}
	if (reliable_uint64_from_string(&count, opt_count, NULL) < 0) {
		fprintf(stderr, "Expected integer for --count parameter.\n");
		goto out;
	}
	main_loop(every_ms, count);
out:
	return 0;
}

