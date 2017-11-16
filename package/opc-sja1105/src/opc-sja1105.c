/* This work is licensed under a Creative Commons CCZero 1.0 Universal License.
 * See http://creativecommons.org/publicdomain/zero/1.0/ for more information. */

#include <stdio.h>
#include <signal.h>
#include <open62541.h>
#include <sja1105/status.h>

int SJA1105_VERBOSE_CONDITION = 1;
int SJA1105_DEBUG_CONDITION = 1;

enum SJA1105PortCounter {
	N_N664ERR = 0,
	N_VLANERR,
	N_UNRELEASED,
	N_SIZERR,
	N_CRCERR,
	N_VLNOTFOUND,
	N_BEPOLERR,
	N_POLERR,
	N_RXFRM,
	N_RXBYTE,
	N_TXFRM,
	N_TXBYTE,
	N_QFULL,
	N_PARTDROP,
	N_EGR_DISABLED,
	N_NOT_REACH,
	N_TOTAL_COUNTERS,
};

char *CounterNames[N_TOTAL_COUNTERS] = {
	"N_N664ERR",
	"N_VLANERR",
	"N_UNRELEASED",
	"N_SIZERR",
	"N_CRCERR",
	"N_VLNOTFOUND",
	"N_BEPOLERR",
	"N_POLERR",
	"N_RXFRM",
	"N_RXBYTE",
	"N_TXFRM",
	"N_TXBYTE",
	"N_QFULL",
	"N_PARTDROP",
	"N_EGR_DISABLED",
	"N_NOT_REACH",
};

char *CounterDescriptions[N_TOTAL_COUNTERS] = {
	/* N_N664ERR */
	"Frames dropped because (a) they had an Ethertype other than 800h "
	"while the port's DRPNONA664 flag was set, (b) they were not "
	"VLAN-tagged while untagged traffic was not allowed (DRPUNTAG = 1)",
	/* N_VLANERR */
	"",
	/* N_UNRELEASED */
	"",
	/* N_SIZERR */
	"",
	/* N_CRCERR */
	"",
	/* N_VLNOTFOUND */
	"",
	/* N_BEPOLERR */
	"",
	/* N_POLERR */
	"",
	/* N_RXFRM */
	"",
	/* N_RXBYTE */
	"",
	/* N_TXFRM */
	"",
	/* N_TXBYTE */
	"",
	/* N_QFULL */
	"",
	/* N_PARTDROP */
	"",
	/* N_EGR_DISABLED */
	"",
	/* N_NOT_REACH */
	"",
};


UA_Boolean running = true;

/* ObjectType nodes */
UA_NodeId TsnSwitchTypeNode;
UA_NodeId EthPortTypeNode;
UA_NodeId PortCounterTypeNode;

/* Object nodes */
UA_NodeId TsnSwitchNode;
UA_NodeId EthPortNode[5];
UA_NodeId EthPortCounterNode[5 * N_TOTAL_COUNTERS];

static void addObjectTypes(UA_Server *server)
{
	UA_ObjectTypeAttributes TsnSwitchTypeAttr;
	UA_ObjectTypeAttributes_init(&TsnSwitchTypeAttr);
	TsnSwitchTypeAttr.displayName = UA_LOCALIZEDTEXT("en_US", "TSNSwitchType");

	UA_Server_addObjectTypeNode(server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE),
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
	/* browseName */            UA_QUALIFIEDNAME(1, "TSNSwitchType"),
	/* attr */                  TsnSwitchTypeAttr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &TsnSwitchTypeNode);

	UA_VariableAttributes TsnSwitchMfgAttr;
	UA_VariableAttributes_init(&TsnSwitchMfgAttr);
	UA_String mfg = UA_STRING("NXP");
	UA_Variant_setScalarCopy(&TsnSwitchMfgAttr.value, &mfg, &UA_TYPES[UA_TYPES_STRING]);
	TsnSwitchMfgAttr.displayName = UA_LOCALIZEDTEXT("en_US", "ManufacturerName");
	UA_NodeId TsnSwitchMfgNode;
	UA_Server_addVariableNode(  server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          TsnSwitchTypeNode,
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
	/* browseName */            UA_QUALIFIEDNAME(1, "ManufacturerName"),
	/* typeDefinition */        UA_NODEID_NULL,
	/* attr */                  TsnSwitchMfgAttr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &TsnSwitchMfgNode);

	/* Make the manufacturer name mandatory */
	UA_Server_addReference(server,
	/* sourceId */         TsnSwitchMfgNode,
	/* refTypeId */        UA_NODEID_NUMERIC(0, UA_NS0ID_HASMODELLINGRULE),
	/* targetId */         UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY),
	/* isForward */        true);

	UA_VariableAttributes TsnSwitchModelAttr;
	UA_VariableAttributes_init(&TsnSwitchModelAttr);
	UA_String model = UA_STRING("SJA1105TEL");
	UA_Variant_setScalarCopy(&TsnSwitchModelAttr.value, &model, &UA_TYPES[UA_TYPES_STRING]);
	TsnSwitchModelAttr.displayName = UA_LOCALIZEDTEXT("en_US", "ModelName");
	UA_NodeId TsnSwitchModelNode;
	UA_Server_addVariableNode(  server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          TsnSwitchTypeNode,
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
	/* browseName */            UA_QUALIFIEDNAME(1, "ModelName"),
	/* typeDefinition */        UA_NODEID_NULL,
	/* attr */                  TsnSwitchModelAttr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &TsnSwitchModelNode);

	/* Make the model name mandatory */
	UA_Server_addReference(server,
	/* sourceId */         TsnSwitchModelNode,
	/* refTypeId */        UA_NODEID_NUMERIC(0, UA_NS0ID_HASMODELLINGRULE),
	/* targetId */         UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY),
	/* isForward */        true);

	UA_ObjectTypeAttributes EthPortTypeAttr;
	UA_ObjectTypeAttributes_init(&EthPortTypeAttr);
	EthPortTypeAttr.displayName = UA_LOCALIZEDTEXT("en_US", "EthPortType");

	UA_Server_addObjectTypeNode(server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE),
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
	/* browseName */            UA_QUALIFIEDNAME(1, "EthPortType"),
	/* attr */                  EthPortTypeAttr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &EthPortTypeNode);
}

static void instantiateSwitchPort(UA_Server *server,
                                  int portIndex,
                                  char *chassisLabel)
{
	char name[256];
	sprintf(name, "RGMII%d", portIndex);
	UA_ObjectAttributes oAttr;
	UA_ObjectAttributes_init(&oAttr);
	oAttr.displayName = UA_LOCALIZEDTEXT("en_US", name);
	UA_Server_addObjectNode(    server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          TsnSwitchNode,
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
	/* browseName */            UA_QUALIFIEDNAME(1, name),
	/* typeDefinition */        EthPortTypeNode,
	/* attr */                  oAttr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &EthPortNode[portIndex]);

	UA_VariableAttributes EthPortChassisLabel;
	UA_VariableAttributes_init(&EthPortChassisLabel);
	UA_String label = UA_STRING(chassisLabel);
	UA_Variant_setScalarCopy(&EthPortChassisLabel.value, &label, &UA_TYPES[UA_TYPES_STRING]);
	EthPortChassisLabel.displayName = UA_LOCALIZEDTEXT("en_US", "Chassis Label");
	UA_Server_addVariableNode(  server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          EthPortNode[portIndex],
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
	/* browseName */            UA_QUALIFIEDNAME(1, "ChassisLabel"),
	/* typeDefinition */        UA_NODEID_NULL,
	/* attr */                  EthPortChassisLabel,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          NULL);

	UA_NodeId CountersNode;
	UA_ObjectAttributes CountersAttr;
	UA_ObjectAttributes_init(&CountersAttr);
	CountersAttr.displayName = UA_LOCALIZEDTEXT("en_US", "Traffic Counters");
	UA_Server_addObjectNode(    server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          EthPortNode[portIndex],
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
	/* browseName */            UA_QUALIFIEDNAME(1, "Counters"),
	/* typeDefinition */        UA_NODEID_NULL,
	/* attr */                  CountersAttr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &CountersNode);

	enum SJA1105PortCounter counter;
	for (counter = 0; counter < N_TOTAL_COUNTERS; counter++) {
		char displayName[256];
		UA_UInt64 value = 0;
		UA_VariableAttributes TrafficCounterAttr;
		UA_VariableAttributes_init(&TrafficCounterAttr);
		sprintf(displayName, "%s ::: %s", chassisLabel, CounterNames[counter]);
		TrafficCounterAttr.displayName = UA_LOCALIZEDTEXT("en_US", displayName);
		TrafficCounterAttr.description = UA_LOCALIZEDTEXT("en_US", CounterDescriptions[counter]);
		UA_Variant_setScalarCopy(&TrafficCounterAttr.value, &value, &UA_TYPES[UA_TYPES_UINT64]);
		UA_Server_addVariableNode(  server,
		/* requestedNewNodeId */    UA_NODEID_NULL,
		/* parentNodeId */          CountersNode,
		/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
		/* browseName */            UA_QUALIFIEDNAME(1, CounterNames[counter]),
		/* typeDefinition */        UA_NODEID_NULL,
		/* attr */                  TrafficCounterAttr,
		/* instantiationCallback */ NULL,
		/* outNewNodeId */          &EthPortCounterNode[N_TOTAL_COUNTERS * portIndex + counter]);
	}
}

static void instantiateSwitch(UA_Server *server)
{
	UA_ObjectAttributes oAttr;
	UA_ObjectAttributes_init(&oAttr);
	oAttr.displayName = UA_LOCALIZEDTEXT("en_US", "SJA1105 TSN Switch");
	UA_Server_addObjectNode(    server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES),
	/* browseName */            UA_QUALIFIEDNAME(1, "SJA1105"),
	/* typeDefinition */        TsnSwitchTypeNode,
	/* attr */                  oAttr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &TsnSwitchNode);

	instantiateSwitchPort(server, 0, "ETH5");
	instantiateSwitchPort(server, 1, "ETH2");
	instantiateSwitchPort(server, 2, "ETH3");
	instantiateSwitchPort(server, 3, "ETH4");
	instantiateSwitchPort(server, 4, "Internal (To LS1021)");
}

static void onStop(int signal)
{
	printf("Received signal %d\n", signal);
	UA_LOG_INFO(UA_Log_Stdout, UA_LOGCATEGORY_SERVER, "received ctrl-c");
	running = false;
}

static uint64_t getSJA1105Counter(struct sja1105_port_status *status,
                                  enum SJA1105PortCounter counter)
{
	switch (counter) {
	case N_N664ERR:      return status->n_n664err;
	case N_VLANERR:      return status->n_vlanerr;
	case N_UNRELEASED:   return status->n_unreleased;
	case N_SIZERR:       return status->n_sizerr;
	case N_CRCERR:       return status->n_crcerr;
	case N_VLNOTFOUND:   return status->n_vlnotfound;
	case N_BEPOLERR:     return status->n_bepolerr;
	case N_POLERR:       return status->n_polerr;
	case N_RXFRM:        return status->n_rxfrm;
	case N_RXBYTE:       return status->n_rxbyte;
	case N_TXFRM:        return status->n_txfrm;
	case N_TXBYTE:       return status->n_txbyte;
	case N_QFULL:        return status->n_qfull;
	case N_PARTDROP:     return status->n_part_drop;
	case N_EGR_DISABLED: return status->n_egr_disabled;
	case N_NOT_REACH:    return status->n_not_reach;
	default:             return -1;
	}
}

static void onRepeatedJob(UA_Server *server, void *data)
{
	struct sja1105_spi_setup *spi_setup;
	struct sja1105_port_status status;

	UA_LOG_INFO(UA_Log_Stdout, UA_LOGCATEGORY_USERLAND,
	            "Reading SJA1105 traffic counters");

	spi_setup = (struct sja1105_spi_setup*) data;

	for (int port = 0; port < 5; port++) {
		if (sja1105_port_status_get(spi_setup, &status, port) < 0) {
			UA_LOG_ERROR(UA_Log_Stdout, UA_LOGCATEGORY_USERLAND,
			             "sja1105_port_status_get failed");
				onStop(-1);
				return;
		}
		enum SJA1105PortCounter counter;
		for (counter = 0; counter < N_TOTAL_COUNTERS; counter++) {
			uint64_t value = getSJA1105Counter(&status, counter);
			UA_Variant variant;
			UA_Variant_setScalarCopy(&variant, &value, &UA_TYPES[UA_TYPES_UINT64]);
			UA_Server_writeValue(server, EthPortCounterNode[N_TOTAL_COUNTERS * port + counter], variant);
		}
	}
}

int main(void)
{
	struct sja1105_spi_setup spi_setup = {
		.device    = "/dev/spidev0.1",
		.mode      = SPI_CPHA,
		.bits      = 8,
		.speed     = 10000000,
		.delay     = 0,
		.cs_change = 0,
		.fd        = -1,
	};

	signal(SIGINT,  onStop);
	signal(SIGTERM, onStop);

	if (sja1105_spi_configure(&spi_setup) < 0) {
		UA_LOG_ERROR(UA_Log_Stdout, UA_LOGCATEGORY_USERLAND,
		             "spi_configure failed");
		return -1;
	}

	UA_ServerConfig config = UA_ServerConfig_standard;
	UA_ServerNetworkLayer nl =
		UA_ServerNetworkLayerTCP(UA_ConnectionConfig_standard, 16664);
	config.networkLayers = &nl;
	config.networkLayersSize = 1;
	UA_Server *server = UA_Server_new(config);

	addObjectTypes(server);
	instantiateSwitch(server);
	/* add a repeated job to the server */
	UA_Job job = {
		.type = UA_JOBTYPE_METHODCALL,
		.job.methodCall = {
			.method = onRepeatedJob,
			.data = &spi_setup
		}
	};
	UA_Server_addRepeatedJob(server, job, 1000, NULL);

	UA_Server_run(server, &running);
	UA_Server_delete(server);
	nl.deleteMembers(&nl);
	return 0;
}
