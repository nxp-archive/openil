#include "motor-jsmn.h"
#include <jsmn.h>
#include <stdio.h>
#include <string.h>

const char *STR_JSMN_ERROR_INVAL = "JSMN_ERROR_INVAL";
const char *STR_JSMN_ERROR_NOMEM = "JSMN_ERROR_NOMEM";
const char *STR_JSMN_ERROR_PART  = "JSMN_ERROR_PART";

const char *STR_JSMN_UNDEFINED = "JSMN_UNDEFINED";
const char *STR_JSMN_OBJECT    = "JSMN_OBJECT";
const char *STR_JSMN_ARRAY     = "JSMN_ARRAY";
const char *STR_JSMN_STRING    = "JSMN_STRING";
const char *STR_JSMN_PRIMITIVE = "JSMN_PRIMITIVE";

static const char *jsmn_err_to_string(int err)
{
	switch (err) {
	case JSMN_ERROR_INVAL: return STR_JSMN_ERROR_INVAL;
	case JSMN_ERROR_NOMEM: return STR_JSMN_ERROR_NOMEM;
	case JSMN_ERROR_PART:  return STR_JSMN_ERROR_PART;
	default:               return NULL;
	}
}

static const char *jsmn_type_to_string(jsmntype_t type)
{
	switch (type) {
	case JSMN_UNDEFINED: return STR_JSMN_UNDEFINED;
	case JSMN_OBJECT:    return STR_JSMN_OBJECT;
	case JSMN_ARRAY:     return STR_JSMN_ARRAY;
	case JSMN_STRING:    return STR_JSMN_STRING;
	case JSMN_PRIMITIVE: return STR_JSMN_PRIMITIVE;
	default:             return NULL;
	}
}

/* Macros for easier-to-understand parser code */
#define CURRENT_TOKEN          (tokens[*tokens_ptr])
#define CURRENT_TOKEN_TYPE     (CURRENT_TOKEN.type)
#define CURRENT_TOKEN_TYPE_STR (jsmn_type_to_string(CURRENT_TOKEN_TYPE))
#define CURRENT_TOKEN_BUF      (&buf[CURRENT_TOKEN.start])
#define CURRENT_TOKEN_LEN      (CURRENT_TOKEN.end - CURRENT_TOKEN.start)
#define CURRENT_TOKEN_CHILDREN (CURRENT_TOKEN.size)
#define NEXT_TOKEN             ((*tokens_ptr)++)

#define CURRENT_TOKEN_MATCHES_STRING(str) \
	(CURRENT_TOKEN_TYPE == JSMN_STRING && \
	 strncmp(str, CURRENT_TOKEN_BUF, CURRENT_TOKEN_LEN) == 0)

#define DIE_IF_UNEXPECTED_TYPE(expected_type, prop_name) \
	do { \
		if (CURRENT_TOKEN_TYPE != expected_type) { \
			fprintf(stderr, "Expected value of type %s " \
			        "for property \"%s\", got %s \"%.*s\"\n", \
			        jsmn_type_to_string(expected_type), prop_name, \
			        CURRENT_TOKEN_TYPE_STR, \
			        CURRENT_TOKEN_LEN, CURRENT_TOKEN_BUF); \
			return -1; \
		} \
	} while (0);
#define DIE_UNKNOWN_KEY() \
	do { \
		fprintf(stderr, "unknown key \"%.*s\" of type %s and " \
		        "having %d children\n", \
		        CURRENT_TOKEN_LEN, CURRENT_TOKEN_BUF, \
		        CURRENT_TOKEN_TYPE_STR, \
		        CURRENT_TOKEN_CHILDREN); \
		return -1; \
	} while (0);

static int motor_parse(struct motor_msg *msg, jsmntok_t *tokens,
                       int *tokens_ptr, int prop_count,
                       const char *buf)
{
	struct motor_coords tmp;
	int left_right = -1;
	int i;

	memset(&tmp, 0, sizeof(tmp));
	for (i = 0; i < prop_count; i++) {
		if (CURRENT_TOKEN_MATCHES_STRING("motor_id")) {
			NEXT_TOKEN;
			DIE_IF_UNEXPECTED_TYPE(JSMN_STRING, "motor_id");
			if (CURRENT_TOKEN_MATCHES_STRING("left")) {
				left_right = 0;
			} else if (CURRENT_TOKEN_MATCHES_STRING("right")) {
				left_right = 1;
			} else {
				fprintf(stderr, "Expected value of \"left\" or \"right\" "
				        "for property motor_id, got %.*s\n",
				        CURRENT_TOKEN_LEN, CURRENT_TOKEN_BUF);
				return -1;
			}
		} else if (CURRENT_TOKEN_MATCHES_STRING("position")) {
			NEXT_TOKEN;
			DIE_IF_UNEXPECTED_TYPE(JSMN_PRIMITIVE, "position");
			sscanf(CURRENT_TOKEN_BUF, "%f", &tmp.position);
		} else if (CURRENT_TOKEN_MATCHES_STRING("rotation")) {
			NEXT_TOKEN;
			DIE_IF_UNEXPECTED_TYPE(JSMN_PRIMITIVE, "rotation");
			sscanf(CURRENT_TOKEN_BUF, "%f", &tmp.rotation);
		} else {
			DIE_UNKNOWN_KEY();
		}
		NEXT_TOKEN;
	}
	memcpy((left_right == 0) ? &msg->left : &msg->right, &tmp, sizeof(tmp));
	return 0;
}

static int msg_obj_parse(struct motor_msg *msg, jsmntok_t *tokens,
                         int *tokens_ptr, int prop_count,
                         const char *buf)
{
	int i, j, rc, motor_prop_count;

	for (i = 0; i < prop_count; i++) {
		if (CURRENT_TOKEN_MATCHES_STRING("board_id")) {
			NEXT_TOKEN;
			DIE_IF_UNEXPECTED_TYPE(JSMN_STRING, "board_id");
			/* XXX: Why +1? */
			snprintf(msg->board_id, CURRENT_TOKEN_LEN + 1, "%s",
			         CURRENT_TOKEN_BUF);
		} else if (CURRENT_TOKEN_MATCHES_STRING("motors")) {
			NEXT_TOKEN;
			DIE_IF_UNEXPECTED_TYPE(JSMN_ARRAY, "motors");
			if (CURRENT_TOKEN_CHILDREN != 2) {
				fprintf(stderr, "Expected motors array to have "
				        "a length of 2, got %d\n",
				        CURRENT_TOKEN_CHILDREN);
				return -1;
			}
			NEXT_TOKEN;
			for (j = 0; j < 2; j++) {
				DIE_IF_UNEXPECTED_TYPE(JSMN_OBJECT, "motor array element");
				motor_prop_count = CURRENT_TOKEN_CHILDREN;
				NEXT_TOKEN;
				rc = motor_parse(msg, tokens, tokens_ptr,
				                 motor_prop_count, buf);
				if (rc < 0) {
					fprintf(stderr, "motor_parse returned %d\n", rc);
					return -1;
				}
			}
		} else {
			DIE_UNKNOWN_KEY();
		}
		NEXT_TOKEN;
	}
	return 0;
}

/* Function populates the struct motor_msg pointed to by *msg
 * by parsing the JSON-encoded message stored in the *buf string
 */
int json_msg_parse(struct motor_msg *msg, const char *buf)
{
	jsmntok_t tokens[20];
	jsmn_parser parser;
	int tokens_ptr_val = 0;
	int *tokens_ptr = &tokens_ptr_val;
	int rc;

	jsmn_init(&parser);
	rc = jsmn_parse(&parser, buf, strlen(buf), tokens, 20);
	if (rc < 0) {
		fprintf(stderr, "could not parse json from buffer %s, rc=%s\n",
		        buf, jsmn_err_to_string(rc));
		return -1;
	}
	DIE_IF_UNEXPECTED_TYPE(JSMN_OBJECT, "root token");
	NEXT_TOKEN;
	return msg_obj_parse(/* struct motor_msg */ msg,
	                     /* jsmntok_t */        tokens,
	                     /* int* */             tokens_ptr,
	                     /* int prop_count */   tokens[0].size,
	                     /* const char* */      buf);
}
