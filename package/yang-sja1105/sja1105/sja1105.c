/*
 * This is automatically generated callbacks file
 * It contains 3 parts: Configuration callbacks, RPC callbacks and state
 * data callbacks.
 * Do NOT alter function signatures or any structures unless you know exactly
 * what you are doing.
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
#define TOTAL_PORTS 5

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

const char *conf_folder = "/etc/sja1105";
const char *datastore_filename = "/usr/local/etc/netopeer/sja1105/datastore.xml";
const char *tempxml = "/var/lib/libnetconf/config.xml";
const char *syncxml = "/var/lib/libnetconf/sync.xml";

/* Signal to libnetconf that configuration data were modified by any callback.
 * 0 - data not modified
 * 1 - data have been modified
 */
int config_modified = 0;

pthread_mutex_t file_mutex;

const char netconf_file_dir[] = "/etc/sja1105/";


/*
 * Determines the callbacks order.
 * Set this variable before compilation and DO NOT modify it in runtime.
 * TRANSAPI_CLBCKS_LEAF_TO_ROOT (default)
 * TRANSAPI_CLBCKS_ROOT_TO_LEAF
 */
const TRANSAPI_CLBCKS_ORDER_TYPE callbacks_order = TRANSAPI_CLBCKS_ORDER_DEFAULT;

/* Do not modify or set! This variable is set by libnetconf to announce
 * edit-config's error-option. Feel free to use it to distinguish module
 * behavior for different error-option values.
 * Possible values:
 * NC_EDIT_ERROPT_STOP - Following callback after failure are not executed,
 *                       all successful callbacks executed till
                         failure point must be applied to the device.
 * NC_EDIT_ERROPT_CONT - Failed callbacks are skipped, but all callbacks
 *                       needed to apply configuration changes are executed
 * NC_EDIT_ERROPT_ROLLBACK - After failure, following callbacks are not executed,
 *                       but previous successful callbacks are executed again
 *                       with previous configuration data to roll it back.
 */
NC_EDIT_ERROPT_TYPE erropt = NC_EDIT_ERROPT_NOTSET;

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

void sja1105_log(NC_VERB_LEVEL level, const char* msg)
{
	switch (level) {
	case NC_VERB_ERROR:
		printf("[sja1105 error]: %s\n", msg);
		break;
	case NC_VERB_WARNING:
		printf("[sja1105 warning]: %s\n", msg);
		break;
	case NC_VERB_VERBOSE:
		printf("[sja1105 verbose]: %s\n", msg);
		break;
	case NC_VERB_DEBUG:
		printf("[sja1105 debug]: %s\n", msg);
		break;
	}
}

/**
 * @brief Initialize plugin after loaded and before any other functions
 *        are called.

 * This function should not apply any configuration data to the controlled
 * device. If no running is returned (it stays *NULL), complete startup
 * configuration is consequently applied via module callbacks. When a running
 * configuration is returned, libnetconf then applies (via module's callbacks)
 * only the startup configuration data that differ from the returned running
 * configuration data.

 * Please note, that copying startup data to the running is performed only
 * after the libnetconf's system-wide close - see nc_close() function
 * documentation for more information.

 * @param[out] running  Current configuration of managed device.

 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
int transapi_init(__attribute__((unused)) xmlDocPtr *running)
{
	/* set message printing callback */
	nc_callback_print(sja1105_log);
	/* test it out */
	nc_verb_verbose("transapi_init");
	return EXIT_SUCCESS;
}

/**
 * @brief Free all resources allocated on plugin runtime and prepare
 *        plugin for removal.
 */
void transapi_close(void)
{
	pthread_mutex_destroy(&file_mutex);
	return;
}

int xml_save_to_file(xmlNodePtr root, const char *filename)
{
	char command[256];
	xmlDocPtr xml_doc = xmlNewDoc(BAD_CAST "1.0");

	xmlDocSetRootElement(xml_doc, root);
	xmlSaveFormatFileEnc(filename, xml_doc, "UTF-8", 1);
	xmlFreeDoc(xml_doc);
	xmlCleanupParser();

	memset(command, 0, sizeof(command));
	sprintf(command, "sed -i '/wd:default/d' %s", filename);
	sja1105_run_cmd(command);

	memset(command, 0, sizeof(command));
	sprintf(command, "sed -i '/version/d' %s", filename);
	sja1105_run_cmd(command);
	return 0;
}

/**
 * @brief               Retrieve state data from device and return them
 *                      as XML document
 *
 * @param model         Device data model. libxml2 xmlDocPtr.
 * @param running       Running datastore content. libxml2 xmlDocPtr.
 * @param[out] err      Double pointer to error structure.
 *                      Fill error when some occurs.
 * @return              State data as libxml2 xmlDocPtr or NULL in case
 *                      of error.
 */
xmlDocPtr get_state_data(__attribute__((unused)) xmlDocPtr model,
                         __attribute__((unused)) xmlDocPtr running,
                         __attribute__((unused)) struct nc_err **err)
{
	nc_verb_verbose("get_state_data\n");
	FILE *fp;
	char cmd_xml_list[256];
	char command_line[256];
	xmlDocPtr doc = NULL;
	xmlNodePtr root;
	xmlNsPtr ns;
	int i;

	doc = xmlNewDoc(BAD_CAST "1.0");
	xmlDocSetRootElement(doc, root = xmlNewDocNode(doc, NULL, BAD_CAST
	                                               "sja1105", NULL));
	ns = xmlNewNs(root, BAD_CAST SJA1105_NETCONF_NS, NULL);
	xmlSetNs(root, ns);

	xmlNodePtr node = xmlNewNode(NULL, BAD_CAST "config-files");
	xmlAddChild(root, node);

	sprintf(command_line, "ls -l %s/* | grep .xml | awk '{print $9}'",
	        netconf_file_dir);
	if ((fp = popen(command_line, "r")) == NULL) {
		nc_verb_error("command fail: ls -l %s/*", netconf_file_dir);
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

	xmlNodePtr node_ports = xmlNewNode(NULL, BAD_CAST "ports");
	xmlAddChild(root, node_ports);

	for (i = 0; i < TOTAL_PORTS; i++)
	{
		char lbuf[256];
		char full_status[4096];
		int len = 0;

		memset(full_status, 0, sizeof(full_status));
		memset(command_line, 0, sizeof(command_line));
		sprintf(command_line, "sja1105-tool status ports %d", i);

		if ((fp = popen(command_line, "r")) == NULL) {
			nc_verb_error("command \"sja1105-tool status ports %d\""
			              "failed", i);
			return(NULL);
		}
		while (fgets(lbuf, 256, fp) != NULL) {
			int llen;

			llen = strlen(lbuf);
			strncpy(full_status + len, lbuf, llen);
			len += llen;
			full_status[len++] = '\t';
		}
		xmlNewChild(node_ports, root->ns, BAD_CAST "port", BAD_CAST full_status);
	}
	return(doc);
}

/*
 * Mapping prefixes with namespaces.
 * Do NOT modify this structure!
 */
struct ns_pair namespace_mapping[] = {{"nxp", SJA1105_NETCONF_NS}, {NULL, NULL}};

/*
 * CONFIGURATION callbacks
 * Here follows set of callback functions run every time some change in
 * associated part of running datastore occurs.
 * You can safely modify the bodies of all function as well as add new
 * functions for better lucidity of code.
 */

/**
 * @brief This callback will be run when node in path /nxp:sja1105 changes
 *
 * @param[in] data      Double pointer to void. Its passed to every callback.
 *                      You can share data using it.
 * @param[in] op        Observed change in path. XMLDIFF_OP type.
 * @param[in] old_node  Old configuration node. If op == XMLDIFF_ADD, it is NULL.
 * @param[in] new_node  New configuration node. if op == XMLDIFF_REM, it is NULL.
 * @param[out] error    If callback fails, it can return libnetconf error
 *                      structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
/* !DO NOT ALTER FUNCTION SIGNATURE! */
int callback_nxp_sja1105(__attribute__((unused)) void **data,
                         XMLDIFF_OP op,
                         __attribute__((unused)) xmlNodePtr old_node,
                         xmlNodePtr new_node,
                         __attribute__((unused)) struct nc_err **error)
{
	char command[256];
	int rc;

	nc_verb_verbose("callback_nxp_sja1105\n");

	if (op & XMLDIFF_REM) {
		nc_verb_verbose("callback_nxp_sja1105 op is REMOVE\n");
		config_modified = 0;
		return EXIT_SUCCESS;
	}

	if (((op & XMLDIFF_ADD) || (op & XMLDIFF_MOD)) && (new_node != NULL)) {
		/* new_node is the root of an XML configuration that we will
		 * save to a temporary file and pass directly to sja1105-tool
		 * for it to load */
		rc = xml_save_to_file(new_node, tempxml);
		if (rc < 0)
			return -1;

		sprintf(command, "sja1105-tool config load -f %s", tempxml);
		sja1105_run_cmd(command);
		config_modified = 1;
	} else {
		nc_verb_verbose("unknown operation type\n");
		config_modified = 0;
	}
	return EXIT_SUCCESS;
}

/*
 * Structure transapi_config_callbacks provide mapping between callback and
 * path in configuration datastore.
 * It is used by libnetconf library to decide which callbacks will be run.
 * DO NOT alter this structure
 */
struct transapi_data_callbacks clbks =  {
	.callbacks_count = 1,
	.data = NULL,
	.callbacks = {
		{.path = "/nxp:sja1105", .func = callback_nxp_sja1105},
	}
};

/**
 * @brief Get a node from the RPC input. The first found node is returned,
 * so if traversing lists, call repeatedly with result->next as
 * the node argument.
 *
 * @param name	Name of the node to be retrieved.
 * @param node	List of nodes that will be searched.
 * @return Pointer to the matching node or NULL
 */
xmlNodePtr get_rpc_node(const char *name, const xmlNodePtr node)
{
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
 * Here follows set of callback functions run every time RPC specific for this
 * device arrives.
 * You can safely modify the bodies of all function as well as add new
 * functions for better lucidity of code.
 * Every function takes an libxml2 list of inputs as an argument.
 * If input was not set in RPC message argument is set to NULL.
 * To retrieve each argument, preferably use get_rpc_node().
 */

xmlNodePtr probe_datastore_node(xmlNodePtr datastore_node, char *node_name)
{
	xmlNodePtr node = NULL;

	if (datastore_node->type != XML_ELEMENT_NODE) {
		nc_verb_error("Root node must be of element type!");
		goto out;
	}
	if (strcasecmp((char*) datastore_node->name, "datastores")) {
		nc_verb_error("Root node must be named \"datastores\"!");
		goto out;
	}
	for (node = datastore_node->children; node != NULL; node = node->next) {
		if (!strcmp((char*)node->name, node_name)) {
			nc_verb_verbose("found the %s node!\n", node_name);
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
	sprintf(newnodes_file, "%s", file);
	if (access(newnodes_file, F_OK) == -1) {
		nc_verb_error("config file not exist, newnodes_file= %s",
		              newnodes_file);
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

	nc_verb_verbose("write_to_datastore:");
	memset(newnodes_file, '\0', sizeof(newnodes_file) - 1);
	sprintf(newnodes_file, "%s", file_name);

	if (access(datastore_filename, F_OK) == -1) {
		nc_verb_error("datastore %s does not exist", datastore_filename);
		pthread_mutex_unlock(&file_mutex);
		return -1;
	}

	/* Init libxml */
	xmlInitParser();

	xmlDocPtr doc_datastore = xmlReadFile(datastore_filename, NULL, 0);
	xmlDocPtr doc_newnodes = xmlReadFile(newnodes_file, NULL, 0);
	xmlNodePtr root_datastore = xmlDocGetRootElement(doc_datastore);
	xmlNodePtr root_newnodes = xmlDocGetRootElement(doc_newnodes);

	xmlNodePtr node_running = probe_datastore_node(root_datastore, "running");
	if (node_running == NULL) {
		nc_verb_error("Running config datastore node not found");
		rc = -1;
		goto quiting;
	}

	xmlNodePtr node_candidate = probe_datastore_node(root_datastore, "candidate");
	if (node_candidate == NULL) {
		nc_verb_error("Candidate config datastore node not found");
		rc = -1;
		goto quiting;
	}

	if (strcasecmp((char*) root_newnodes->name, "sja1105")) {
		nc_verb_error("Root node must be named \"sja1105\"!");
		rc = -1;
		goto quiting;
	}

	/* add new sja1105 node to running node in datastore.xml */
	xmlNodePtr rootnode_running = xmlCopyNodeList(root_newnodes);

	/* start copy the node */
	xmlNodePtr new_run = xmlAddChild(node_running, rootnode_running);
	if (new_run == NULL) {
		nc_verb_error("error adding the sja1105 node");
		goto quiting;
	}

	/* there is already running node */
	xmlNodePtr tempNode = new_run->prev;

	while (tempNode != NULL) {
		xmlNodePtr tempNode1;
		tempNode1 = tempNode;
		tempNode = tempNode->prev;
		xmlUnlinkNode(tempNode1);
		xmlFreeNode(tempNode1);
		nc_verb_verbose("delete previous sja1105 running node");
	}

	/* Add new sja1105 node to candidate node in datastore.xml */
	xmlNodePtr rootnode_candidate = xmlCopyNodeList(root_newnodes);

	xmlSetProp(node_candidate, (const xmlChar *)"modified", (const xmlChar *)"true");

	/* start copy the node */
	xmlNodePtr new_candi = xmlAddChild(node_candidate, rootnode_candidate);
	if (new_candi == NULL) {
		nc_verb_error("error adding the sja1105 node");
		goto quiting;
	}

	/* there is already running node */
	tempNode = new_candi->prev;

	while (tempNode != NULL) {
		xmlNodePtr tempNode1;
		tempNode1 = tempNode;
		tempNode = tempNode->prev;
		xmlUnlinkNode(tempNode1);
		xmlFreeNode(tempNode1);
		nc_verb_verbose("delete previous sja1105 candidate node\n");
	}

	xmlSetProp(node_candidate, (const xmlChar *)"modified", (const xmlChar *)"false");

quiting:
	xmlSaveFile(datastore_filename, doc_datastore);

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

nc_reply *rpc_save_local_config(xmlNodePtr input)
{
	xmlNodePtr file_name_xml = get_rpc_node("configfile", input);
	char *file_name;
	struct nc_err* e = NULL;
	char command_full[256];
	char cmd_file[256];
	int ret;
	char msg_err[256];

	nc_verb_verbose("rpc_sja1105_config_save");

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
		strcpy(msg_err, "file validate failure, input a name with .xml extension!");
		goto error;
	}
	nc_verb_verbose("rpc_sja1105_config_save: preparing save file : %s\n",
	                cmd_file);

	sprintf(command_full, "sja1105-tool config save %s/%s",
	        conf_folder, cmd_file);

	sja1105_run_cmd(command_full);

	nc_verb_verbose("run command --- %s", command_full);

	return nc_reply_ok();
error:
	e = nc_err_new(NC_ERR_IN_USE);
	nc_err_set(e, NC_ERR_PARAM_MSG, msg_err);
	return nc_reply_error(e);
}

nc_reply *rpc_load_local_config(xmlNodePtr input)
{
	xmlNodePtr file_name_xml = get_rpc_node("configfile", input);
	char *file_name;
	struct nc_err* e = NULL;
	char command_full[256];
	char cmd_file[256];
	char folder[256];
	int ret;
	char msg_err[256];

	nc_verb_verbose("rpc_sja1105_config_load");

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

	nc_verb_verbose("rpc_sja1105_config_load: preparing load file: %s\n",
	                cmd_file);

	sprintf(folder, "%s/%s", conf_folder, cmd_file);

	if (access(folder, F_OK) == -1) {
		nc_verb_error("config file does not exist, command file = %s",
		              folder);
		memset(msg_err, '\0', sizeof(msg_err));
		strcpy(msg_err, "config file not exist in /etc/sja1105/");
		goto error;
	}

	sprintf(command_full, "sja1105-tool config load -f %s/%s",
	        conf_folder, cmd_file);

	sja1105_run_cmd(command_full);

	ret = write_to_datastore(folder);
	if (ret < 0) {
		memset(msg_err, '\0', sizeof(msg_err));
		strcpy(msg_err, "run netconf xml file load failure");
		goto error;
	}
	config_modified = 1;

	return nc_reply_ok();
error:
	e = nc_err_new(NC_ERR_IN_USE);
	nc_err_set(e, NC_ERR_PARAM_MSG, msg_err);
	return nc_reply_error(e);
}

nc_reply *rpc_load_default(__attribute__((unused)) xmlNodePtr input)
{
	nc_verb_verbose("rpc_sja1105_config_default\n");
	char command_full[] = "sja1105-tool config default -f ls1021atsn";
	int ret;
	char msg_err[256];
	char folder[256];
	struct nc_err* e = NULL;

	sja1105_run_cmd(command_full);

	sprintf(folder, "%s/standard.xml", conf_folder);

	ret = write_to_datastore(folder);
	if (ret < 0) {
		memset(msg_err, '\0', sizeof(msg_err));
		strcpy(msg_err, "run netconf xml file load failure");
		goto default_error;
	}
	config_modified = 1;

	return nc_reply_ok();

default_error:
	e = nc_err_new(NC_ERR_IN_USE);
	nc_err_set(e, NC_ERR_PARAM_MSG, msg_err);
	return nc_reply_error(e);
}

/*
 * Structure transapi_rpc_callbacks provides mapping between callbacks and RPC messages.
 * It is used by libnetconf library to decide which callbacks will be run when RPC arrives.
 * DO NOT alter this structure
 */
struct transapi_rpc_callbacks rpc_clbks = {
	.callbacks_count = 3,
	.callbacks = {
		{.name="save-local-config", .func=rpc_save_local_config},
		{.name="load-local-config", .func=rpc_load_local_config},
		{.name="load-default", .func=rpc_load_default}
	}
};

int staging_area_callback(const char *filepath,
                          __attribute__((unused)) xmlDocPtr *edit_config,
                          __attribute__((unused)) int *exec)
{
	char command_full[256];
	char folder[256];

	memset(command_full, 0, sizeof(command_full));
	memset(folder, 0, sizeof(folder));
	nc_verb_verbose("staging_area_callback: %s", filepath);
	/*
	 * 1. Check if the staging area was modified by previously
	 *    calling one of these functions:
	 *      * rpc_load_default()
	 *      * rpc_load_local_config()
	 *      * callback_nxp_sja1105() with (op & XMLDIFF_ADD) || (op & XMLDIFF_MOD)
	 *    Do the check by setting a global flag in those functions and
	 *    clearing it here.
	 *    If the flag was already clear by the time staging_area_callback()
	 *    is called, it means the staging area was modified externally
	 *    (most probably sja1105-tool).
	 * 2. Invoke a "sja1105-tool config save *tempxml" to extract the
	 *    new staging area contents into a temporary XML file
	 * 3. Run "write_to_datastore(tempxml)" or similar, to import the newly
	 *    extracted configuration from the modified staging area into
	 *    the NETCONF datastore.
	 */

	if (config_modified) {
		/* netopeer callbacks modified the staging area */
		config_modified = 0;
		return 0;
	}

	nc_verb_verbose("staging_area_callback: detected external modification. syncing up the datastore with the new config\n");

	sprintf(command_full, "sja1105-tool config save %s", syncxml);

	sja1105_run_cmd(command_full);

	strcpy(folder, syncxml);

	write_to_datastore(folder);

	config_modified = 0;

	return 0;
}

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
	.callbacks_count = 1,
	.callbacks = {{.path = "/lib/firmware/sja1105.bin",
	               .func = staging_area_callback}}
};

