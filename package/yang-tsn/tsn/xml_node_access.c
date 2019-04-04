 /*
 * Copyright 2019 NXP
 *
 * SPDX-License-Identifier:	GPL-2.0+
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
#include "yang_tsn.h"


int xml_read_field(xmlNode *node, char *field_name,char * data)
{
	char     *value = NULL;
	int       rc = EXIT_SUCCESS;
	xmlNode  *cur;
	for (cur = node; cur != NULL; cur = cur->next) {
		if (xmlStrcmp(cur->name, (const xmlChar*) field_name) == 0) {
			value = (char*) xmlNodeListGetString(cur->doc, cur->xmlChildrenNode, 1);
		}
	}
	if (value == NULL) {
		rc = EXIT_FAILURE;
		goto out;
	}
	else{
		snprintf(data, MAX_ELEMENT_LENGTH, value);
	}
out:
	xmlFree(value);
	return rc;
}


xmlNodePtr get_child_node(xmlNodePtr parent_node, const char *child_node_name)
{
	xmlNodePtr node = NULL;

	if (parent_node->type != XML_ELEMENT_NODE) {
		nc_verb_error("Root node must be of element type!");
		goto out;
	}
	for (node = parent_node->children; node != NULL; node = node->next) {
		if (!strcmp((char*)node->name, child_node_name)) {
			return node;
		}
	}
out:
	return NULL;
}

