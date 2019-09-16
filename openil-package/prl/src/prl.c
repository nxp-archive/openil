#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <stdint.h>
#include <inttypes.h>
#include <sys/time.h>
#include <time.h>

#define NSEC_PER_USEC 1000L
#define NSEC_PER_MSEC 1000000L
#define NSEC_PER_SEC  1000000000L

enum prl_opt {
	PRL_OPT_COUNT = 0,
	PRL_OPT_EVERY,
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
	[PRL_OPT_EVERY] = {
		.name = "every",
		.has_arg = 1,
		.val = PRL_OPT_EVERY
	},
	[PRL_OPT_HELP] = {
		.name = "help",
		.has_arg = 0,
		.val = PRL_OPT_HELP
	},
	[PRL_OPT_NULL] = { NULL, 0, NULL, 0 }
};

int reliable_double_from_string(double *to, char *from, char **endptr)
{
	int   errno_saved = errno;
	int   rc = 0;
	char *p;

	errno = 0;
	*to = strtod(from, &p);
	if (endptr != NULL) {
		*endptr = p;
	}
	if (errno) {
		fprintf(stderr, "Range error occured while reading \"%s\"", from);
		rc = -errno;
		goto out;
	}
	if (from == p) {
		/* Read nothing */
		fprintf(stderr, "No double stored at \"%s\"", from);
		rc = -errno;
		goto out;
	}
out:
	errno = errno_saved;
	return rc;
}

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

int64_t ns_from_timespec(struct timespec t)
{
	return (t.tv_sec * NSEC_PER_SEC) + t.tv_nsec;
}

void main_loop(uint64_t every_ns, uint64_t count)
{
	char *line = NULL;
	size_t len = 0;
	struct timespec current_time;
	struct timespec last_time;
	int64_t current_time_ns;
	int64_t last_time_ns;
	uint64_t printed_lines = 0;
	bool in_contract;

	setlinebuf(stdin);
	clock_gettime(CLOCK_MONOTONIC, &last_time);
	last_time_ns = ns_from_timespec(last_time);
	/* Round to closest multiple of every_ns */
	last_time_ns /= every_ns;
	last_time_ns *= every_ns;
	while (getline(&line, &len, stdin) != -1) {
		clock_gettime(CLOCK_MONOTONIC, &current_time);
		current_time_ns = ns_from_timespec(current_time);
		if (current_time_ns - last_time_ns < every_ns) {
			/* Spoke too soon?
			 * Only if not too much.
			 */
			in_contract = (printed_lines < count);
		} else {
			/* At least a full every_ns interval has
			 * passed since last line */
			in_contract = true;
			/* Reset the "spoke too much" counter for a
			 * new time interval */
			printed_lines = 0;
			/* Increment last_time_ns to closest every_ns multiple
			 * that is not larger than current_time_ns
			 */
			last_time_ns = current_time_ns;
			last_time_ns /= every_ns;
			last_time_ns *= every_ns;
		}
		if (in_contract) {
			printf("%s", line);
			fflush(stdout);
			printed_lines++;
		}
	}
	free(line);
	fclose(stdin);
}

void usage()
{
	printf("PRL (Pipe Rate Limiter) is a C program for pipeline manipulation\n"
	       "that filters stdin per line, and rate limits stdout to a given rate,\n"
	       "dropping excess lines.\n"
	       "It implements a very crude accounting mechanism similar in nature to a\n"
	       "token bucket filter. As long as lines received on stdin are in contract\n"
	       "(no more than \"--count\" lines on \"--every\" time period),\n"
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
	       "Running PRL makes sense only when the producer program generates\n"
	       "line-buffered output (tail -f, tcpdump -l).\n"
	       "Usage:\n"
	       "prl --count <number of lines> --every <integer>\n");
}

int main(int argc, char **argv)
{
	int opt, opt_index;
	char *opt_every = NULL;
	char *opt_count = NULL;
	char *unit_of_measure;
	double   every;
	uint64_t count;
	uint64_t every_ns;

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
		case PRL_OPT_EVERY:
			if (opt_every) {
				fprintf(stderr, "--every cannot be provided twice!\n");
				return 1;
			}
			opt_every = optarg;
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
	if (!opt_every) {
		fprintf(stderr, "Please supply a time value to --every (1s, 0.5ms, 3.8us, 5ns)\n");
		return 1;
	}
	if (!opt_count) {
		fprintf(stderr, "Please supply a line count to --count\n");
		return 1;
	}

	if (reliable_double_from_string(&every, opt_every, &unit_of_measure) < 0) {
		fprintf(stderr, "Expected integer for --every parameter.\n");
		goto out;
	}
	if (strlen(unit_of_measure) == 0 || strcmp(unit_of_measure, "s") == 0) {
		every_ns = every * NSEC_PER_SEC;
	} else if (strcmp(unit_of_measure, "ms") == 0) {
		every_ns = every * NSEC_PER_MSEC;
	} else if (strcmp(unit_of_measure, "us") == 0) {
		every_ns = every * NSEC_PER_USEC;
	} else if (strcmp(unit_of_measure, "ns") == 0) {
		every_ns = every;
	} else {
		fprintf(stderr, "unexpected unit of measurement \"%s\". "
		                "expected s, ms, us or ns.\n", unit_of_measure);
		goto out;
	}
	if (reliable_uint64_from_string(&count, opt_count, NULL) < 0) {
		fprintf(stderr, "Expected integer for --count parameter.\n");
		goto out;
	}
	main_loop(every_ns, count);
out:
	return 0;
}

