/*
 * This is automatically generated callbacks file
 * It contains 3 parts: Configuration callbacks, RPC callbacks and state data callbacks.
 * Do NOT alter function signatures or any structures unless you know exactly what you are doing.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/inotify.h>
#include <libxml/tree.h>
#include <libnetconf_xml.h>
#include <pthread.h>
#include <semaphore.h>

#define SJA1105_NETCONF_NS "http://nxp.com/ns/yang/tsn/sja1105"

typedef enum {
	REG_UINT64 = 0,
	REG_ARRAY = 1
} reg_type;

struct reg_desp {
	char name[128];
	int exist;
	reg_type type;
	char value[256];
};

/* transAPI version which must be compatible with libnetconf */
int transapi_version = 6;

char *config_xml_list[] = {};

const char conf_folder[]="/etc/sja1105";
const char datastore_folder[]="/usr/local/etc/netopeer/sja1105/datastore.xml";
const char command_name[]="sja1105-tool";

/* Signal to libnetconf that configuration data were modified by any callback.
 * 0 - data not modified
 * 1 - data have been modified
 */
int config_modified = 0;

pthread_mutex_t file_mutex;

const char netconf_file_dir[] = "/etc/sja1105/";

enum ENTRY_COUNT_LIST {
	SCHEDULE_TABLE = 0,
	SCHEDULE_ENTRY_POINTS,
	SCHEDULE_PARAMETERS,
	SCHEDULE_ENTRY_POINTS_PARAMETERS,
	ENTRY_COUNT_LIST_COUNTS
};

int entry_count[ENTRY_COUNT_LIST_COUNTS];

/*
 * Determines the callbacks order.
 * Set this variable before compilation and DO NOT modify it in runtime.
 * TRANSAPI_CLBCKS_LEAF_TO_ROOT (default)
 * TRANSAPI_CLBCKS_ROOT_TO_LEAF
 */
const TRANSAPI_CLBCKS_ORDER_TYPE callbacks_order = TRANSAPI_CLBCKS_ORDER_DEFAULT;

/* Do not modify or set! This variable is set by libnetconf to announce edit-config's error-option
Feel free to use it to distinguish module behavior for different error-option values.
 * Possible values:
 * NC_EDIT_ERROPT_STOP - Following callback after failure are not executed, all successful callbacks executed till
                         failure point must be applied to the device.
 * NC_EDIT_ERROPT_CONT - Failed callbacks are skipped, but all callbacks needed to apply configuration changes are executed
 * NC_EDIT_ERROPT_ROLLBACK - After failure, following callbacks are not executed, but previous successful callbacks are
                         executed again with previous configuration data to roll it back.
 */
NC_EDIT_ERROPT_TYPE erropt = NC_EDIT_ERROPT_NOTSET;

void clear_entry_count()
{
	int i;

	for(i = 0; i < ENTRY_COUNT_LIST_COUNTS; i++) {
		entry_count[i] = 0;
	}
}

char *sja1105_run_cmd(char *command_run)
{
	FILE * fp;
	char buffer[1024];
	char *rc;

	fp = popen(command_run, "r");
	rc = fgets(buffer, sizeof(buffer), fp);
	pclose(fp);

	nc_verb_verbose("running command %s done!\n", command_run);
	return rc;
}

int write_to_datastore(char *file_name);
int file_validate(char *file);

/**
 * @brief Initialize plugin after loaded and before any other functions are called.

 * This function should not apply any configuration data to the controlled device. If no
 * running is returned (it stays *NULL), complete startup configuration is consequently
 * applied via module callbacks. When a running configuration is returned, libnetconf
 * then applies (via module's callbacks) only the startup configuration data that
 * differ from the returned running configuration data.

 * Please note, that copying startup data to the running is performed only after the
 * libnetconf's system-wide close - see nc_close() function documentation for more
 * information.

 * @param[out] running	Current configuration of managed device.

 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
int transapi_init(xmlDocPtr *running) {
	int res;
	static int init_flag = 1;

	nc_verb_verbose("transapi_init: run sja1105-tool config load stanard_policy\n");
  
	res = pthread_mutex_init(&file_mutex,NULL);    /* ........ */
	if (res != 0) {
		perror("Mutex initialization failed");
		exit(EXIT_FAILURE);
	}

	if (init_flag) {
		sja1105_run_cmd("sja1105-tool config default ls1021atsn");
		sja1105_run_cmd("sja1105-tool config upload");
		clear_entry_count();
		init_flag = 0;

		if (access(datastore_folder, F_OK) == 0) {
			printf("datastore.xml exist!\n");
			xmlNodePtr startup_node = NULL, node;
			xmlDocPtr datastore = xmlReadFile(datastore_folder, NULL, XML_PARSE_NOERROR | XML_PARSE_NOWARNING | XML_PARSE_NOBLANKS | XML_PARSE_NSCLEAN);
			/* get the startup node */
			for (node = datastore->children; node != NULL; node = node->next) {
				if (node->type != XML_ELEMENT_NODE || xmlStrcmp(node->name, BAD_CAST "datastores") != 0) {
					continue;
				}
				for (node = node->children; node != NULL; node = node->next) {
					if (node->type != XML_ELEMENT_NODE || xmlStrcmp(node->name, BAD_CAST "startup") != 0) {
						continue;
					}
					startup_node = node;
					break;
				}
				break;
			}

			if ((startup_node != NULL)  && (startup_node->children != NULL)) {
				/* datastore is exist */
				xmlFreeDoc(datastore);
				goto initdone;
			}

			xmlFreeDoc(datastore);
		}

		*running = xmlNewDoc(BAD_CAST "1.0");

		char newnodes_file[512];
		char file_name[] = "standard.xml";

		if(file_validate(file_name))
			return -1;
	
		if (pthread_mutex_trylock(&file_mutex) != 0) {
		/* file is still editing */
			return -1;
		}

		memset(newnodes_file, '\0', sizeof(newnodes_file) - 1);
		sprintf(newnodes_file, "%s/%s", conf_folder, file_name);

		/* Init libxml */     
		xmlInitParser();

		xmlDocPtr doc_newnodes = xmlReadFile(newnodes_file, NULL, 0);
		xmlNodePtr root_newnodes = xmlDocGetRootElement(doc_newnodes);

		if (strcasecmp((char*) root_newnodes->name, "sja1105")) {
			fprintf(stderr, "Root node must be named \"sja1105\"!\n");
			xmlFreeDoc(doc_newnodes);
			xmlCleanupParser();
			xmlMemoryDump();
			pthread_mutex_unlock(&file_mutex);
			return -1;
		}

		xmlNodePtr rootnode = xmlCopyNodeList(root_newnodes);	

		xmlFreeDoc(doc_newnodes);

		/* Shutdown libxml */
		xmlCleanupParser();
    
		/*
		* this is to debug memory for regression tests
		*/
		xmlMemoryDump();
		pthread_mutex_unlock(&file_mutex);

		xmlDocSetRootElement(*running, rootnode);

	}

initdone:
	return EXIT_SUCCESS;
}

/**
 * @brief Free all resources allocated on plugin runtime and prepare plugin for removal.
 */
void transapi_close(void) {

	pthread_mutex_destroy(&file_mutex);
	return;
}

int sja1105_modify_reg(char *table_name, xmlNodePtr new_node, reg_type *type, char **options, int len)
{
	xmlNodePtr n1;
	struct reg_desp *reg_list;
	char *contend;
	char cmd_modify[1024];
	int i;

	reg_list = (struct reg_desp *)calloc(len, sizeof(struct reg_desp));
	for (i = 0; i < len; i++) {
		strcpy((reg_list + i)->name, options[i]);
		(reg_list + i)->type = *(type + i);
	}

	for (n1 = new_node->children; n1 != NULL; n1 = n1->next) {

		if (n1->type != XML_ELEMENT_NODE) {
			printf("not xml element\n");
			continue;
		}

		contend = (char*)xmlNodeGetContent(n1);

		for (i = 0; i < len; i++) {
			if (xmlStrEqual(n1->name, BAD_CAST (reg_list + i)->name)) {
				nc_verb_verbose("found %s = %s\n", (reg_list + i)->name, (char*)xmlNodeGetContent(n1));
				(reg_list + i)->exist = 1;
				strcpy((reg_list + i)->value, contend); 
			}
		}
		free(contend);
	}

	if (!strcmp(table_name, "xmii-mode-parameters-table")) {
		sprintf(reg_list->value, "%s", "0x0");
	} else if (reg_list->exist != 1){
		free(reg_list);
		return -1;
	}

	/* set value by sja1105-tool */
	for (i = 1; i < len; i++) {
		if ((reg_list + i)->exist) {
			if ((reg_list + i)->type == REG_UINT64)
				sprintf(cmd_modify, "sja1105-tool config modify %s[%s] %s %s", table_name,
						reg_list->value, (reg_list + i)->name, (reg_list + i)->value);
			else
				sprintf(cmd_modify, "sja1105-tool config modify %s[%s] %s \"%s\"", table_name,
						reg_list->value, (reg_list + i)->name, (reg_list + i)->value);

			sja1105_run_cmd(cmd_modify);
		}
	}

	sja1105_run_cmd("sja1105-tool config upload");

	free(reg_list);
	return 0;
}

int sja1105_add_entry(char *table_name, int number)
{
	char command[256];
	char *rc;

	/*sja1105-tool conf mod schedule-table entry-count 2*/
	sprintf(command, "sja1105-tool conf mod %s entry-count %d", table_name, number);

	rc = sja1105_run_cmd(command);
	if (rc == NULL)
		return 0;
	return -1;
}

/**
 * @brief Retrieve state data from device and return them as XML document
 *
 * @param model	Device data model. libxml2 xmlDocPtr.
 * @param running	Running datastore content. libxml2 xmlDocPtr.
 * @param[out] err  Double pointer to error structure. Fill error when some occurs.
 * @return State data as libxml2 xmlDocPtr or NULL in case of error.
 */
xmlDocPtr get_state_data(xmlDocPtr model, xmlDocPtr running, struct nc_err **err) {
	nc_verb_verbose("get_state_data\n");
	FILE *fp;
	char cmd_xml_list[256];
	char command_line[256];
	xmlDocPtr doc = NULL;
	xmlNodePtr root;
	xmlNsPtr ns;

	doc = xmlNewDoc(BAD_CAST "1.0");
	xmlDocSetRootElement(doc, root = xmlNewDocNode(doc, NULL, BAD_CAST "sja1105", NULL));
	ns = xmlNewNs(root, BAD_CAST SJA1105_NETCONF_NS, NULL);
	xmlSetNs(root, ns);

	xmlNodePtr node = xmlNewNode(NULL, BAD_CAST "config-files");
	xmlAddChild(root, node);

	sprintf(command_line, "ls -l %s/* | grep .xml | awk '{print $9}'", netconf_file_dir);
	if ((fp = popen(command_line, "r")) == NULL) {
		printf("command fail: ls -l %s/*\n", netconf_file_dir);
		return(NULL);
	}

	while (fgets(cmd_xml_list, 256, fp) != NULL) {
		nc_verb_verbose("found: %s\n", cmd_xml_list);
		char file_name[128];
		char temp[128];
		int len;

		memset(temp, 0, sizeof(temp));
		memset(file_name, 0, sizeof(file_name));
		strcpy(temp, cmd_xml_list + strlen(netconf_file_dir) + 1);
		len = strlen(temp) - 1;
		strncpy(file_name, temp, len);
		xmlNewChild(node, root->ns, BAD_CAST "configFile", BAD_CAST file_name);
	}

	pclose(fp);
	return(doc);
}
/*
 * Mapping prefixes with namespaces.
 * Do NOT modify this structure!
 */
struct ns_pair namespace_mapping[] = {{"nxp", SJA1105_NETCONF_NS}, {NULL, NULL}};

/*
 * CONFIGURATION callbacks
 * Here follows set of callback functions run every time some change in associated part of running datastore occurs.
 * You can safely modify the bodies of all function as well as add new functions for better lucidity of code.
 */

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:schedule-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_schedule_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_schedule_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"winstindex",
		"winend",
		"winst",
		"destports",
		"setvalid",
		"txen",
		"resmedia_en",
		"resmedia",
		"vlindex",
		"delta"
	};
	reg_type type[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	if (op & XMLDIFF_ADD) {
		entry_count[SCHEDULE_TABLE]++;
		sja1105_add_entry("schedule-table", entry_count[SCHEDULE_TABLE]);
	}

	rc = sja1105_modify_reg("schedule-table", new_node, type, options, len);
	if (rc < 0)
		return -1; 

	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:schedule-entry-points-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_schedule_entry_points_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_schedule_entry_points_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"subschindx",
		"delta",
		"address"
	};
	reg_type type[] = {0, 0, 0, 0};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	if (op & XMLDIFF_ADD) {
		entry_count[SCHEDULE_ENTRY_POINTS]++;
		sja1105_add_entry("schedule-entry-points-table", entry_count[SCHEDULE_ENTRY_POINTS]);
	}

	rc = sja1105_modify_reg("schedule-entry-points-table", new_node, type, options, len);
	if (rc < 0)
		return -1; 

	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:vl-lookup-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_vl_lookup_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_vl_lookup_table_nxp_entry\n");
	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:vl-policing-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_vl_policing_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_vl_policing_table_nxp_entry\n");
	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:vl-forwarding-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_vl_forwarding_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_vl_forwarding_table_nxp_entry\n");
	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:l2-address-lookup-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_l2_address_lookup_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_l2_address_lookup_table_nxp_entry\n");
	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:l2-policing-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_l2_policing_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_l2_policing_table_nxp_entry\n");

	int rc;
	char *options[] = {
		"index",
		"sharindx",
		"smax",
		"rate",
		"maxlen",
		"partition"
	};
	reg_type type[] = {0, 0, 0, 0, 0, 0};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	rc = sja1105_modify_reg("l2-policing-table", new_node, type, options, len);
	if (rc < 0)
		return -1; 

	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:vlan-lookup-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_vlan_lookup_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_vlan_lookup_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"ving_mirr",
		"vegr_mirr",
		"vmemb_port",
		"vlan_bc",
		"tag_port",
		"vlanid"
	};
	reg_type type[] = {0, 0, 0, 0, 0, 0, 0};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	rc = sja1105_modify_reg("vlan-lookup-table", new_node, type, options, len);
	if (rc < 0)
		return -1;

	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:l2-forwarding-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_l2_forwarding_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_l2_forwarding_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"bc_domain",
		"reach_port",
		"fl_domain",
		"vlan_pmap"
	};
	reg_type type[] = {0, 0, 0, 0, 1};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	rc = sja1105_modify_reg("l2-forwarding-table", new_node, type, options, len);
	if (rc < 0)
		return -1;

	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:mac-configuration-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_mac_configuration_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_mac_configuration_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"top",
		"base",
		"enabled",
		"ifg",
		"speed",
		"tp_delin",
		"tp_delout",
		"maxage",
		"vlanprio",
		"vlanid",
		"ing_mirr",
		"egr_mirr",
		"drpnona664",
		"drpdtag",
		"drpuntag",
		"retag",
		"dyn_learn",
		"egress",
		"ingress"
	};
	reg_type type[] = {0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	rc = sja1105_modify_reg("mac-configuration-table", new_node, type, options, len);
	if (rc < 0)
		return -1;

	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:schedule-parameters-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_schedule_parameters_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_schedule_parameters_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"subscheind"
	};
	reg_type type[] = {0, 1};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	if (op & XMLDIFF_ADD) {
		entry_count[SCHEDULE_PARAMETERS]++;
		sja1105_add_entry("schedule-parameters-table", entry_count[SCHEDULE_PARAMETERS]);
	}

	rc = sja1105_modify_reg("schedule-parameters-table", new_node, type, options, len);
	if (rc < 0)
		return -1;
	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:schedule-entry-points-parameters-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_schedule_entry_points_parameters_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_schedule_entry_points_parameters_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"clksrc",
		"actsubsch"
	};
	reg_type type[] = {0, 0, 0};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	if (op & XMLDIFF_ADD) {
		entry_count[SCHEDULE_ENTRY_POINTS_PARAMETERS]++;
		sja1105_add_entry("schedule-entry-points-parameters-table", entry_count[SCHEDULE_ENTRY_POINTS_PARAMETERS]);
	}

	rc = sja1105_modify_reg("schedule-entry-points-parameters-table", new_node, type, options, len);
	if (rc < 0)
		return -1;

	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:vl-forwarding-parameters-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_vl_forwarding_parameters_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_vl_forwarding_parameters_table_nxp_entry\n");
	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:l2-address-lookup-parameters-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_l2_address_lookup_parameters_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_l2_address_lookup_parameters_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"maxage",
		"dyn_tbsz",
		"poly",
		"shared_learn",
		"no_enf_hostprt",
		"no_mgmt_learn"
	};
	reg_type type[] = {0, 0, 0, 0, 0, 0, 0};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	rc = sja1105_modify_reg("l2-address-lookup-parameters-table", new_node, type, options, len);
	if (rc < 0)
		return -1;

	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:l2-forwarding-parameters-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_l2_forwarding_parameters_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_l2_forwarding_parameters_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"max_dynp",
		"part_spc"
	};
	reg_type type[] = {0, 0, 1};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	rc = sja1105_modify_reg("l2-forwarding-parameters-table", new_node, type, options, len);
	if (rc < 0)
		return -1;

	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:clock-synchronization-parameters-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_clock_synchronization_parameters_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_clock_synchronization_parameters_table_nxp_entry\n");
	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:avb-parameters-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_avb_parameters_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_avb_parameters_table_nxp_entry\n");
	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:general-parameters-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_general_parameters_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_general_parameters_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"vllupformat",
		"mirr_ptacu",
		"switchid",
		"hostprio",
		"mac_fltres1",
		"mac_fltres0",
		"mac_flt1",
		"mac_flt0",
		"incl_srcpt1",
		"incl_srcpt0",
		"send_meta1",
		"send_meta0",
		"casc_port",
		"host_port",
		"mirr_port",
		"vimarker",
		"vimask",
		"tpid",
		"ignore2stf",
		"tpid2"
	};
	reg_type type[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	rc = sja1105_modify_reg("general-parameters-table", new_node, type, options, len);
	if (rc < 0)
		return -1;

	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:retagging-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_retagging_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_retagging_table_nxp_entry\n");
	return EXIT_SUCCESS;
}

/**
 * @brief This callback will be run when node in path /nxp:sja1105/nxp:xmii-mode-parameters-table/nxp:entry changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node	Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node	New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105_nxp_xmii_mode_parameters_table_nxp_entry(void **data, XMLDIFF_OP op, xmlNodePtr old_node, xmlNodePtr new_node, struct nc_err **error) {
	nc_verb_verbose("callback_nxp_sja1105_nxp_xmii_mode_parameters_table_nxp_entry\n");
	int rc;
	char *options[] = {
		"index",
		"phy_mac",
		"xmii_mode"
	};
	reg_type type[] = {0, 1, 1};
	int len = sizeof(options)/sizeof(options[0]);

	if (op & XMLDIFF_REM) {
		return EXIT_SUCCESS;
	}

	rc = sja1105_modify_reg("xmii-mode-parameters-table", new_node, type, options, len);
	if (rc < 0)
		return -1;

	return EXIT_SUCCESS;
}

/*
 * Structure transapi_config_callbacks provide mapping between callback and path in configuration datastore.
 * It is used by libnetconf library to decide which callbacks will be run.
 * DO NOT alter this structure
 */
struct transapi_data_callbacks clbks =  {
	.callbacks_count = 20,
	.data = NULL,
	.callbacks = {
		{.path = "/nxp:sja1105/nxp:schedule-table/nxp:entry", .func = callback_nxp_sja1105_nxp_schedule_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:schedule-entry-points-table/nxp:entry", .func = callback_nxp_sja1105_nxp_schedule_entry_points_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:vl-lookup-table/nxp:entry", .func = callback_nxp_sja1105_nxp_vl_lookup_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:vl-policing-table/nxp:entry", .func = callback_nxp_sja1105_nxp_vl_policing_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:vl-forwarding-table/nxp:entry", .func = callback_nxp_sja1105_nxp_vl_forwarding_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:l2-address-lookup-table/nxp:entry", .func = callback_nxp_sja1105_nxp_l2_address_lookup_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:l2-policing-table/nxp:entry", .func = callback_nxp_sja1105_nxp_l2_policing_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:vlan-lookup-table/nxp:entry", .func = callback_nxp_sja1105_nxp_vlan_lookup_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:l2-forwarding-table/nxp:entry", .func = callback_nxp_sja1105_nxp_l2_forwarding_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:mac-configuration-table/nxp:entry", .func = callback_nxp_sja1105_nxp_mac_configuration_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:schedule-parameters-table/nxp:entry", .func = callback_nxp_sja1105_nxp_schedule_parameters_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:schedule-entry-points-parameters-table/nxp:entry", .func = callback_nxp_sja1105_nxp_schedule_entry_points_parameters_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:vl-forwarding-parameters-table/nxp:entry", .func = callback_nxp_sja1105_nxp_vl_forwarding_parameters_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:l2-address-lookup-parameters-table/nxp:entry", .func = callback_nxp_sja1105_nxp_l2_address_lookup_parameters_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:l2-forwarding-parameters-table/nxp:entry", .func = callback_nxp_sja1105_nxp_l2_forwarding_parameters_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:clock-synchronization-parameters-table/nxp:entry", .func = callback_nxp_sja1105_nxp_clock_synchronization_parameters_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:avb-parameters-table/nxp:entry", .func = callback_nxp_sja1105_nxp_avb_parameters_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:general-parameters-table/nxp:entry", .func = callback_nxp_sja1105_nxp_general_parameters_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:retagging-table/nxp:entry", .func = callback_nxp_sja1105_nxp_retagging_table_nxp_entry},
		{.path = "/nxp:sja1105/nxp:xmii-mode-parameters-table/nxp:entry", .func = callback_nxp_sja1105_nxp_xmii_mode_parameters_table_nxp_entry}
	}
};

/**
 * @brief Get a node from the RPC input. The first found node is returned, so if traversing lists,
 * call repeatedly with result->next as the node argument.
 *
 * @param name	Name of the node to be retrieved.
 * @param node	List of nodes that will be searched.
 * @return Pointer to the matching node or NULL
 */
xmlNodePtr get_rpc_node(const char *name, const xmlNodePtr node) {
	xmlNodePtr ret = NULL;

	for (ret = node; ret != NULL; ret = ret->next) {
		if (xmlStrEqual(BAD_CAST name, ret->name)) {
			break;
		}
	}

	return ret;
}

/*
 * RPC callbacks
 * Here follows set of callback functions run every time RPC specific for this device arrives.
 * You can safely modify the bodies of all function as well as add new functions for better lucidity of code.
 * Every function takes an libxml2 list of inputs as an argument.
 * If input was not set in RPC message argument is set to NULL. To retrieve each argument, preferably use get_rpc_node().
 */


xmlNodePtr probe_running_node(xmlNodePtr datastore_node)
{
	xmlNodePtr node = NULL;

	if (datastore_node->type != XML_ELEMENT_NODE) {
		fprintf(stderr, "Root node must be of element type!\n");
		goto out;
	}
	if (strcasecmp((char*) datastore_node->name, "datastores")) {
		fprintf(stderr, "Root node must be named \"datastores\"!\n");
		goto out;
	}
	for (node = datastore_node->children; node != NULL; node = node->next) {
		if (node->type != XML_ELEMENT_NODE) {
			continue;
		}
		if (strcmp((char*) datastore_node->name, "running")) {
			nc_verb_verbose("found the running node!\n");
			return node;
		}
	}

out:
	return NULL;
}

int file_validate(char *file)
{
	char newnodes_file[512];

	memset(newnodes_file, '\0', sizeof(newnodes_file) - 1);
	sprintf(newnodes_file, "%s/%s", conf_folder, file);
	if (access(newnodes_file, F_OK) == -1) {
		printf("config file not exist, newnodes_file= %s\n", newnodes_file);
		return -1;
	}

	return 0;
}

int file_check(char *file)
{
	char head[128], extend[128];

	sscanf(file, "%[^.].%s", head, extend);

	if (strcmp(extend, "xml"))
		return -1;

	return 0;
}

int write_to_datastore(char *file_name)
{
	char newnodes_file[512];
	int rc = 0;

	if(file_validate(file_name))
		return -1;
	
	if (pthread_mutex_trylock(&file_mutex) != 0) {
		/* file is still editing */
		return -1;
	}

	nc_verb_verbose("write_to_datastore:\n");
	memset(newnodes_file, '\0', sizeof(newnodes_file) - 1);
	sprintf(newnodes_file, "%s/%s", conf_folder, file_name);

	if (access(datastore_folder, F_OK) == -1) {
		printf("datastore.xml not exist\n");
		pthread_mutex_unlock(&file_mutex);
		return -1;
	}

	/* Init libxml */     
    xmlInitParser();

	xmlDocPtr doc_datastore = xmlReadFile(datastore_folder, NULL, 0);
	xmlDocPtr doc_newnodes = xmlReadFile(newnodes_file, NULL, 0);
	xmlNodePtr root_datastore = xmlDocGetRootElement(doc_datastore);
	xmlNodePtr root_newnodes = xmlDocGetRootElement(doc_newnodes);

	xmlNodePtr node = probe_running_node(root_datastore);
	if (node == NULL) {
		printf("Not found the running node\n");
		rc = -1;
		goto quiting;
	}

	if (strcasecmp((char*) root_newnodes->name, "sja1105")) {
		fprintf(stderr, "Root node must be named \"sja1105\"!\n");
		rc = -1;
		goto quiting;
	}

	xmlNodePtr rootnode = xmlCopyNodeList(root_newnodes);	
	/* start copy the node */
	xmlNodePtr new = xmlAddChild(node, rootnode);
	if (new == NULL) {
		printf("error adding the sja1105 node\n");
		goto quiting;
	}

	/* there is already running node */
	xmlNodePtr tempNode = new->prev;

	while (tempNode != NULL) {
		xmlNodePtr tempNode1;
		tempNode1 = tempNode;
		tempNode = tempNode->prev;
		xmlUnlinkNode(tempNode1);
		xmlFreeNode(tempNode1);
		nc_verb_verbose("delete previous sja1105 node\n");
	}

quiting:
	xmlSaveFile(datastore_folder, doc_datastore);

	xmlFreeDoc(doc_datastore);
	xmlFreeDoc(doc_newnodes);

	/* Shutdown libxml */
    xmlCleanupParser();
    
    /*
     * this is to debug memory for regression tests
     */
    xmlMemoryDump();
	pthread_mutex_unlock(&file_mutex);

	return rc;
}

int sja1105_check_dir(char *file)
{
	char dir_copy[128];

	memset(dir_copy, '\0', sizeof(dir_copy));
	if (file == NULL)
		return -1;

	if (strlen(file) < strlen(conf_folder))
		return -1;

	strncpy(dir_copy, file, strlen(conf_folder));

	if (strcmp(dir_copy, conf_folder))
		return -1;

	return 0;
}

int check_netconf_conf(char *file_dir)
{
	char a[128], b[128], xmlfile[128];
	char cmd_config_file[256];
	int ret;

	nc_verb_verbose("v2 in the check_netconf_conf, file = %s\n", file_dir);

	sscanf(file_dir, "/%[^/]/%[^/]/%s", a, b , xmlfile);

	nc_verb_verbose("a=%s, b= %s, c= %s\n", a, b, xmlfile);

	if(strcmp(a, "etc") || strcmp(b, "sja1105"))
		return -1;

	sprintf(cmd_config_file, "%s/%s", conf_folder, xmlfile);
	if (access(cmd_config_file, F_OK) == -1) {
		printf("netconf config file not exist, command file = %s\n", cmd_config_file);
		return -1;
	}

	ret = write_to_datastore(xmlfile);
	if (ret < 0)
		return -1;

	return 0;
}

int add_netconf_conf(char *file)
{
	char cmd_create_file[256];

	sprintf(cmd_create_file, "sja1105-netconf config save %s/%s", conf_folder, file);
	sja1105_run_cmd(cmd_create_file);

	return 0;	
}

nc_reply *rpc_sja1105_config_save(xmlNodePtr input) {

	nc_verb_verbose("rpc_sja1105_config_save\n");
	xmlNodePtr file_name_xml = get_rpc_node("file_name_xml", input);
	char *file_name;
	struct nc_err* e = NULL;
	char command_full[256];
	char cmd_file[256];
	int ret;
	char msg_err[256];

	file_name = (char*)xmlNodeGetContent(file_name_xml);

	sscanf(file_name, "%s", cmd_file);

	free(file_name);

	if (cmd_file[0] == '\"')
		strcpy(cmd_file, cmd_file + 1);
	if (cmd_file[strlen(cmd_file) - 1] == '\"')
		cmd_file[strlen(cmd_file) - 1] = '\0';

	ret = file_check(cmd_file);
	if (ret < 0) {
		memset(msg_err, '\0', sizeof(msg_err));
		strcpy(msg_err, "file validate failure, input a name with .xml extended!");
		goto error;
	}
	nc_verb_verbose("rpc_sja1105_config_save: preparing save file : %s\n", cmd_file);

	sprintf(command_full, "%s config save %s/%s", command_name, conf_folder, cmd_file);

	sja1105_run_cmd(command_full);

	nc_verb_verbose("run command --- %s\n", command_full);

	ret = add_netconf_conf(cmd_file);
	if (ret < 0) {
		memset(msg_err, '\0', sizeof(msg_err));
		strcpy(msg_err, "run netconf command failure");
		goto error;
	}

	return nc_reply_ok();

error:
	e = nc_err_new(NC_ERR_IN_USE);
	nc_err_set(e, NC_ERR_PARAM_MSG, msg_err);
	return nc_reply_error(e);
}

nc_reply *rpc_sja1105_config_load(xmlNodePtr input) {
	nc_verb_verbose("rpc_sja1105_config_load\n");
	xmlNodePtr file_name_xml = get_rpc_node("file_name_xml", input);
	char *file_name;
	struct nc_err* e = NULL;
	char command_full[256];
	char cmd_file[256];
	char folder[256];
	int ret;
	char msg_err[256];

	file_name = (char*)xmlNodeGetContent(file_name_xml);

	sscanf(file_name, "%s", cmd_file);

	free(file_name);

	if (cmd_file[0] == '\"')
		strcpy(cmd_file, cmd_file + 1);
	if (cmd_file[strlen(cmd_file) - 1] == '\"')
		cmd_file[strlen(cmd_file) - 1] = '\0';

	nc_verb_verbose("intend to load file %s\n", cmd_file);

	ret = file_validate(cmd_file);
	if (ret < 0) {
		memset(msg_err, '\0', sizeof(msg_err));
		strcpy(msg_err, "file validate failure, file not exist!");
		goto error;
	}

	nc_verb_verbose("rpc_sja1105_config_load: preparing load file : %s\n", cmd_file);

	sprintf(folder, "%s/%s", conf_folder, cmd_file);

	if (access(folder, F_OK) == -1) {
		printf("config file not exist, command file = %s\n", folder);
		memset(msg_err, '\0', sizeof(msg_err));
		strcpy(msg_err, "config file not exist in /etc/sja1105/");
		goto error;
	}

	sprintf(command_full, "%s config load %s/%s", command_name, conf_folder, cmd_file);

	sja1105_run_cmd(command_full);
	sja1105_run_cmd("sja1105-tool config upload");

	clear_entry_count();

	ret = write_to_datastore(cmd_file);
	if (ret < 0) {
		memset(msg_err, '\0', sizeof(msg_err));
		strcpy(msg_err, "run netconf xml file load failure");
		goto error;
	}

	return nc_reply_ok();

error:
	e = nc_err_new(NC_ERR_IN_USE);
	nc_err_set(e, NC_ERR_PARAM_MSG, msg_err);
	return nc_reply_error(e);
}

nc_reply *rpc_sja1105_config_default(xmlNodePtr input) {
	nc_verb_verbose("rpc_sja1105_config_default\n");
	char command_full[] = "sja1105-tool config default ls1021atsn";
	int ret;
	char msg_err[256];
	struct nc_err* e = NULL;

	sja1105_run_cmd(command_full);
	sja1105_run_cmd("sja1105-tool config upload");

	clear_entry_count();

	ret = write_to_datastore("standard.xml");
	if (ret < 0) {
		memset(msg_err, '\0', sizeof(msg_err));
		strcpy(msg_err, "run netconf xml file load failure");
		goto default_error;
	}

	return nc_reply_ok();

default_error:
	e = nc_err_new(NC_ERR_IN_USE);
	nc_err_set(e, NC_ERR_PARAM_MSG, msg_err);
	return nc_reply_error(e);
}

nc_reply *rpc_sja1105_upload(xmlNodePtr input) {
	nc_verb_verbose("rpc_sja1105_upload\n");
	char command_full[] = "sja1105-tool config upload";

	sja1105_run_cmd(command_full);

	return nc_reply_ok();
}
/*
 * Structure transapi_rpc_callbacks provides mapping between callbacks and RPC messages.
 * It is used by libnetconf library to decide which callbacks will be run when RPC arrives.
 * DO NOT alter this structure
 */
struct transapi_rpc_callbacks rpc_clbks = {
	.callbacks_count = 4,
	.callbacks = {
		{.name="sja1105_config_save", .func=rpc_sja1105_config_save},
		{.name="sja1105_config_load", .func=rpc_sja1105_config_load},
		{.name="sja1105_config_default", .func=rpc_sja1105_config_default},
		{.name="sja1105_upload", .func=rpc_sja1105_upload}
	}
};

/*
 * Structure transapi_file_callbacks provides mapping between specific files
 * (e.g. configuration file in /etc/) and the callback function executed when
 * the file is modified.
 * The structure is empty by default. Add items, as in example, as you need.
 *
 * Example:
 * int example_callback(const char *filepath, xmlDocPtr *edit_config, int *exec) {
 *     // do the job with changed file content
 *     // if needed, set edit_config parameter to the edit-config data to be applied
 *     // if needed, set exec to 1 to perform consequent transapi callbacks
 *     return 0;
 * }
 *
 * struct transapi_file_callbacks file_clbks = {
 *     .callbacks_count = 1,
 *     .callbacks = {
 *         {.path = "/etc/my_cfg_file", .func = example_callback}
 *     }
 * }
 */
struct transapi_file_callbacks file_clbks = {
	.callbacks_count = 0,
	.callbacks = {{NULL}}
};

