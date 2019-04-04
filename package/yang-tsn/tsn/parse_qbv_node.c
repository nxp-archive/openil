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
#include <tsn/genl_tsn.h>
#include <linux/tsn.h>
#include "yang_tsn.h"

typedef enum {
	PORT_TYPE_ENETC = 0,
	PORT_TYPE_SWITCH = 1,
	PORT_TYPE_UNKOWN = 0xff,
}PORT_TYPE;

PORT_TYPE judge_port_type(struct std_qbv_conf *admin_conf)
{
	PORT_TYPE type = PORT_TYPE_UNKOWN;
	if(strncmp(admin_conf->device_name,"swp", 3) == 0){
		type = PORT_TYPE_SWITCH;
	}else if(strncmp(admin_conf->device_name,"eno", 3) == 0){
		type = PORT_TYPE_ENETC;
	}
	return type;
}



int parse_sgs_params(xmlNode *node, struct std_qbv_conf *admin_conf, int list_index, char * err_msg)
{
	int rc = EXIT_SUCCESS;
	char * config_section;
	unsigned long tmp;
	char ele_val[MAX_ELEMENT_LENGTH];
	struct tsn_qbv_entry *gate_entry;
	
	if (node->type != XML_ELEMENT_NODE) {
		nc_verb_verbose("sgs-params node must be of element type!");
		sprintf(err_msg, "sgs-params node must be of element type!\n\tcurrent type is %d",
			node->type);
		rc = EXIT_FAILURE;
		goto out;
	}
	gate_entry = admin_conf->qbv_conf.admin.control_list;
	for (node = node->children; node != NULL; node = node->next) {
		if (node->type != XML_ELEMENT_NODE) {
			continue;
		}
		config_section = (char*) node->name;
		if (strcmp(config_section, "gate-states-value") == 0) {
			rc = xml_read_field(node, "gate-states-value", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse gate-states-value config from XML!");
				sprintf(err_msg, 
						"Could not parse gate-states-value config in %s from XML!", 
						admin_conf->device_name);
				goto out;
			}else{
				if(strlen(ele_val)>7)
					tmp = strtoul(ele_val, NULL, 2);
				else
					tmp = strtoul(ele_val, NULL, 0);
				(gate_entry + list_index)->gate_state = (uint8_t) tmp;
				
			}
		} else if (strcmp(config_section, "time-interval-value") == 0) {
			rc = xml_read_field(node, "time-interval-value", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse time-interval-value config from XML!");
				goto out;
			}else{
				tmp = strtoul(ele_val, NULL, 0);
				(gate_entry + list_index)->time_interval = (uint32_t) tmp;
			}
		} else {
			nc_verb_verbose("unknown config section %s", config_section);
			rc = EXIT_FAILURE;
		}
	}
out:
	return rc;
}

int parse_gate_control_entry(xmlNode *node, struct std_qbv_conf *admin_conf, int list_index, char * err_msg)
{
	int rc = EXIT_SUCCESS;
	char * config_section;
	char ele_val[MAX_ELEMENT_LENGTH];
	
	if (node->type != XML_ELEMENT_NODE) {
		nc_verb_verbose("gate-control-entry node must be of element type!");
		sprintf(err_msg, "gate-control-entry node must be of element type!\n\tcurrent type is %d",
			node->type);
		rc = EXIT_FAILURE;
		goto out;
	}
	for (node = node->children; node != NULL; node = node->next) {
		if (node->type != XML_ELEMENT_NODE) {
			continue;
		}
		config_section = (char*) node->name;
		if (strcmp(config_section, "operation-name") == 0) {
			rc = xml_read_field(node, "operation-name", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse operation-name config from XML!");
				sprintf(err_msg, 
						"Could not parse operation-name config in %s from XML!",
						admin_conf->device_name);
				goto out;
			}
		} else if (strcmp(config_section, "sgs-params") == 0) {
			rc = parse_sgs_params(node, admin_conf, list_index, err_msg);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse sgs-params config from XML!");
				goto out;
			}
		} else {
			nc_verb_verbose("unknown config section %s", config_section);
			rc = EXIT_FAILURE;
		}
	}
out:

	return rc;
}

int parse_admin_cycle_time(xmlNode *node, struct std_qbv_conf *admin_conf, char * err_msg)
{
	int rc = EXIT_SUCCESS;
	char * config_section;
	//unsigned long tmp;
	char ele_val[MAX_ELEMENT_LENGTH];
	//struct ieee_ptp_time admin_cycle_time={0,0};
	
	if (node->type != XML_ELEMENT_NODE) {
		nc_verb_verbose("admin-cycle-time node must be of element type!");
		sprintf(err_msg, "admin-cycle-time node must be of element type!\n\tcurrent type is %d",
			node->type);
		rc = EXIT_FAILURE;
		goto out;
	}
	for (node = node->children; node != NULL; node = node->next) {
		if (node->type != XML_ELEMENT_NODE) {
			continue;
		}
		config_section = (char*) node->name;
		if (strcmp(config_section, "numerator") == 0) {
			rc = xml_read_field(node, "numerator", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse numerator config from XML!");
				sprintf(err_msg, 
						"Could not parse numerator config in %s from XML!",
						admin_conf->device_name);
				goto out;
			}
		} else if (strcmp(config_section, "denominator") == 0) {
			rc = xml_read_field(node, "denominator", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse denominator config from XML!");
				goto out;
			}
		} else {
			nc_verb_verbose("unknown config section %s", config_section);
			rc = EXIT_FAILURE;
		}
	}
out:
	return rc;
}


int parse_admin_cycle_time_extension(xmlNode *node, struct std_qbv_conf *admin_conf, char * err_msg)
{
	int rc = EXIT_SUCCESS;
	char * config_section;
	unsigned long tmp;
	char ele_val[MAX_ELEMENT_LENGTH];
	
	if (node->type != XML_ELEMENT_NODE) {
		nc_verb_verbose("admin-cycle-time-extension node must be of element type!");
		sprintf(err_msg, "admin-cycle-time-extension node must be of element type!\n\tcurrent type is %d",
			node->type);
		rc = EXIT_FAILURE;
		goto out;
	}
	for (node = node->children; node != NULL; node = node->next) {
		if (node->type != XML_ELEMENT_NODE) {
			continue;
		}
		config_section = (char*) node->name;
		if (strcmp(config_section, "admin-cycle-time-extension") == 0) {
			rc = xml_read_field(node, "admin-cycle-time-extension", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse admin-cycle-time-extension config from XML!");
				sprintf(err_msg, 
						"Could not parse admin-cycle-time-extension config in %s from XML!",
						admin_conf->device_name);
				goto out;
			}else{
				tmp = strtoul(ele_val, NULL, 0);
				admin_conf->qbv_conf.admin.cycle_time_extension = (uint32_t) tmp;
			}
		}  else {
			nc_verb_verbose("unknown config section %s", config_section);
			rc = EXIT_FAILURE;
		}
	}
out:
	return rc;
}


int parse_admin_base_time(xmlNode *node, struct std_qbv_conf *admin_conf, char * err_msg)
{
	int rc = EXIT_SUCCESS;
	char * config_section;
	unsigned long tmp;
	char ele_val[MAX_ELEMENT_LENGTH];
	struct ieee_ptp_time admin_base_time = {0,0};
	PORT_TYPE port_type;
	
	if (node->type != XML_ELEMENT_NODE) {
		nc_verb_verbose("admin-base-time node must be of element type!");
		sprintf(err_msg, "admin-base-time node must be of element type!\n\tcurrent type is %d",
			node->type);
		rc = EXIT_FAILURE;
		goto out;
	}
	for (node = node->children; node != NULL; node = node->next) {
		if (node->type != XML_ELEMENT_NODE) {
			continue;
		}
		config_section = (char*) node->name;
		if (strcmp(config_section, "seconds") == 0) {
			rc = xml_read_field(node, "seconds", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse seconds config from XML!");
				sprintf(err_msg, 
						"Could not parse seconds config in %s from XML!",
						admin_conf->device_name);
				goto out;
			}else{
				tmp = strtoul(ele_val, NULL, 0);
				if(tmp <= 0xFFFFFFFF){
					admin_base_time.seconds = (uint32_t) tmp;
				}else{
					nc_verb_verbose("the value of seconds should no more than (2^32 -1)!");
					sprintf(err_msg, 
						"the value of seconds should no more than (2^32 -1) in %s",
						admin_conf->device_name);
					rc = EXIT_FAILURE;
					goto out;
				}
			}
		} else if (strcmp(config_section, "fractional-seconds") == 0) {
			rc = xml_read_field(node, "fractional-seconds", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse fractional-seconds config from XML!");
				goto out;
			}else{
				tmp = strtoul(ele_val, NULL, 0);
				if(tmp < 1000000000){
					admin_base_time.nano_seconds = (uint32_t) tmp;
				}else{
					nc_verb_verbose("the value of fractional-seconds should less than 10^9!");
					sprintf(err_msg, 
						"the value of fractional-seconds should less than 10^9 in %s",
						admin_conf->device_name);
					rc = EXIT_FAILURE;
					goto out;
				}
			}
		} else {
			nc_verb_verbose("unknown config section %s", config_section);
			rc = EXIT_FAILURE;
			goto out;
		}
	}
	/* there have diffrents between enetc and switch */
	port_type = judge_port_type(admin_conf);
	if(port_type == PORT_TYPE_SWITCH){
		admin_conf->qbv_conf.admin.base_time = admin_base_time.nano_seconds + (admin_base_time.seconds<<32);
	}else if(port_type == PORT_TYPE_ENETC){
		admin_conf->qbv_conf.admin.base_time = admin_base_time.nano_seconds + (admin_base_time.seconds*1000000000);
	}else{
		nc_verb_verbose("%s have unknown port type!", admin_conf->device_name);
		sprintf(err_msg, 
						"can't judge port type from port name \"%s\"",
						admin_conf->device_name);
		rc = EXIT_FAILURE;
		goto out;
	}
	
out:
	return rc;
}


int parse_admin_control_list(xmlNode *node, struct std_qbv_conf *admin_conf, uint32_t list_index, char * err_msg)
{
	int rc = EXIT_SUCCESS;
	char * config_section;
	unsigned long tmp;
	xmlNode *tmp_node;
	char ele_val[MAX_ELEMENT_LENGTH];
	
	tmp_node = node->children;
	if ((tmp_node->type != XML_ELEMENT_NODE) && (tmp_node->type != XML_TEXT_NODE)) {
		nc_verb_verbose("admin-control-list node must be of element or text type!");
		sprintf(err_msg, "admin-control-list node must be of element or text type!\n\tcurrent type is %d",
			tmp_node->type);
		rc = EXIT_FAILURE;
		goto out;
	}
	for (tmp_node = node->children; tmp_node != NULL; tmp_node = tmp_node->next) {
		if (tmp_node->type != XML_ELEMENT_NODE) {
			continue;
		}
		config_section = (char*) tmp_node->name;
		if (strcmp(config_section, "index") == 0) {
			rc = xml_read_field(tmp_node, "index", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse index config from XML!");
				goto out;
			}else{
				tmp = strtoul(ele_val, NULL, 0);
				if((uint32_t)tmp != list_index){
					nc_verb_verbose("index of control-list in %s is not discontinuous!",
						admin_conf->device_name);
					sprintf(err_msg, 
						"index of control-list in %s is not discontinuous!", admin_conf->device_name);
					rc = EXIT_FAILURE;
					goto out;
				}
			}
		} else if (strcmp(config_section, "gate-control-entry") == 0) {
			rc = parse_gate_control_entry(tmp_node, admin_conf, list_index, err_msg);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse gate-control-entry config from XML!");
				goto out;
			}
		} else {
			nc_verb_verbose("unknown config section %s", config_section);
			rc = EXIT_FAILURE;
		}
	}
out:
	return rc;
}

int parse_max_sdu_table(xmlNode *node, struct std_qbv_conf *admin_conf, char * err_msg)
{
	int rc = EXIT_SUCCESS;
	uint32_t traffic_class_index = 0;
	char * config_section;
	xmlNode * tmp_node = node;
	unsigned long tmp;
	char ele_val[MAX_ELEMENT_LENGTH];
	
	if (tmp_node->type != XML_ELEMENT_NODE) {
		nc_verb_verbose("max-sdu-table node must be of element type!");
		sprintf(err_msg, "max-sdu-tablet node must be of element type!\n\tcurrent type is %d",
			tmp_node->type);
		rc = EXIT_FAILURE;
		goto out;
	}
	if (strcasecmp((char*) tmp_node->name, "max-sdu-table")) {
		nc_verb_verbose("node must be named \"%s\"!", "max-sdu-table");
		sprintf(err_msg, "admin-control-list node must be of element type!\n\tcurrent type is %d",
			tmp_node->type);
		rc = EXIT_FAILURE;
		goto out;
	}
	for (tmp_node = node->children; tmp_node != NULL; tmp_node = tmp_node->next) {
		if (tmp_node->type != XML_ELEMENT_NODE) {
			continue;
		}
		config_section = (char*) tmp_node->name;
		if (strcmp(config_section, "traffic-class") == 0) {
			rc = xml_read_field(tmp_node, "traffic-class", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse traffic-class config from XML!");
				goto out;
			}else{
				traffic_class_index ++;
			}
		} else if (strcmp(config_section, "queue-max-sdu") == 0) {
			rc = xml_read_field(tmp_node, "queue-max-sdu", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse queue-max-sdu config from XML!");
				sprintf(err_msg, 
					"Could not parse the queue-max-sdu in %s", admin_conf->device_name);
				goto out;
			}else if(traffic_class_index == 1){
				tmp = strtoul(ele_val, NULL, 0);
				admin_conf->qbv_conf.maxsdu = (uint32_t) tmp;
			}
		} else {
			nc_verb_verbose("unknown config section %s", config_section);
			rc = EXIT_FAILURE;
		}
	}
out:
	return rc;
}


int parse_admin(xmlNode *node, struct std_qbv_conf *admin_conf, char *err_msg)
{
	int rc = EXIT_SUCCESS;
	char * config_section;
	uint32_t list_index = 0;
	xmlNode * tmp_node = node;
	unsigned long tmp;
	char ele_val[MAX_ELEMENT_LENGTH];
	
	if (node->type != XML_ELEMENT_NODE) {
		nc_verb_verbose("admin node must be of element type!");
		sprintf(err_msg, "admin node must be of element type!\n\tcurrent type is %d",
			tmp_node->type);
		rc = EXIT_FAILURE;
		goto out;
	}
	if (strcasecmp((char*) node->name, "admin")) {
		nc_verb_verbose("node must be named \"%s\"!", "admin");
		rc = EXIT_FAILURE;
		goto out;
	}
	for (tmp_node = node->children; tmp_node != NULL; tmp_node = tmp_node->next) {
		if (tmp_node->type != XML_ELEMENT_NODE) {
			continue;
		}
		config_section = (char*) tmp_node->name;
		if (strcmp(config_section, "admin-gate-states") == 0) {
			rc = xml_read_field(tmp_node, "admin-gate-states", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse admin-gate-states config from XML!");
				sprintf(err_msg, 
					"Could not parse the admin-gate-states in %s", admin_conf->device_name);
				goto out;
			}else{
				if(strlen(ele_val)>7)
					tmp = strtoul(ele_val, NULL, 2);
				else
					tmp = strtoul(ele_val, NULL, 0);
				admin_conf->qbv_conf.admin.gate_states = (uint8_t) tmp;
			}
		} else if (strcmp(config_section, "admin-control-list-length") == 0) {
			rc = xml_read_field(tmp_node, "admin-control-list-length", ele_val);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse admin-control-list-length config from XML!");
				goto out;
			}else{
				tmp = strtoul(ele_val, NULL, 0);
				admin_conf->qbv_conf.admin.control_list_length = (uint32_t) tmp;
			}
		} else if (strcmp(config_section, "admin-cycle-time") == 0) {
			/* admin_cycle_time will be recaculate in tsntool */
			rc = parse_admin_cycle_time(tmp_node, admin_conf, err_msg);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse admin-cycle-time config from XML!");
				goto out;
			}
		} else if (strcmp(config_section, "admin-cycle-time-extension") == 0) {
			rc = parse_admin_cycle_time_extension(tmp_node, admin_conf, err_msg);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse admin-cycle-time-extension config from XML!");
				goto out;
			}
		} else if (strcmp(config_section, "admin-base-time") == 0) {
			rc = parse_admin_base_time(tmp_node, admin_conf, err_msg);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse admin-base-time config from XML!");
				goto out;
			}
		} else if (strcmp(config_section, "admin-control-list") == 0) {
			rc = parse_admin_control_list(tmp_node, admin_conf, list_index, err_msg);
			if (rc != EXIT_SUCCESS) {
				nc_verb_verbose("Could not parse admin-control-list config from XML!");
				goto out;
			}else{
				list_index++;
			}
		} else {
			nc_verb_verbose("unknown config section %s", config_section);
			rc = EXIT_FAILURE;
		}
	}
out:
	return rc;
}



