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
#include <sja1105/errors.h>

#define SJA1105_NETCONF_NS "http://nxp.com/ns/yang/tsn/sja1105"
#define TOTAL_PORTS 5

/* transAPI version which must be compatible with libnetconf */
int transapi_version = 6;

/* The user needs to make sure that the STAGING_AREA definition in here
 * is in sync with the "staging_area" from sja1105-tool.conf.
 */
#define CONF_FOLDER        "/etc/sja1105"
#define DATASTORE_FILENAME "/usr/local/etc/netopeer/sja1105/datastore.xml"
#define TEMPXML            "/var/lib/libnetconf/config.xml"
#define STAGING_AREA       "/lib/firmware/sja1105.bin"
#define SJA1105_TOOL_CONF  "/usr/local/etc/netopeer/sja1105/sja1105-tool.conf"

/* Signal to libnetconf that configuration data were modified by any callback.
 * 0 - data not modified
 * 1 - data has been modified
 */
int config_modified = 0;
int staging_area_modified = 0;
int last_datastore_works = 0;

/* Avoid performing concurrent modifications on the datastore in
 * modify_datastore_externally_from_sja1105_xml().
 * TODO: Not enough?! The mutex should also protect
 * from libnetconf access to it.
 */
pthread_mutex_t datastore_mutex;
/* Make the staging_area_callback() wait until
 * sja1105_tool_subprocess() completes.
 */
pthread_mutex_t staging_area_mutex;

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

int subprocess(const char *cmdline,
               void (*output_line_callback)(char *line, void *priv),
               void *priv)
{
	char  line[BUFSIZ];
	FILE *fp;
	int   rc;

	fp = popen(cmdline, "r");

	if (output_line_callback) {
		while (fgets(line, BUFSIZ, fp) != NULL) {
			/* Massage the line a little bit before handing
			 * it out to the callback */
			rc = strlen(line) - 1;
			if (line[rc] == '\n') {
				line[rc] = '\0';
			}
			output_line_callback(line, priv);
		}
	}
	rc = WEXITSTATUS(pclose(fp));
	nc_verb_verbose("%s: \"%s\" returned code %d", __func__, cmdline, rc);
	return rc;
}

void sja1105_tool_output_callback(char *line, __attribute__((unused)) void *priv)
{
	printf("[sja1105-tool]: \"%s\"\n", line);
}

int sja1105_tool_subprocess(const char *object, const char *verb, const char *args)
{
	char cmdline[BUFSIZ];
	int  command_is_susceptible_of_modifying_staging_area;
	int  rc;

	command_is_susceptible_of_modifying_staging_area =
		(strcmp(object, "config") == 0) &&
		((strncmp(verb, "load", strlen("load")) == 0) ||
		 (strncmp(verb, "new", strlen("new")) == 0) ||
		 (strncmp(verb, "modify", strlen("modify")) == 0) ||
		 (strncmp(verb, "default", strlen("default")) == 0));

	if (command_is_susceptible_of_modifying_staging_area) {
		/* Take the mutex before the subprocess call.
		 * Otherwise don't - the staging_area_callback also
		 * invokes sja1105_tool_subprocess, but with "save"
		 * - this doesn't modify the staging area but just
		 * exports it to XML.
		 * Without this condition, the code will result in a
		 * deadlock, because staging_area_callback already has
		 * the lock held.
		 */
		nc_verb_verbose("%s: staging_area_mutex try lock", __func__);
		pthread_mutex_lock(&staging_area_mutex);
		nc_verb_verbose("%s: staging_area_mutex took lock", __func__);
	}

	snprintf(cmdline, BUFSIZ,
	         "sja1105-tool -c " SJA1105_TOOL_CONF " %s %s %s",
	         object, verb, args);
	rc = subprocess(cmdline, sja1105_tool_output_callback, NULL);

	/* Let staging_area_callback know it's us - it'll call. */
	if (command_is_susceptible_of_modifying_staging_area) {
		staging_area_modified = (rc == SJA1105_ERR_OK ||
		                         rc == SJA1105_ERR_HW_NOT_RESPONDING_STAGING_AREA_DIRTY ||
		                         rc == SJA1105_ERR_UPLOAD_FAILED_HW_LEFT_FLOATING_STAGING_AREA_DIRTY);
		nc_verb_verbose("%s: staging_area_modified %d",
		                __func__, staging_area_modified);
		pthread_mutex_unlock(&staging_area_mutex);
		nc_verb_verbose("%s: staging_area_mutex unlock", __func__);
	}
	return rc;
}

void sja1105_log(NC_VERB_LEVEL level, const char* msg)
{
	switch (level) {
	case NC_VERB_ERROR:
		printf("[sja1105   error]: %s\n", msg);
		break;
	case NC_VERB_WARNING:
		printf("[sja1105 warning]: %s\n", msg);
		break;
	case NC_VERB_VERBOSE:
		printf("[sja1105 verbose]: %s\n", msg);
		break;
	case NC_VERB_DEBUG:
		printf("[sja1105   debug]: %s\n", msg);
		break;
	}
}

static int sja1105_tool_apply_from_datastore(xmlNodePtr datastore_node)
{
	xmlDocPtr xml_doc;
	char cmdline[BUFSIZ];
	int rc;

	/* Create an xml doc from the datastore node
	 * and save it to TEMPXML
	 */
	xml_doc = xmlNewDoc(BAD_CAST "1.0");
	xmlDocSetRootElement(xml_doc, xmlCopyNodeList(datastore_node));
	xmlSaveFormatFileEnc(TEMPXML, xml_doc, "UTF-8", 1);
	xmlFreeDoc(xml_doc);
	/* XXX: Fixup some elements from the datastore nodes
	 * that sja1105-tool just doesn't understand.
	 */
	snprintf(cmdline, BUFSIZ,
	         "sed -i -e '/wd:default/d' -e '/version/d' %s",
	         TEMPXML);
	rc = subprocess(cmdline, NULL, NULL);
	if (rc != EXIT_SUCCESS) {
		nc_verb_error("sed subprocess failed");
		rc = EXIT_FAILURE;
		goto out;
	}
	/* Load the newly created and fixed-up TEMPXML into the
	 * sja1105-tool staging area, and into the hardware (-f)
	 */
	rc = sja1105_tool_subprocess("config", "load -f", TEMPXML);
	if (rc != SJA1105_ERR_OK) {
		nc_verb_error("sja1105_tool_subprocess failed");
		rc = EXIT_FAILURE;
		goto out;
	}
out:
	return rc;
}

static int populate_datastore_from_sja1105_xml(xmlNodePtr datastore_node,
                                               const char *sja1105_xml)
{
	int rc = EXIT_SUCCESS;

	/* Get a pointer to the sja1105-tool xml in root_sja1105_tool */
	xmlDocPtr  doc_sja1105_tool  = xmlReadFile(sja1105_xml, NULL, 0);
	xmlNodePtr root_sja1105_tool = xmlDocGetRootElement(doc_sja1105_tool);
	xmlNodePtr cur;

	if (strcasecmp((const char*) root_sja1105_tool->name, "sja1105")) {
		nc_verb_error("Root node must be named \"sja1105\"!");
		rc = EXIT_FAILURE;
		goto out;
	}

	/* Remove existing candidate/running subtree from
	 * the datastore, if it exists (since we are replacing
	 * it with a new subtree).
	 */
	for (cur = datastore_node->children; cur != NULL; cur = cur->next) {
		xmlUnlinkNode(cur);
		xmlFreeNodeList(cur);
	}

	/* add new sja1105 node to datastore_node */
	xmlNodePtr new_config = xmlCopyNodeList(root_sja1105_tool);
	xmlNodePtr result = xmlAddChild(datastore_node, new_config);
	if (result == NULL) {
		nc_verb_error("error adding the sja1105 node");
		rc = EXIT_FAILURE;
		goto out;
	}
out:
	xmlFreeDoc(doc_sja1105_tool);
	return rc;
}

xmlNodePtr probe_datastore_node(xmlNodePtr datastore_node, const char *node_name)
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
			nc_verb_verbose("found the %s node!", node_name);
			return node;
		}
	}
out:
	return NULL;
}

/*
 * libnetconf/transapi.h says about struct transapi_file_callbacks:
 *
 *       xmlDocPtr *edit_config[out] - (...) The data are supposed
 *       to be enclosed in \<config/\> root element.
 *
 * That's what we do here.
 */
static int config_doc_from_staging_area(xmlDocPtr *doc_datastore)
{
	int rc = EXIT_SUCCESS;
	xmlNodePtr root;
	xmlNsPtr ns;

	/* Create the datastore skeleton */
	*doc_datastore = xmlNewDoc(BAD_CAST "1.0");
	root = xmlNewNode(NULL, BAD_CAST "config");
	xmlDocSetRootElement(*doc_datastore, root);
	ns = xmlNewNs(root, BAD_CAST "urn:cesnet:tmc:datastores:file", NULL);
	xmlSetNs(root, ns);

	/* Turn the staging area into a temporary XML */
	rc = sja1105_tool_subprocess("config", "save", TEMPXML);
	if (rc != SJA1105_ERR_OK) {
		nc_verb_error("subprocess failed");
		goto out;
	}
	/* Copy the temporary xml to the datastore running config */
	rc = populate_datastore_from_sja1105_xml(root, TEMPXML);
	if (rc != EXIT_SUCCESS) {
		nc_verb_error("populate_datastore_from_sja1105_xml failed");
		goto out;
	}
out:
	return rc;
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
	/* Init libxml */
	xmlInitParser();
	/* Init pthread mutex on datastore */
	pthread_mutex_init(&datastore_mutex, NULL);
	pthread_mutex_init(&staging_area_mutex, NULL);

	/* TODO: Attempt to load the staging area (if one exists)
	 * into the initial running config (*running_node).
	 * Do not fail if we can't (it may simply not exist).
	 *
	 * Code currently commented out because the netopeer server
	 * doesn't seem to want to read the XML document in *running
	 * properly (perhaps the format is wrong?).
	 */
#if 0
	int rc;

	/* Turn the staging area into a temporary XML */
	rc = sja1105_tool_subprocess("config", "save", TEMPXML);
	if (rc != SJA1105_ERR_OK) {
		nc_verb_error("subprocess failed");
		goto out;
	}
	*running = xmlReadFile(TEMPXML, NULL, 0);
out:
#endif
	return EXIT_SUCCESS;
}

/**
 * @brief Free all resources allocated on plugin runtime and prepare
 *        plugin for removal.
 */
void transapi_close(void)
{
	xmlCleanupParser();
	pthread_mutex_destroy(&datastore_mutex);
	pthread_mutex_destroy(&staging_area_mutex);
	return;
}

enum port_counter_type {
	SJA1105_PORT_MAC_DIAGNOSTICS_COUNTER = 0,
	SJA1105_PORT_MAC_DIAGNOSTICS_FLAG,
	SJA1105_PORT_HIGH_LEVEL_COUNTER,
	SJA1105_PORT_INVALID_COUNTER,
};

struct sja1105_tool_status_ports_output_priv {
	enum port_counter_type last_seen_type;
	xmlNodePtr port_node;
	xmlNodePtr port_counters_node;
};

void sja1105_tool_status_ports_output_callback(char *line, void *priv_ptr)
{
	struct sja1105_tool_status_ports_output_priv *priv =
	                (struct sja1105_tool_status_ports_output_priv*) priv_ptr;
	const char *port_counter_name;
	const char *port_counter_value;
	const char *port_index;
	char *saveptr;

	if (strstr(line, "Port ") != NULL) {
		port_index = strtok_r(line, " ", &saveptr);
		/* Discard first word, which we know is "Port" */
		port_index = strtok_r(NULL, " ", &saveptr);
		xmlNewChild(priv->port_node,
		            /* namespace */ NULL,
		            BAD_CAST "index",
		            BAD_CAST port_index);
	} else if (strstr(line, "MAC-Level Diagnostic Counters") != NULL) {
		priv->last_seen_type = SJA1105_PORT_MAC_DIAGNOSTICS_COUNTER;
		priv->port_counters_node =
		      xmlNewChild(priv->port_node,
		                  /* namespace */ NULL,
		                  BAD_CAST "mac-level-diagnostic-counters",
		                  /* content */ NULL);
	} else if (strstr(line, "MAC-Level Diagnostic Flags") != NULL) {
		priv->last_seen_type = SJA1105_PORT_MAC_DIAGNOSTICS_FLAG;
		priv->port_counters_node =
		      xmlNewChild(priv->port_node,
		                  /* namespace */ NULL,
		                  BAD_CAST "mac-level-diagnostic-flags",
		                  /* content */ NULL);
	} else if (strstr(line, "High-Level Diagnostic Counters") != NULL) {
		priv->last_seen_type = SJA1105_PORT_HIGH_LEVEL_COUNTER;
		priv->port_counters_node =
		      xmlNewChild(priv->port_node,
		                  /* namespace */ NULL,
		                  BAD_CAST "high-level-diagnostic-counters",
		                  /* content */ NULL);
	} else {
		if (priv->last_seen_type == SJA1105_PORT_INVALID_COUNTER) {
			/* Most probably junk */
			return;
		}
		port_counter_name = strtok_r(line, " ", &saveptr);
		if (port_counter_name == NULL) {
			/* Most probably an empty line */
			return;
		};
		port_counter_value = strtok_r(NULL, " ", &saveptr);
		if (port_counter_value == NULL) {
			nc_verb_error("%s: discarding line with single word: \"%s\"",
			              __func__, port_counter_name);
			return;
		}
		/* Finally, a regular line such as
		 * "N_TXFRM         0"
		 */
		xmlNewChild(priv->port_counters_node,
		            /* namespace */ NULL,
		            BAD_CAST port_counter_name,
		            BAD_CAST port_counter_value);
	}
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
                         struct nc_err **error)
{
	struct sja1105_tool_status_ports_output_priv priv;
	char cmdline[BUFSIZ];
	xmlDocPtr doc = NULL;
	xmlNodePtr root;
	xmlNsPtr ns;
	int rc;
	int i;

	doc = xmlNewDoc(BAD_CAST "1.0");
	root = xmlNewDocNode(doc, NULL, BAD_CAST "sja1105", NULL);
	xmlDocSetRootElement(doc, root);
	ns = xmlNewNs(root, BAD_CAST SJA1105_NETCONF_NS, NULL);
	xmlSetNs(root, ns);

	xmlNodePtr node_port_status = xmlNewChild(root,
	                                          /* namespace */ NULL,
	                                          BAD_CAST "port-status",
	                                          /* content */ NULL);

	for (i = 0; i < TOTAL_PORTS; i++) {
		/* Prepare the private structure for the line callback function
		 * that will scrape the output of "sja1105 status port $i".
		 * That function will also populate the xml document subtree
		 * under priv.port_node.
		 */
		priv.last_seen_type = SJA1105_PORT_INVALID_COUNTER;
		priv.port_counters_node = NULL;
		priv.port_node = xmlNewChild(node_port_status,
		                             /* namespace */ NULL,
		                             BAD_CAST "port",
		                             /* content */ NULL);

		snprintf(cmdline, BUFSIZ, "sja1105-tool status port %d", i);
		rc = subprocess(cmdline, sja1105_tool_status_ports_output_callback, &priv);
		if (rc != EXIT_SUCCESS) {
			nc_verb_error("subprocess returned code %d", rc);
			*error = nc_err_new(NC_ERR_OP_FAILED);
			nc_err_set(*error, NC_ERR_PARAM_MSG,
			           "Failed to get output from sja1105-tool.");
			goto out;
		}
	}
out:
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
                         xmlNodePtr old_node,
                         xmlNodePtr new_node,
                         struct nc_err **error)
{
	int rc = EXIT_SUCCESS;

	/* We don't intend to touch the datastore here */
	config_modified = 0;

	nc_verb_verbose("%s called", __func__);

	if (((op & XMLDIFF_ADD) || (op & XMLDIFF_MOD)) && (new_node != NULL)) {
		/* new_node is the root of an XML configuration that we will
		 * save to a temporary file and pass directly to sja1105-tool
		 * for it to load */
		rc = sja1105_tool_apply_from_datastore(new_node);
		if (rc == EXIT_FAILURE) {
			nc_verb_warning("Failed to apply new datastore, "
			                "attempting recovery from old datastore");
			goto out;
			if (last_datastore_works == 0 || old_node == NULL) {
				*error = nc_err_new(NC_ERR_OP_FAILED);
				nc_err_set(*error, NC_ERR_PARAM_MSG,
				           "No recovery possible, hardware left in invalid state!");
				goto out;
			}
			/* Regardless of whether we manage to pull a recovery,
			 * this datastore (the next "last") does not work.
			 */
			rc = sja1105_tool_apply_from_datastore(old_node);
			if (rc != EXIT_SUCCESS) {
				nc_verb_error("Failed to recover sja1105-tool: "
				              "loading old datastore returned %d", rc);
				*error = nc_err_new(NC_ERR_OP_FAILED);
				nc_err_set(*error, NC_ERR_PARAM_MSG,
				           "Failed to recover from old datastore configuration.");
				last_datastore_works = 0;
				goto out;
			}
			nc_verb_warning("Recovered sja1105-tool staging area "
			                "to last known working datastore");
			*error = nc_err_new(NC_ERR_OP_FAILED);
			nc_err_set(*error, NC_ERR_PARAM_MSG,
			           "Failed to apply new datastore configuration (recovered successfully).");
			/* Recovered well, but callback was still a failure */
			rc = EXIT_FAILURE;
		}
		/* If we're telling the netconf server that this callback was
		 * a failure, it will revert this new_node to the old_node (which
		 * will still be old_node next time).
		 * Therefore, if we could recover from old_node now, we should be
		 * able to recover from it next time too.
		 */
		last_datastore_works = 1;
	} else if (op & XMLDIFF_REM) {
		/* What to do, what to do?
		 * The datastore is empty => user requested the hardware
		 * to be left in an invalid state. Don't allow that to happen.
		 */
		nc_verb_verbose("%s: op is REMOVE", __func__);
		*error = nc_err_new(NC_ERR_OP_FAILED);
		nc_err_set(*error, NC_ERR_PARAM_MSG,
		           "Not allowed to remove configuration data,"
		           "as it would leave the hardware in an invalid state.");
		return EXIT_FAILURE;
	} else {
		nc_verb_verbose("%s: unknown operation type", __func__);
	}
out:
	return rc;
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

static int file_has_xml_extension(const char *file)
{
	char head[128], extend[128];

	sscanf(file, "%[^.].%s", head, extend);
	if (strcmp(extend, "xml"))
		return EXIT_FAILURE;
	return EXIT_SUCCESS;
}

/* file_name - the path to the input (temporary) xml to be
 *             saved to the datastore xml
 */
static int modify_datastore_externally_from_sja1105_xml(const char *sja1105_xml)
{
	int rc = 0;

	if (access(sja1105_xml, F_OK) != EXIT_SUCCESS) {
		nc_verb_error("sja1105-tool xml %s does not exist", sja1105_xml);
		return EXIT_FAILURE;
	}

	if (pthread_mutex_trylock(&datastore_mutex) != 0) {
		/* file is still editing */
		return EXIT_FAILURE;
	}

	nc_verb_verbose("%s:", __func__);

	if (access(DATASTORE_FILENAME, F_OK) != EXIT_SUCCESS) {
		nc_verb_error("datastore %s does not exist", DATASTORE_FILENAME);
		pthread_mutex_unlock(&datastore_mutex);
		return EXIT_FAILURE;
	}

	/* Get a pointer to the datastore xml in root_datastore */
	xmlDocPtr  doc_datastore = xmlReadFile(DATASTORE_FILENAME, NULL, 0);
	xmlNodePtr root_datastore = xmlDocGetRootElement(doc_datastore);

	/* Get datastore running and candidate nodes */
	xmlNodePtr running_node =
	           probe_datastore_node(root_datastore, "running");
	if (running_node == NULL) {
		nc_verb_error("datastore running config node not found");
		rc = EXIT_FAILURE;
		goto out;
	}
	xmlNodePtr candidate_node =
	           probe_datastore_node(root_datastore, "candidate");
	if (candidate_node == NULL) {
		nc_verb_error("datastore candidate config node not found");
		rc = EXIT_FAILURE;
		goto out;
	}

	rc = populate_datastore_from_sja1105_xml(running_node, TEMPXML);
	if (rc != EXIT_SUCCESS) {
		nc_verb_error("Failed to append %s to %s running node",
		              sja1105_xml, DATASTORE_FILENAME);
		goto out;
	}
	rc = populate_datastore_from_sja1105_xml(candidate_node, TEMPXML);
	if (rc != EXIT_SUCCESS) {
		nc_verb_error("Failed to append %s to %s candidate node",
		              sja1105_xml, DATASTORE_FILENAME);
		goto out;
	}
	xmlSetProp(candidate_node, BAD_CAST "modified", BAD_CAST "true");
	/* Let the netopeer server know we modified the datastore */
	config_modified = 1;

out:
	xmlSaveFile(DATASTORE_FILENAME, doc_datastore);

	xmlFreeDoc(doc_datastore);
	pthread_mutex_unlock(&datastore_mutex);

	return rc;
}

nc_reply *rpc_save_local_config(xmlNodePtr input)
{
	xmlNodePtr file_name_xml = get_rpc_node("configfile", input);
	char *file_name;
	struct nc_err* e = NULL;
	char dest_filename[BUFSIZ];
	char cmd_file[BUFSIZ];
	int  rc;

	nc_verb_verbose("%s", __func__);

	file_name = (char*)xmlNodeGetContent(file_name_xml);

	sscanf(file_name, "%s", cmd_file);

	free(file_name);

	if (cmd_file[0] == '\"')
		strcpy(cmd_file, cmd_file + 1);
	if (cmd_file[strlen(cmd_file) - 1] == '\"')
		cmd_file[strlen(cmd_file) - 1] = '\0';

	rc = file_has_xml_extension(cmd_file);
	if (rc != EXIT_SUCCESS) {
		goto error;
	}
	nc_verb_verbose("%s: preparing save file: %s",
	                __func__, cmd_file);

	snprintf(dest_filename, BUFSIZ, CONF_FOLDER "/%s", cmd_file);

	rc = sja1105_tool_subprocess("config", "save", dest_filename);
	if (rc != SJA1105_ERR_OK) {
		nc_verb_error("subprocess failed");
		goto error;
	}

	return nc_reply_ok();
error:
	e = nc_err_new(NC_ERR_IN_USE);
	nc_err_set(e, NC_ERR_PARAM_MSG, "file validate failure, input a name with .xml extension!");
	return nc_reply_error(e);
}

nc_reply *rpc_load_local_config(xmlNodePtr input)
{
	xmlNodePtr file_name_xml = get_rpc_node("configfile", input);
	char *file_name;
	struct nc_err* e = NULL;
	const char *msg_err = NULL;
	char cmd_file[BUFSIZ];
	char filename[BUFSIZ];
	int  rc;

	nc_verb_verbose("%s", __func__);

	file_name = (char*)xmlNodeGetContent(file_name_xml);
	sscanf(file_name, "%s", cmd_file);
	free(file_name);

	if (cmd_file[0] == '\"')
		strcpy(cmd_file, cmd_file + 1);
	if (cmd_file[strlen(cmd_file) - 1] == '\"')
		cmd_file[strlen(cmd_file) - 1] = '\0';

	snprintf(filename, BUFSIZ, CONF_FOLDER "/%s", cmd_file);

	rc = access(filename, F_OK);
	if (rc != EXIT_SUCCESS) {
		msg_err = "File does not exist!";
		goto error;
	}

	nc_verb_verbose("%s: preparing load file: %s",
	                __func__, filename);

	if (access(filename, F_OK) != EXIT_SUCCESS) {
		msg_err = "Config file does not exist in /etc/sja1105/";
		nc_verb_error("%s, command file = %s", msg_err, filename);
		goto error;
	}

	rc = sja1105_tool_subprocess("config", "load -f", filename);
	if (rc != SJA1105_ERR_OK) {
		nc_verb_error("subprocess failed");
		goto error;
	}

	rc = modify_datastore_externally_from_sja1105_xml(filename);
	if (rc != EXIT_SUCCESS) {
		msg_err = "run netconf xml file load failure";
		goto error;
	}

	return nc_reply_ok();
error:
	e = nc_err_new(NC_ERR_IN_USE);
	nc_err_set(e, NC_ERR_PARAM_MSG, msg_err);
	return nc_reply_error(e);
}

nc_reply *rpc_load_default(__attribute__((unused)) xmlNodePtr input)
{
	nc_verb_verbose("%s", __func__);
	struct nc_err* e = NULL;
	const char *msg_err = NULL;
	int  rc;

	rc = sja1105_tool_subprocess("config", "default -f", "ls1021atsn");
	if (rc != SJA1105_ERR_OK) {
		nc_verb_error("subprocess failed");
		goto default_error;
	}
	rc = sja1105_tool_subprocess("config", "save", CONF_FOLDER "/standard.xml");
	if (rc != SJA1105_ERR_OK) {
		nc_verb_error("subprocess failed");
		goto default_error;
	}
	if (rc != EXIT_SUCCESS) {
		nc_verb_error("subprocess failed");
		goto default_error;
	}

	/* Sync datastore with sja1105-tool */
	rc = modify_datastore_externally_from_sja1105_xml(CONF_FOLDER "/standard.xml");
	if (rc != EXIT_SUCCESS) {
		msg_err = "run netconf xml file load failure";
		goto default_error;
	}

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
		{ .name="save-local-config", .func = rpc_save_local_config },
		{ .name="load-local-config", .func = rpc_load_local_config },
		{ .name="load-default",      .func = rpc_load_default }
	}
};

int staging_area_callback(const char *filepath,
                          xmlDocPtr *doc_datastore,
                          int *execflag)
{
	int rc = 0;

	/* 1. Check if the staging area was modified by previously
	 *    calling one of these functions:
	 *      * rpc_load_default()
	 *      * rpc_load_local_config()
	 *      * callback_nxp_sja1105() with (op & XMLDIFF_ADD) || (op & XMLDIFF_MOD)
	 *    Do the check by setting a global flag in those functions and
	 *    clearing it here.
	 *    If the flag was already clear by the time staging_area_callback()
	 *    is called, it means the staging area was modified externally
	 *    (most probably sja1105-tool).
	 */
	if (strcmp(filepath, STAGING_AREA) != 0) {
		nc_verb_error("%s called for invalid file %s!",
		              __func__, filepath);
		goto out_invalid;
	}

	nc_verb_verbose("%s: staging_area_mutex try lock", __func__);
	pthread_mutex_lock(&staging_area_mutex);
	nc_verb_verbose("%s: staging_area_mutex took lock", __func__);

	if (staging_area_modified) {
		/* We are guilty as charged, wasn't modified externally */
		goto out;
	}

	nc_verb_verbose("%s: detected external modification to staging area. "
	                "Syncing up the datastore with the new config",
	                __func__);

	/* 2. Import the externally modified sja1105-tool staging area,
	 *    first into a temporary XML, then into the datastore
	 *    running config node.
	 */
	rc = config_doc_from_staging_area(doc_datastore);
	*execflag = 1;
	/* Let the netopeer server know we modified the datastore */
	config_modified = 1;

out:
	staging_area_modified = 0;
	pthread_mutex_unlock(&staging_area_mutex);
	nc_verb_verbose("%s: staging_area_mutex unlock", __func__);
out_invalid:
	return rc;
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
	.callbacks = {
		{ .path = STAGING_AREA, .func = staging_area_callback },
	}
};

