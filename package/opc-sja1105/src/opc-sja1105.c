/* This work is licensed under a Creative Commons CCZero 1.0 Universal License.
 * See http://creativecommons.org/publicdomain/zero/1.0/ for more information. */

#include <stdio.h>
#include <signal.h>
#include <open62541.h>
#include <sja1105/status.h>

int SJA1105_VERBOSE_CONDITION = 1;
int SJA1105_DEBUG_CONDITION = 1;

struct sja1105_spi_setup spi_setup = {
	.device    = "/dev/spidev0.1",
	.mode      = SPI_CPHA,
	.bits      = 8,
	.speed     = 10000000,
	.delay     = 0,
	.cs_change = 0,
	.fd        = -1,
};

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

/*
 *
struct sja1105_port_status {
	uint64_t n_runt;
	uint64_t n_soferr;
	uint64_t n_alignerr;
	uint64_t n_miierr;
	uint64_t typeerr;
	uint64_t sizeerr;
	uint64_t tctimeout;
	uint64_t priorerr;
	uint64_t nomaster;
	uint64_t memov;
	uint64_t memerr;
	uint64_t invtyp;
	uint64_t intcyov;
	uint64_t domerr;
	uint64_t pcfbagdrop;
	uint64_t spcprior;
	uint64_t ageprior;
	uint64_t portdrop;
	uint64_t lendrop;
	uint64_t bagdrop;
	uint64_t policeerr;
	uint64_t drpnona664err;
	uint64_t spcerr;
	uint64_t agedrp;
	uint64_t n_n664err;
	uint64_t n_vlanerr;
	uint64_t n_unreleased;
	uint64_t n_sizerr;
	uint64_t n_crcerr;
	uint64_t n_vlnotfound;
	uint64_t n_bepolerr;
	uint64_t n_polerr;
	uint64_t n_rxfrmsh;
	uint64_t n_rxfrm;
	uint64_t n_rxbytesh;
	uint64_t n_rxbyte;
	uint64_t n_txfrmsh;
	uint64_t n_txfrm;
	uint64_t n_txbytesh;
	uint64_t n_txbyte;
	uint64_t n_qfull;
	uint64_t n_part_drop;
	uint64_t n_egr_disabled;
	uint64_t n_not_reach;
};
*/

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
                                  int index,
                                  char *name,
                                  char *chassisLabel)
{
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
	/* outNewNodeId */          &EthPortNode[index]);

	UA_VariableAttributes EthPortChassisLabel;
	UA_VariableAttributes_init(&EthPortChassisLabel);
	UA_String label = UA_STRING(chassisLabel);
	UA_Variant_setScalarCopy(&EthPortChassisLabel.value, &label, &UA_TYPES[UA_TYPES_STRING]);
	EthPortChassisLabel.displayName = UA_LOCALIZEDTEXT("en_US", "Chassis Label");
	UA_Server_addVariableNode(  server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          EthPortNode[index],
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
	/* parentNodeId */          EthPortNode[index],
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
	/* browseName */            UA_QUALIFIEDNAME(1, "Counters"),
	/* typeDefinition */        UA_NODEID_NULL,
	/* attr */                  CountersAttr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &CountersNode);

	for (int i = 0; i < N_TOTAL_COUNTERS; i++) {
		UA_UInt64 value = 0;
		UA_VariableAttributes TrafficCounterAttr;
		UA_VariableAttributes_init(&TrafficCounterAttr);
		TrafficCounterAttr.displayName = UA_LOCALIZEDTEXT("en_US", CounterNames[i]);
		TrafficCounterAttr.description = UA_LOCALIZEDTEXT("en_US", CounterDescriptions[i]);
		UA_Variant_setScalarCopy(&TrafficCounterAttr.value, &value, &UA_TYPES[UA_TYPES_UINT64]);
		UA_Server_addVariableNode(  server,
		/* requestedNewNodeId */    UA_NODEID_NULL,
		/* parentNodeId */          CountersNode,
		/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
		/* browseName */            UA_QUALIFIEDNAME(1, CounterNames[i]),
		/* typeDefinition */        UA_NODEID_NULL,
		/* attr */                  TrafficCounterAttr,
		/* instantiationCallback */ NULL,
		/* outNewNodeId */          &EthPortCounterNode[index * 5 + i]);
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

	instantiateSwitchPort(server, 0, "RGMII0", "ETH5");
	instantiateSwitchPort(server, 1, "RGMII1", "ETH2");
	instantiateSwitchPort(server, 2, "RGMII2", "ETH3");
	instantiateSwitchPort(server, 3, "RGMII3", "ETH4");
	instantiateSwitchPort(server, 4, "RGMII4", "Internal (To LS1021)");
}

static void onStop(int signal)
{
	printf("Received signal %d\n", signal);
	UA_LOG_INFO(UA_Log_Stdout, UA_LOGCATEGORY_SERVER, "received ctrl-c");
	running = false;
}

static void testCallback(UA_Server *server, void *data)
{
	UA_LOG_INFO(UA_Log_Stdout, UA_LOGCATEGORY_USERLAND, "testcallback");
}

int main(void)
{
	signal(SIGINT,  onStop);
	signal(SIGTERM, onStop);

	UA_ServerConfig config = UA_ServerConfig_standard;
	UA_ServerNetworkLayer nl =
		UA_ServerNetworkLayerTCP(UA_ConnectionConfig_standard, 16664);
	config.networkLayers = &nl;
	config.networkLayersSize = 1;
	UA_Server *server = UA_Server_new(config);

	addObjectTypes(server);
	instantiateSwitch(server);
	/* add a repeated job to the server */
	UA_Job job = {.type = UA_JOBTYPE_METHODCALL,
	.job.methodCall = {.method = testCallback, .data = NULL} };
	UA_Server_addRepeatedJob(server, job, 2000, NULL); /* call every 2 sec */

	UA_Server_run(server, &running);
	UA_Server_delete(server);
	nl.deleteMembers(&nl);
	return 0;
}
