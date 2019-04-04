// SPDX-License-Identifier: (GPL-2.0 OR MIT)
/*
 * Copyright 2019 NXP
 */
#include <tsn/genl_tsn.h>
#include <linux/tsn.h>
#include <libxml/tree.h>
#include <libnetconf_xml.h>

#ifndef __YANG_TSN_H__
#define __YANG_TSN_H__


#define TSN_NS "http://nxp.com/ns/yang/tsn"
#define ENETC_PORT_NUM 3
#define SWITCH_PORT_NUM 6
#define TOTAL_PORTS (ENETC_PORT_NUM+SWITCH_PORT_NUM)
#define MAX_ELEMENT_LENGTH 100
#define MAX_IF_NAME_LENGTH 20

#define CONF_FOLDER        "/usr/local/etc/netopeer/tsn"
#define DATASTORE_FILENAME "/usr/local/etc/netopeer/tsn/datastore.xml"
#define TEMPXML            "/var/lib/libnetconf/config.xml"

struct std_qbv_conf{
	char device_name[MAX_IF_NAME_LENGTH];
	struct tsn_qbv_conf qbv_conf;
};

struct ieee_cycle_time{
	uint32_t numerator;
	uint32_t denominator;
};

struct ieee_ptp_time{
	uint64_t seconds;
	uint64_t nano_seconds;
};

int xml_read_field(xmlNode *node, char *field_name,char * data);

int parse_sgs_params(xmlNode *node, struct std_qbv_conf *admin_conf, int list_index, char * err_msg);
int parse_gate_control_entry(xmlNode *node, struct std_qbv_conf *admin_conf, int list_index, char * err_msg);
int parse_admin_cycle_time(xmlNode *node, struct std_qbv_conf *admin_conf, char * err_msg);
int parse_admin_cycle_time_extension(xmlNode *node, struct std_qbv_conf *admin_conf, char * err_msg);
int parse_admin_base_time(xmlNode *node, struct std_qbv_conf *admin_conf, char * err_msg);
int parse_admin_control_list(xmlNode *node, struct std_qbv_conf *admin_conf, uint32_t list_index, char * err_msg);
int parse_max_sdu_table(xmlNode *node, struct std_qbv_conf *admin_conf, char * err_msg);
int parse_admin(xmlNode *node, struct std_qbv_conf *admin_conf, char *err_msg);
xmlNodePtr get_child_node(xmlNodePtr parent_node, const char *child_node_name);
#endif