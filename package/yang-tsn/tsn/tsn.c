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

#define GET_SWITCH_PORT_NAME_CMD "ls /sys/bus/pci/devices/0000:00:00.5/net/"
#define GET_ENETC0_PORT_NAME_CMD "ls /sys/bus/pci/devices/0000:00:00.0/net/"
#define GET_ENETC2_PORT_NAME_CMD "ls /sys/bus/pci/devices/0000:00:00.2/net/"
#define GET_ENETC3_PORT_NAME_CMD "ls /sys/bus/pci/devices/0000:00:00.6/net/"
#define INIT_PTP_CMD "devmem 0x1fc0900a0 w 0x00000004"
#define GET_PTP_SECOND_CMD "devmem 0x1fc0900c4"
#define MAX_PORT_NAME_LEN TOTAL_PORTS*MAX_IF_NAME_LENGTH

char interface_name[TOTAL_PORTS][MAX_IF_NAME_LENGTH];
/* transAPI version which must be compatible with libnetconf */
int transapi_version = 6;

/* Signal to libnetconf that configuration data were modified by any callback.
 * 0 - data not modified
 * 1 - data has been modified
 */
int config_modified = 0;

pthread_mutex_t datastore_mutex;

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
		/* Init libxml */
		xmlInitParser();
		/* Init pthread mutex on datastore */
		pthread_mutex_init(&datastore_mutex, NULL);

		/* TODO: Attempt to load the staging area (if one exists)
		 * into the initial running config (*running_node).
		 * Do not fail if we can't (it may simply not exist).
		 *
		 * Code currently commented out because the netopeer server
		 * doesn't seem to want to read the XML document in *running
		 * properly (perhaps the format is wrong?).
		 */

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
		return;
}

char * extract_data(char * str, char * delim)
{
		char * rc = NULL;
		rc = strtok(str, delim);
		if(rc){
				rc = strtok(NULL, " ");
		}else{
				rc = NULL;
		}
		return rc;
}
int enable_ptp(void)
{
		int rc = EXIT_SUCCESS;
		FILE *fp1;
		FILE *fp2;
		char cmd[50];
		char cmd_rst[50];
		unsigned long tmp = 0;
		nc_verb_verbose("%s is called", __func__);
		strcpy(cmd, GET_PTP_SECOND_CMD);
		fp1 = popen(cmd, "r");
		if(fp1){
				if(fgets(cmd_rst, MAX_PORT_NAME_LEN, fp1) != NULL){
						tmp = strtoul(cmd_rst, NULL, 0);
				}
		}else{
				rc = EXIT_FAILURE;
		}
		if(WEXITSTATUS(pclose(fp1))){
				rc = EXIT_FAILURE;
		}
		if(!tmp){
				nc_verb_verbose("ptp is isn't work");
				memset(cmd, 0 ,50);
				strcpy(cmd, INIT_PTP_CMD);
				fp2 = popen(cmd, "r");
				if(WEXITSTATUS(pclose(fp2))){
						rc = EXIT_FAILURE;
				}
		}
		return rc;
}

static cJSON *get_list_object_item(const cJSON * const object, const char * const name, int index)
{
		cJSON *current_element = NULL;
		int cnt=0;

		if ((object == NULL) || (name == NULL))
		{
				return NULL;
		}

		for(current_element = object->child;current_element != NULL;current_element = current_element->next)
		{
				if(!strcmp(name, current_element->string)){
						if(index == cnt){
								break;
						}else{
								cnt ++;
						}
				}
		}
		

		if ((current_element == NULL) || (current_element->string == NULL)) {
				return NULL;
		}

		return current_element;
}

int probe_qbv_xml_from_json(xmlNodePtr xml_node, cJSON *json_ob)
{
		int list_cnt;
		cJSON *oper,*item,*list,*time;
		xmlNodePtr oper_node;
		xmlNodePtr time_node;
		xmlNodePtr list_node;
		xmlNodePtr temp_node;
		char temp[80]={0};

		unsigned long second = 0;
		unsigned long nanosecond = 0;
		unsigned long temp_ul = 0;
		unsigned int temp_int = 0;
		int i=0;

		nc_verb_verbose("%s is called", __func__);
		item = cJSON_GetObjectItem(json_ob, "configchangetime");
		if(item){
				second = ((unsigned long)item->valuedouble/1000000000);
				nanosecond = ((unsigned long)item->valuedouble%1000000000);
				time_node = xmlNewChild(xml_node, NULL, BAD_CAST "config-change-time", NULL);
				sprintf(temp, "%ld", second);
				if(time_node){
						xmlNewTextChild(time_node, NULL, BAD_CAST "seconds", BAD_CAST temp);
						sprintf(temp, "%ld", nanosecond);
						xmlNewTextChild(time_node, NULL, BAD_CAST "fractional-seconds", BAD_CAST temp);
				}
		}
		item = cJSON_GetObjectItem(json_ob, "currenttime");
		if(item){
				second = ((unsigned long)item->valuedouble/1000000000);
				nanosecond = ((unsigned long)item->valuedouble%1000000000);
				time_node = xmlNewChild(xml_node, NULL, BAD_CAST "current-time", NULL);
				sprintf(temp, "%ld", second);
				xmlNewTextChild(time_node, NULL, BAD_CAST "seconds", BAD_CAST temp);
				sprintf(temp, "%ld", nanosecond);
				xmlNewTextChild(time_node, NULL, BAD_CAST "fractional-seconds", BAD_CAST temp);
		}
		item = cJSON_GetObjectItem(json_ob, "configpending");
		if(item){
				xmlNewTextChild(xml_node, NULL, BAD_CAST "config-pending", BAD_CAST "true");
		}

		item = cJSON_GetObjectItem(json_ob, "listmax");
		if(item){
				second = (unsigned long)(item->valuedouble);
				sprintf(temp, "%ld", second);
				xmlNewTextChild(xml_node, NULL, BAD_CAST "supported-list-max", BAD_CAST temp);
		}

		oper = cJSON_GetObjectItem(json_ob, "oper");
		if(oper){
				oper_node = xmlNewChild(xml_node, NULL, BAD_CAST "oper", NULL);
				item = cJSON_GetObjectItem(oper, "gatestate");
				if(item){
						temp_ul= (unsigned long)(item->valuedouble);
						sprintf(temp, "%ld", temp_ul);
						xmlNewTextChild(oper_node, NULL, BAD_CAST "oper-gate-states", BAD_CAST temp);
				}
				item = cJSON_GetObjectItem(oper, "listcount");
				if(item){
						temp_ul= (unsigned long)(item->valuedouble);
						sprintf(temp, "%ld", temp_ul);
						xmlNewTextChild(oper_node, NULL, BAD_CAST "oper-control-list-length", BAD_CAST temp);
				}
				list_cnt = (int)(temp_ul);
				time = cJSON_GetObjectItem(oper, "cycletime");
				if(time){
						temp_node = xmlNewChild(oper_node, NULL, BAD_CAST "oper-cycle-time", NULL);
						temp_ul = (unsigned long)(time->valuedouble);
						sprintf(temp, "%ld", temp_ul);
						xmlNewTextChild(temp_node, NULL, BAD_CAST "numerator", BAD_CAST temp);
						xmlNewTextChild(temp_node, NULL, BAD_CAST "denominator", BAD_CAST "1000000000");
				}
				item = cJSON_GetObjectItem(oper, "cycletimeext");
				if(item){
						temp_ul= (unsigned long)(item->valuedouble);
						sprintf(temp, "%ld", temp_ul);
						xmlNewTextChild(oper_node, NULL, BAD_CAST "oper-cycle-time-extension", BAD_CAST temp);
				}
				for(i=0;i<list_cnt; i++){
						list = get_list_object_item(oper, "list", i);
						if(list){
								list_node = xmlNewChild(oper_node, NULL, BAD_CAST "oper-control-list", NULL);

								item = cJSON_GetObjectItem(list, "entryid");
								if(item){
										temp_int= (unsigned int)(item->valuedouble);
										sprintf(temp, "%d", temp_int);
										xmlNewTextChild(list_node, NULL, BAD_CAST "index", BAD_CAST temp);
								}
								temp_node = xmlNewChild(list_node, NULL, BAD_CAST "gate-control-entry", NULL);
								temp_node = xmlNewChild(temp_node, NULL, BAD_CAST "set-gate-states", NULL);
								temp_node = xmlNewChild(temp_node, NULL, BAD_CAST "sgs-params", NULL);
								item = cJSON_GetObjectItem(list, "gate");
								if(item){
										temp_int= (unsigned int)(item->valuedouble);
										sprintf(temp, "%d", temp_int);
										xmlNewTextChild(temp_node, NULL, BAD_CAST "gate-states-value", BAD_CAST temp);
								}
								item = cJSON_GetObjectItem(list, "timeperiod");
								if(item){
										temp_int= (unsigned int)(item->valuedouble);
										sprintf(temp, "%d", temp_int);
										xmlNewTextChild(temp_node, NULL, BAD_CAST "time-interval-value", BAD_CAST temp);
								}
						}
				}
				item = cJSON_GetObjectItem(oper, "basetime");
				if(item){
						second = ((unsigned long)item->valuedouble/1000000000);
						nanosecond = ((unsigned long)item->valuedouble%1000000000);
						time_node = xmlNewChild(xml_node, NULL, BAD_CAST "oper-base-time", NULL);
						sprintf(temp, "%ld", second);
						xmlNewTextChild(time_node, NULL, BAD_CAST "seconds", BAD_CAST temp);
						sprintf(temp, "%ld", nanosecond);
						xmlNewTextChild(time_node, NULL, BAD_CAST "fractional-seconds", BAD_CAST temp);
				}
		}
		return 1;
}
int get_qbv_status(xmlNodePtr node)
{
		FILE *fp;
		int rc = EXIT_SUCCESS;
		int len = 0;
		int port;
		xmlNodePtr root_node = node;
		xmlNodePtr interface_node;
		cJSON *json;
		struct tsn_qbv_status qbvstaus;
		char *json_data;
		nc_verb_verbose("%s is called", __func__);
		for(port=0; port<TOTAL_PORTS; port++){
				/* Add interface node */
				interface_node = xmlNewChild(root_node, NULL, BAD_CAST "interface", NULL);
				if(interface_name[port] == NULL){
						break;
				}
				xmlNewTextChild(interface_node, NULL, BAD_CAST "name", BAD_CAST interface_name[port]);
				genl_tsn_init();
				tsn_qos_port_qbv_status_get(interface_name[port], &qbvstaus);
				genl_tsn_close();
				fp = fopen(TSNTOOL_PORT_ST_FILE, "r");
				if(fp){
						fseek(fp,0,SEEK_END);
						len = ftell(fp);
						fseek(fp,0,SEEK_SET);
						json_data = (char *)malloc(len+1);
						if(json_data){
								fread(json_data, 1, len, fp);
								json = cJSON_Parse(json_data);
								if(json){
										probe_qbv_xml_from_json(interface_node, json);
								}else{
										nc_verb_verbose("json parse error");
								}
								cJSON_Delete(json);
								free(json_data);
						}else{
								nc_verb_verbose("malloc error");
								fclose(fp);
						}
				}else{
						nc_verb_verbose("open \"%s\" error");
				}
				if(rename(TSNTOOL_PORT_ST_FILE, TSNTOOL_PORT_ST_BAK_FILE)){
						nc_verb_verbose("rename error");
				}
		}
		return rc;
}

int get_port_name_list(char * port_name_list)
{
		FILE *fp;
		int rc = EXIT_SUCCESS;
		int len = 0;
		int i;
		char *temp;
		char cmd_rst[MAX_PORT_NAME_LEN];
		nc_verb_verbose("%s is called", __func__);
		memset(port_name_list, 0, MAX_PORT_NAME_LEN);

		fp = popen(GET_ENETC0_PORT_NAME_CMD, "r");
		if(fp){
				while(fgets(cmd_rst, MAX_PORT_NAME_LEN, fp) != NULL){
						len = strlen(cmd_rst) - 1;
						if(cmd_rst[len] == '\n'){
								cmd_rst[len] = ' ';
								cmd_rst[len+1] = '\0';
						}
						strcat(port_name_list, cmd_rst);
				}
		}else{
				nc_verb_verbose("enetc0 err");
		}
		if(WEXITSTATUS(pclose(fp))){
				return EXIT_FAILURE;
		}
		fp = popen(GET_ENETC2_PORT_NAME_CMD, "r");
		if(fp){
				while(fgets(cmd_rst, MAX_PORT_NAME_LEN, fp) != NULL){
						len = strlen(cmd_rst) - 1;
						if(cmd_rst[len] == '\n'){
								cmd_rst[len] = ' ';
								cmd_rst[len+1] = '\0';
						}
						strcat(port_name_list, cmd_rst);
				}
		}else{
				nc_verb_verbose("enetc2 err");
		}
		if(WEXITSTATUS(pclose(fp))){
				return EXIT_FAILURE;
		}
		fp = popen(GET_ENETC3_PORT_NAME_CMD, "r");
		if(fp){
				while(fgets(cmd_rst, MAX_PORT_NAME_LEN, fp) != NULL){
						len = strlen(cmd_rst) - 1;
						if(cmd_rst[len] == '\n'){
								cmd_rst[len] = ' ';
								cmd_rst[len+1] = '\0';
						}
						strcat(port_name_list, cmd_rst);
				}
		}else{
				nc_verb_verbose("enetc3 err");
		}
		if(WEXITSTATUS(pclose(fp))){
				return EXIT_FAILURE;
		}
		fp = popen(GET_SWITCH_PORT_NAME_CMD, "r");
		if(fp){
				while(fgets(cmd_rst, MAX_PORT_NAME_LEN, fp) != NULL){
						len = strlen(cmd_rst) - 1;
						if(cmd_rst[len] == '\n'){
								cmd_rst[len] = ' ';
								cmd_rst[len+1] = '\0';
						}
						strcat(port_name_list, cmd_rst);
				}
		}
		if(WEXITSTATUS(pclose(fp))){
				return EXIT_FAILURE;
		}
		temp = strtok(port_name_list, " ");
		i = 0;
		strcpy(interface_name[i++], temp);
		while(1){
				temp = strtok(NULL, " ");
				if(temp != NULL){
						strcpy(interface_name[i++], temp);
				}else{
						break;
				}
		}
		return rc;
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
				__attribute__((unused)) struct nc_err **error)
{
		xmlDocPtr doc = NULL;
		char port_name_list[MAX_PORT_NAME_LEN];
		xmlNodePtr root;
		xmlNsPtr ns;
		xmlNodePtr node;
		nc_verb_verbose("%s is called", __func__);
		doc = xmlNewDoc(BAD_CAST "1.0");
		root = xmlNewDocNode(doc, NULL, BAD_CAST "tsn", NULL);
		xmlDocSetRootElement(doc, root);
		ns = xmlNewNs(root, BAD_CAST TSN_NS, NULL);
		xmlSetNs(root, ns);
		node = xmlNewChild(root,NULL, BAD_CAST "interfaces-state", BAD_CAST NULL);
		get_port_name_list(port_name_list);
		get_qbv_status(node);

		return(doc);

}

int parse_interface(xmlNode *node, struct std_qbv_conf *admin_conf, char * err_msg)
{
		int rc = EXIT_SUCCESS;
		char * config_section;
		xmlNode * tmp_node = node;
		int have_if_name=0;
		char ele_val[MAX_ELEMENT_LENGTH];

		nc_verb_verbose("%s is called", __func__);
		if (tmp_node->type != XML_ELEMENT_NODE) {
				nc_verb_verbose("Interface node must be of element type!");
				rc = EXIT_FAILURE;
				goto out;
		}
		if (strcasecmp((char*) tmp_node->name, "interface")) {
				nc_verb_verbose("node must be named \"%s\"!", "interface");
				rc = EXIT_FAILURE;
				goto out;
		}
		/* must ensure that interface have "name" element */
		for (tmp_node = node->children; tmp_node != NULL; tmp_node = tmp_node->next) {
				if (tmp_node->type != XML_ELEMENT_NODE) {
						continue;
				}
				config_section = (char*) tmp_node->name;
				if (strcmp(config_section, "name") == 0) {
						rc = xml_read_field(tmp_node, "name", ele_val);
						if(rc != EXIT_SUCCESS){
								nc_verb_verbose("Could not parse name of Interface from XML!");
						}else{
								have_if_name = 1;
								snprintf(admin_conf->device_name, MAX_ELEMENT_LENGTH, ele_val);
						}

						break;
				}
		}
		if(!have_if_name){
				snprintf(err_msg, MAX_ELEMENT_LENGTH,
								"Could not parse the device's name of Interface in %s",
								admin_conf->device_name);
				rc = EXIT_FAILURE;
				goto out;
		}

		for (node = node->children; node != NULL; node = node->next) {
				if (node->type != XML_ELEMENT_NODE) {
						continue;
				}
				config_section = (char*) node->name;
				if (strcmp(config_section, "gate-enabled") == 0) {
						rc = xml_read_field(node, "gate-enabled", ele_val);
						if (rc != EXIT_SUCCESS) {
								nc_verb_verbose("Could not parse gate-enabled config from XML!");
								snprintf(err_msg, MAX_ELEMENT_LENGTH,
										"Could not parse gate-enabled config from XML in %s!",
												admin_conf->device_name);
								goto out;
						}else{
								if(strcmp(ele_val, "true") == 0){
										admin_conf->qbv_conf.gate_enabled = TRUE;
								}else if(strcmp(ele_val, "false") == 0){
										admin_conf->qbv_conf.gate_enabled = FALSE;
								}else{
										snprintf(err_msg, MAX_ELEMENT_LENGTH,
														"the value of gate-enabled in %s must be \"true\" or \"false\"!",
														admin_conf->device_name);
										rc = EXIT_FAILURE;
										goto out;
								}
						}
				} else if (strcmp(config_section, "name") == 0) {
						continue;
				} else if (strcmp(config_section, "max-sdu-table") == 0) {
						rc = parse_max_sdu_table(node, admin_conf,err_msg);
						if (rc != EXIT_SUCCESS) {
								nc_verb_verbose("Could not parse max-sdu-table config from XML!");
								snprintf(err_msg, MAX_ELEMENT_LENGTH,
												"Could not parse max-sdu-table config from XML in %s!",
												admin_conf->device_name);
								goto out;
						}
				} else if (strcmp(config_section, "config-change") == 0) {
						rc = xml_read_field(node, "config-change", ele_val);
						if (rc != EXIT_SUCCESS) {
								nc_verb_verbose("Could not parse config-change config from XML!");
								goto out;
						}else{
								if(strcmp(ele_val, "true") == 0){
										admin_conf->qbv_conf.config_change = TRUE;
								}else if(strcmp(ele_val, "false") == 0){
										admin_conf->qbv_conf.config_change = FALSE;
								}else{
										snprintf(err_msg, MAX_ELEMENT_LENGTH,
														"the value of config-change in %s must be \"true\" or \"false\"!",
														admin_conf->device_name);
										rc = EXIT_FAILURE;
										goto out;
								}
						}
				} else if (strcmp(config_section, "admin") == 0) {
						rc = parse_admin(node, admin_conf,err_msg);
						if (rc != EXIT_SUCCESS) {
								nc_verb_verbose("Could not parse admin config from XML!");
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

int parse_interfaces(xmlNode *node, char * err_msg, int apply_flag)
{
		char *config_section;
		struct std_qbv_conf std_admin_conf[TOTAL_PORTS];
		struct tsn_qbv_entry *qbv_entry[TOTAL_PORTS]={0};

		xmlNode *interface_node;
		int rc = EXIT_SUCCESS;
		int interface_num = 0;
		int malloc_num = 0;
		char port_name_list[MAX_PORT_NAME_LEN];
		int i = 0, j = 0;
		int valid_port_name;

		nc_verb_verbose("%s is called", __func__);
		if (node->type != XML_ELEMENT_NODE) {
				nc_verb_verbose("Interfaces node must be of element type!");
				rc = EXIT_FAILURE;
				goto out;
		}
		if (strcasecmp((char*) node->name, "interfaces")) {
				nc_verb_verbose("node must be named \"%s\"!", "interfaces");
				snprintf(err_msg, MAX_ELEMENT_LENGTH, "must have node \"interfaces\"!");
				rc = EXIT_FAILURE;
				goto out;
		}

		if(get_port_name_list(port_name_list) == EXIT_FAILURE){
				sprintf(err_msg, "get port name list fail!");
				rc = EXIT_FAILURE;
				goto out;
		}

		for (interface_node = node->children; interface_node != NULL; interface_node = interface_node->next) {
				if (interface_node->type != XML_ELEMENT_NODE) {
						continue;
				}
				config_section = (char*) interface_node->name;
				if (strcmp(config_section, "interface") == 0) {
						qbv_entry[interface_num] = (struct tsn_qbv_entry *)malloc(MAX_ENTRY_SIZE);
						if (qbv_entry[interface_num] == NULL) {
								nc_verb_verbose("malloc space error.\n");
								rc = EXIT_FAILURE;
								goto out;
						}
						malloc_num ++;

						memset(std_admin_conf+interface_num, 0, sizeof(struct std_qbv_conf));
						memset(qbv_entry[interface_num], 0, MAX_ENTRY_SIZE);

						std_admin_conf[interface_num].qbv_conf.admin.control_list = qbv_entry[interface_num];

						rc = parse_interface(interface_node, std_admin_conf+interface_num, err_msg);
						if (rc != EXIT_SUCCESS) {
								nc_verb_verbose(err_msg);
								goto out;
						}
						interface_num ++;
				} else if (strcmp(config_section, "device-id") == 0) {
						continue;
				} else {
						nc_verb_verbose("unknown config section %s", config_section);
						rc = EXIT_FAILURE;
						goto out;
				}
				/* validate configuration */
				/* check ports' name */


				for(i=0; i<interface_num; i++){
						valid_port_name = 0;
						for(j=0; j<TOTAL_PORTS; j++){
								if(strcmp(std_admin_conf[i].device_name, interface_name[j]) == 0){
										valid_port_name++;
										break;
								}
						}
						if(!valid_port_name){
								sprintf(err_msg, "Invalid port name \"%s\"! please check ports' name by \"get_ports_name\" via user-rpc",
												std_admin_conf[i].device_name);
								rc = EXIT_FAILURE;
								goto out;
						}
				}
		}

		/* apply new configuration */
		if(apply_flag){
				/* ensure that the ptp clock is working */
				enable_ptp();
				genl_tsn_init();
				for(i=0; i<interface_num; i++){
						rc = tsn_qos_port_qbv_set(std_admin_conf[i].device_name, &std_admin_conf[i].qbv_conf,
										std_admin_conf[i].qbv_conf.gate_enabled);
						if(rc != EXIT_SUCCESS){
								snprintf(err_msg, MAX_ELEMENT_LENGTH, "Apply new configuration for %s error!!!",
												std_admin_conf[i].device_name);
								break;
						}
				}
				genl_tsn_close();
		}

out:
		for(i=0; i<malloc_num; i++){
				free(qbv_entry[i]);
		}
		return rc;
}

/*
 * Mapping prefixes with namespaces.
 * Do NOT modify this structure!
 */
struct ns_pair namespace_mapping[] = {{"nxp", TSN_NS}, {NULL, NULL}};

/*
 * CONFIGURATION callbacks
 * Here follows set of callback functions run every time some change in
 * associated part of running datastore occurs.
 * You can safely modify the bodies of all function as well as add new
 * functions for better lucidity of code.
 */

/**
 * @brief This callback will be run when node in path /nxp:tsn changes
 *
 * @param[in] data	Double pointer to void. Its passed to every callback. You can share data using it.
 * @param[in] op	Observed change in path. XMLDIFF_OP type.
 * @param[in] node	Modified node. if op == XMLDIFF_REM its copy of node removed.
 * @param[out] error	If callback fails, it can return libnetconf error structure with a failure description.
 *
 * @return EXIT_SUCCESS or EXIT_FAILURE
 */
int callback_nxp_tsn(__attribute__((unused)) void **data,
				__attribute__((unused)) XMLDIFF_OP op,
				__attribute__((unused)) xmlNodePtr old_node,
				__attribute__((unused)) xmlNodePtr new_node,
				__attribute__((unused)) struct nc_err **error)
{
		xmlNodePtr node;
		char err_msg[MAX_ELEMENT_LENGTH];
		int rc = EXIT_SUCCESS;

		nc_verb_verbose("%s is called", __func__);
		if(op & XMLDIFF_REM){
				/* Remove operation will be implement after callbacks return error */
				nc_verb_verbose("Have Remove operation on datastore!");
		}else{
				node = new_node;
				for (node = node->children; node != NULL; node = node->next) {
						if (node->type != XML_ELEMENT_NODE) {
								continue;
						}
						if (xmlStrEqual(BAD_CAST node->name, BAD_CAST "interfaces") == 1) {
								rc = parse_interfaces(node, err_msg, 0);
								if (rc != EXIT_SUCCESS) {
										nc_verb_verbose("Could not parse interfaces config from XML!");
										goto out;
								}
						}
				}
		}

out:
		if(rc != EXIT_SUCCESS){
				*error = nc_err_new(NC_ERR_OP_FAILED);
				nc_err_set(*error, NC_ERR_PARAM_MSG, err_msg);
		}
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
				{.path = "/nxp:tsn", .func = callback_nxp_tsn},
		}
};


/*
 * RPC callbacks
 * Here follows set of callback functions run every time RPC specific for this device arrives.
 * You can safely modify the bodies of all function as well as add new functions for better lucidity of code.
 * Every function takes array of inputs as an argument. On few first lines they are assigned to named variables. Avoid accessing the array directly.
 * If input was not set in RPC message argument in set to NULL.
 */


nc_reply *rpc_get_ports_name(__attribute__((unused)) xmlNodePtr input)
{
		xmlDocPtr doc = NULL;
		xmlNodePtr root;
		xmlNsPtr ns;
		struct nc_err* e = NULL;
		char err_msg[MAX_ELEMENT_LENGTH];
		char port_name_list[MAX_PORT_NAME_LEN];
		int i;

		nc_verb_verbose("%s is called", __func__);

		if(get_port_name_list(port_name_list) == EXIT_FAILURE){
				strcpy(err_msg, "get port name list fail!");
				goto error;
		}
		doc = xmlNewDoc(BAD_CAST "1.0");
		root = xmlNewDocNode(doc, NULL, BAD_CAST "ports_name", NULL);
		xmlDocSetRootElement(doc, root);
		ns = xmlNewNs(root, BAD_CAST TSN_NS, NULL);
		xmlSetNs(root, ns);

		for(i=0; i<TOTAL_PORTS; i++){
				xmlNewChild(root, NULL, BAD_CAST "name", BAD_CAST interface_name[i]);
		}

		return ncxml_reply_data(root);
error:
		e = nc_err_new(NC_ERR_IN_USE);
		nc_err_set(e, NC_ERR_PARAM_MSG, err_msg);
		return nc_reply_error(e);
}

nc_reply *rpc_validate_config(__attribute__((unused)) xmlNodePtr input)
{
		struct nc_err* e = NULL;
		char err_msg[MAX_ELEMENT_LENGTH];
		int rc = EXIT_SUCCESS;
		xmlNodePtr candidate_node;
		xmlDocPtr  doc_datastore;
		xmlNodePtr root_datastore;
		xmlNodePtr tsn_node;
		xmlNodePtr node;

		nc_verb_verbose("%s is called", __func__);

		if (access(DATASTORE_FILENAME, F_OK) != EXIT_SUCCESS) {
				nc_verb_error("%s does not exist!", DATASTORE_FILENAME);
				sprintf(err_msg,"%s does not exist!", DATASTORE_FILENAME);
				goto error;
		}
		doc_datastore = xmlReadFile(DATASTORE_FILENAME, NULL, 0);
		root_datastore = xmlDocGetRootElement(doc_datastore);

		candidate_node = get_child_node(root_datastore, "candidate");
		if(candidate_node == NULL){
				sprintf(err_msg,"Could not find candidate node in %s!", DATASTORE_FILENAME);
				goto error;
		}
		tsn_node = get_child_node(candidate_node, "tsn");
		if(tsn_node == NULL){
				sprintf(err_msg,"Could not find tsn node in %s!", DATASTORE_FILENAME);
				goto error;
		}

		for (node = tsn_node->children; node != NULL; node = node->next) {
				if (node->type != XML_ELEMENT_NODE) {
						continue;
				}
				if (xmlStrEqual(BAD_CAST node->name, BAD_CAST "interfaces") == 1) {
						rc = parse_interfaces(node, err_msg, 0);
						if (rc != EXIT_SUCCESS) {
								nc_verb_verbose("Could not parse interfaces config from XML!");
								goto error;
						}
				}
		}
		return nc_reply_ok();
error:
		e = nc_err_new(NC_ERR_OP_FAILED);
		nc_err_set(e, NC_ERR_PARAM_MSG, err_msg);
		return nc_reply_error(e);
}

nc_reply *rpc_apply_config(__attribute__((unused)) xmlNodePtr input)
{
		struct nc_err* e = NULL;
		char err_msg[MAX_ELEMENT_LENGTH];
		int rc = EXIT_SUCCESS;
		xmlNodePtr running_node;
		xmlDocPtr  doc_datastore;
		xmlNodePtr root_datastore;
		xmlNodePtr tsn_node;
		xmlNodePtr node;

		nc_verb_verbose("%s is called", __func__);

		if (access(DATASTORE_FILENAME, F_OK) != EXIT_SUCCESS) {
				nc_verb_error("%s does not exist!", DATASTORE_FILENAME);
				sprintf(err_msg,"%s does not exist!", DATASTORE_FILENAME);
				goto error;
		}
		doc_datastore = xmlReadFile(DATASTORE_FILENAME, NULL, 0);
		root_datastore = xmlDocGetRootElement(doc_datastore);

		running_node = get_child_node(root_datastore, "running");
		if(running_node == NULL){
				sprintf(err_msg,"Could not find running node in %s!", DATASTORE_FILENAME);
				goto error;
		}
		tsn_node = get_child_node(running_node, "tsn");
		if(tsn_node == NULL){
				sprintf(err_msg,"Could not find tsn node in %s!", DATASTORE_FILENAME);
				goto error;
		}

		for (node = tsn_node->children; node != NULL; node = node->next) {
				if (node->type != XML_ELEMENT_NODE) {
						continue;
				}
				if (xmlStrEqual(BAD_CAST node->name, BAD_CAST "interfaces") == 1) {
						rc = parse_interfaces(node, err_msg, 1);
						if (rc != EXIT_SUCCESS) {
								nc_verb_verbose("Could not parse interfaces config from XML!");
								goto error;
						}
				}
		}
		return nc_reply_ok();
error:
		e = nc_err_new(NC_ERR_OP_FAILED);
		nc_err_set(e, NC_ERR_PARAM_MSG, err_msg);
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
				{ .name="get_ports_name",  .func = rpc_get_ports_name },
				{ .name="validate_config",  .func = rpc_validate_config },
				{ .name="apply_config",  .func = rpc_apply_config },
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


