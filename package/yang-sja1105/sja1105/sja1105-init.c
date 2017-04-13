/**
 * \file sja1105-init.c
 * \brief Startup datastore initiation for cfgsystem transAPI module.
 */

#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <libxml/tree.h>

#include <libnetconf.h>

/* from sja1105.c */
int transapi_init(xmlDocPtr *running);

const char* capabilities[] = {
	"urn:ietf:params:netconf:base:1.0",
	"urn:ietf:params:netconf:base:1.1",
	"urn:ietf:params:netconf:capability:startup:1.0"
};

void debug_print(NC_VERB_LEVEL level, const char* msg)
{
	switch (level) {
	case NC_VERB_ERROR:
		fprintf(stderr, "ERROR: %s\n", msg);
		break;
	case NC_VERB_WARNING:
		fprintf(stderr, "WARNING: %s\n", msg);
		break;
	case NC_VERB_VERBOSE:
		fprintf(stderr, "VERBOSE: %s\n", msg);
		break;
	case NC_VERB_DEBUG:
		fprintf(stderr, "DEBUG: %s\n", msg);
		break;
	}
}

void help(const char* progname)
{
	fprintf(stdout, "Usage: %s path [features ...]\n\n", progname);
	fprintf(stdout, "  path     Path to the sja1105's datastore file.\n");
	fprintf(stdout, "  features Space-separated features to be enabled.\n\n");
}

void create_datastore(xmlDocPtr *datastore)
{
	xmlNodePtr root, node;
	xmlNsPtr ns;

	*datastore = xmlNewDoc(BAD_CAST "1.0");
	root = xmlNewNode(NULL, BAD_CAST "datastores");
	xmlDocSetRootElement(*datastore, root);
	ns = xmlNewNs(root, BAD_CAST "urn:cesnet:tmc:datastores:file", NULL);
	xmlSetNs(root, ns);

	node = xmlNewChild(root, root->ns, BAD_CAST "running", NULL);
	xmlNewProp(node, BAD_CAST "lock", BAD_CAST "");
	node =xmlNewChild(root, root->ns, BAD_CAST "candidate", NULL);
	xmlNewProp(node, BAD_CAST "lock", BAD_CAST "");
	xmlNewProp(node, BAD_CAST "modified", BAD_CAST "false");
	node = xmlNewChild(root, root->ns, BAD_CAST "startup", NULL);
	xmlNewProp(node, BAD_CAST "lock", BAD_CAST "");
}

int main(int argc, char** argv)
{
	struct nc_session* dummy_session;
	struct nc_cpblts* capabs;
	struct ncds_ds* ds;
	nc_rpc* rpc;
	nc_reply* reply;
	char* new_startup_config;
	xmlDocPtr startup_doc = NULL;
	int ret = 0;

	if (argc < 2 || argv[1][0] == '-') {
		help(argv[0]);
		return 1;
	}

	/* set message printing callback */
	nc_callback_print(debug_print);

	/* init libnetconf for messages  from transAPI function */
	if (nc_init(NC_INIT_ALL | NC_INIT_MULTILAYER) == -1) {
		debug_print(NC_VERB_ERROR, "Could not initialize libnetconf.");
		return 1;
	}

	/* register the datastore */
	if ((ds = ncds_new(NCDS_TYPE_FILE, "/usr/local/etc/netopeer/sja1105/sja1105.yin", NULL)) == NULL) {
		nc_close();
		return 1;
	}

	/* add imports and augments */
	/*if (ncds_add_model("/usr/local/etc/netopeer//ietf-yang-types.yin") != 0 ) {
		nc_verb_error("Could not add import and augment models.");
		nc_close();
		return 1;
	}*/

	/* enable features */

	/* set the path to the target file */
	if (ncds_file_set_path(ds, argv[1]) != 0) {
		nc_verb_error("Could not set \"%s\" to the datastore.", argv[1]);
		nc_close();
		return 1;
	}
	if (ncds_init(ds) < 0) {
		nc_verb_error("Failed to nitialize datastore.");
		nc_close();
		return 1;
	}
	if (ncds_consolidate() != 0) {
		nc_verb_error("Could not consolidate the datastore.");
		nc_close();
		return 1;
	}

	if (transapi_init(&startup_doc) != EXIT_SUCCESS) {
		nc_close();
		return 1;
	}

	if (startup_doc == NULL || startup_doc->children == NULL) {
		/* nothing to do */
		nc_close();
		return 0;
	}

	/* create the dummy session */
	capabs = nc_cpblts_new(capabilities);
	if ((dummy_session = nc_session_dummy("session0", "root", NULL, capabs)) == NULL) {
		nc_verb_error("Could not create a dummy session.");
		nc_close();
		return 1;
	}

	/* dump the new config */
	xmlDocDumpMemory(startup_doc, (xmlChar**)&new_startup_config, NULL);
	xmlFreeDoc(startup_doc);

	/* apply edit-config rpc on the datastore */
	if ((rpc = nc_rpc_editconfig(NC_DATASTORE_STARTUP, NC_DATASTORE_CONFIG, 0, 0, 0, new_startup_config)) == NULL) {
		nc_verb_error("Could not create edit-config RPC.");
		nc_close();
		return 1;
	}
	free(new_startup_config);
	reply = ncds_apply_rpc2all(dummy_session, rpc, NULL);
	if (nc_reply_get_type(reply) != NC_REPLY_OK) {
		nc_verb_error("Edit-config RPC failed.");
		nc_close();
		return 1;
	}

	nc_reply_free(reply);
	nc_rpc_free(rpc);
	nc_cpblts_free(capabs);
	nc_session_free(dummy_session);
	nc_close();
	return ret;
}
