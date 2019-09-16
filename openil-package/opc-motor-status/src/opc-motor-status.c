/* This work is licensed under a Creative Commons CCZero 1.0 Universal License.
 * See http://creativecommons.org/publicdomain/zero/1.0/ for more information. */

#include <stdio.h>
#include <signal.h>
#include <open62541.h>
#include "motor-jsmn.h"
#include "motor-status-listener.h"
/* For INET6_ADDRSTRLEN */
#include <arpa/inet.h>

#define OPC_UA_SERVER_PORT         16664
#define MOTOR_STATUS_LISTENER_PORT 12345

int motor_listener_sockfd;
UA_Boolean running = true;

struct motor_coords_ua {
	UA_NodeId nodeid;
	UA_NodeId position_nodeid;
	UA_NodeId rotation_nodeid;
	float position;
	float rotation;
};

struct motor_board_ua {
	UA_NodeId nodeid;
	char board_id[100];
	struct motor_coords_ua left;
	struct motor_coords_ua right;
};

#define MOTOR_BOARDS_COUNT 100
struct motor_board_ua motor_boards[MOTOR_BOARDS_COUNT];
int motor_boards_allocated[MOTOR_BOARDS_COUNT];

struct object_types {
	UA_NodeId motor_board_type_node;
	UA_NodeId motor_type_node;
};
struct object_types g_types;

/* ==========================
 * OPC UA node creation stuff
 * ==========================
 **/

/* This function populates the g_types global structure with 2
 * nodes representing custom object types
 **/
static void
object_types_create(UA_Server *server, struct object_types *types)
{
	/* motor_board_type_attr */
	UA_ObjectTypeAttributes motor_board_type_attr;
	UA_ObjectTypeAttributes_init(&motor_board_type_attr);
	motor_board_type_attr.displayName = UA_LOCALIZEDTEXT("en_US", "MotorControlBoardType");

	UA_Server_addObjectTypeNode(server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE),
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
	/* browseName */            UA_QUALIFIEDNAME(1, "MotorControlBoardType"),
	/* attr */                  motor_board_type_attr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &types->motor_board_type_node);

	/* motor_board_mfg_attr */
	UA_VariableAttributes motor_board_mfg_attr;
	UA_VariableAttributes_init(&motor_board_mfg_attr);
	UA_String mfg = UA_STRING("NXP");
	UA_Variant_setScalarCopy(&motor_board_mfg_attr.value, &mfg, &UA_TYPES[UA_TYPES_STRING]);
	motor_board_mfg_attr.displayName = UA_LOCALIZEDTEXT("en_US", "ManufacturerName");
	UA_NodeId motor_board_mfg_node;
	UA_Server_addVariableNode(  server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          types->motor_board_type_node,
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
	/* browseName */            UA_QUALIFIEDNAME(1, "ManufacturerName"),
	/* typeDefinition */        UA_NODEID_NULL,
	/* attr */                  motor_board_mfg_attr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &motor_board_mfg_node);

	/* Make the manufacturer name mandatory */
	UA_Server_addReference(server,
	/* sourceId */         motor_board_mfg_node,
	/* refTypeId */        UA_NODEID_NUMERIC(0, UA_NS0ID_HASMODELLINGRULE),
	/* targetId */         UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY),
	/* isForward */        true);

	UA_VariableAttributes motor_board_model_attr;
	UA_VariableAttributes_init(&motor_board_model_attr);
	UA_String model = UA_STRING("i.MX RT-1050");
	UA_Variant_setScalarCopy(&motor_board_model_attr.value, &model, &UA_TYPES[UA_TYPES_STRING]);
	motor_board_model_attr.displayName = UA_LOCALIZEDTEXT("en_US", "ModelName");
	UA_NodeId motor_board_model_node;
	UA_Server_addVariableNode(  server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          types->motor_board_type_node,
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
	/* browseName */            UA_QUALIFIEDNAME(1, "ModelName"),
	/* typeDefinition */        UA_NODEID_NULL,
	/* attr */                  motor_board_model_attr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &motor_board_model_node);

	/* Make the model name mandatory */
	UA_Server_addReference(server,
	/* sourceId */         motor_board_model_node,
	/* refTypeId */        UA_NODEID_NUMERIC(0, UA_NS0ID_HASMODELLINGRULE),
	/* targetId */         UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY),
	/* isForward */        true);

	UA_ObjectTypeAttributes motor_type_attr;
	UA_ObjectTypeAttributes_init(&motor_type_attr);
	motor_type_attr.displayName = UA_LOCALIZEDTEXT("en_US", "MotorType");

	UA_Server_addObjectTypeNode(server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE),
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
	/* browseName */            UA_QUALIFIEDNAME(1, "MotorType"),
	/* attr */                  motor_type_attr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &types->motor_type_node);
}

static void
instantiate_motor_opc_property_nodes(UA_Server *server,
                                     struct motor_board_ua *brd,
                                     int left_right,
                                     int position_rotation)
{
	struct motor_coords_ua *motor_ptr =
	       (left_right == 0) ? &brd->left : &brd->right;
	char display_name[256];
	char browse_name[256];
	UA_Float default_value = 0;
	UA_VariableAttributes property_attr;
	UA_VariableAttributes_init(&property_attr);
	sprintf(display_name, "%s motor %s",
	       (left_right == 0) ? "Left" : "Right",
	       (position_rotation == 0) ? "position" : "rotation");
	sprintf(browse_name, "%s", (position_rotation == 0) ? "Position" : "Rotation");
	property_attr.displayName = UA_LOCALIZEDTEXT("en_US", display_name);
	property_attr.description = UA_LOCALIZEDTEXT("en_US", display_name);
	UA_Variant_setScalarCopy(&property_attr.value, &default_value, &UA_TYPES[UA_TYPES_FLOAT]);
	UA_Server_addVariableNode(  server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          motor_ptr->nodeid,
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
	/* browseName */            UA_QUALIFIEDNAME(1, browse_name),
	/* typeDefinition */        UA_NODEID_NULL,
	/* attr */                  property_attr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          (position_rotation == 0) ?
	                            &motor_ptr->position_nodeid :
	                            &motor_ptr->rotation_nodeid);
}

static void
instantiate_motor_opc_nodes(UA_Server *server,
                            struct motor_board_ua *brd,
                            int left_right)
{
	UA_ObjectAttributes motor_node_attr;
	UA_ObjectAttributes_init(&motor_node_attr);
	motor_node_attr.displayName = UA_LOCALIZEDTEXT("en_US",
	           (left_right == 0) ? "Left motor" : "Right motor");
	UA_Server_addObjectNode(    server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          brd->nodeid,
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
	/* browseName */            UA_QUALIFIEDNAME(1,
	                            (left_right == 0) ? "LeftMotor" : "RightMotor"),
	/* typeDefinition */        g_types.motor_type_node,
	/* attr */                  motor_node_attr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          (left_right == 0) ? &brd->left.nodeid : &brd->right.nodeid);

	instantiate_motor_opc_property_nodes(server, brd, left_right, 0 /* position node */);
	instantiate_motor_opc_property_nodes(server, brd, left_right, 1 /* rotation node */);
}

static void instantiate_board_opc_nodes(UA_Server *server, struct motor_board_ua *new_brd)
{
	/* Create board node */
	UA_ObjectAttributes board_node_attr;
	UA_ObjectAttributes_init(&board_node_attr);
	board_node_attr.displayName = UA_LOCALIZEDTEXT("en_US", new_brd->board_id);
	UA_Server_addObjectNode(    server,
	/* requestedNewNodeId */    UA_NODEID_NULL,
	/* parentNodeId */          UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
	/* referenceTypeId */       UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES),
	/* browseName */            UA_QUALIFIEDNAME(1, new_brd->board_id),
	/* typeDefinition */        g_types.motor_board_type_node,
	/* attr */                  board_node_attr,
	/* instantiationCallback */ NULL,
	/* outNewNodeId */          &new_brd->nodeid);

	instantiate_motor_opc_nodes(server, new_brd, 0 /* left motor node */);
	instantiate_motor_opc_nodes(server, new_brd, 1 /* right motor node */);
}

static void
opc_update_float_nodeid(UA_Server *server, UA_NodeId nodeid, float val)
{
	UA_Variant variant;
	UA_Variant_setScalarCopy(&variant, &val, &UA_TYPES[UA_TYPES_FLOAT]);
	UA_Server_writeValue(server, nodeid, variant);
}

/* ==========================
 * Array bookkeeping stuff
 * ==========================
 **/

/* Returns the index of a newly allocated struct in the
 * motor_boards array if successful, or -1 on failure.
 * Populates the OPC UA server with nodes and keeps the
 * node id's in its structure.
 */
static int motor_board_create(UA_Server *server, const struct motor_msg *msg)
{
	struct motor_board_ua *new_brd;
	int i;

	for (i = 0; i < MOTOR_BOARDS_COUNT; i++) {
		if (!motor_boards_allocated[i]) break;
	}
	if (i == MOTOR_BOARDS_COUNT) {
		/* No space for new board */
		return -1;
	}

	new_brd = motor_boards + i;
	memset(new_brd, 0, sizeof(struct motor_board_ua));
	strcpy(new_brd->board_id, msg->board_id);
	new_brd->left.position  = msg->left.position;
	new_brd->left.rotation  = msg->left.rotation;
	new_brd->right.position = msg->right.position;
	new_brd->right.rotation = msg->right.rotation;
	motor_boards_allocated[i] = 1;

	instantiate_board_opc_nodes(server, new_brd);
	return i;
}

/* Deletes element i from the motor_boards array */
static void motor_board_delete(int i)
{
	motor_boards_allocated[i] = 0;
}

static void
motor_board_update(UA_Server *server, int i, const struct motor_msg *msg)
{
	struct motor_board_ua *brd = motor_boards + i;

	brd->left.position = msg->left.position;
	brd->left.rotation = msg->left.rotation;
	brd->right.position = msg->right.position;
	brd->right.rotation = msg->right.rotation;
	opc_update_float_nodeid(server, brd->left.position_nodeid, brd->left.position);
	opc_update_float_nodeid(server, brd->left.rotation_nodeid, brd->left.rotation);
	opc_update_float_nodeid(server, brd->right.position_nodeid, brd->right.position);
	opc_update_float_nodeid(server, brd->right.rotation_nodeid, brd->right.rotation);
}

static int motor_board_get(char *board_id)
{
	int i;
	for (i = 0; i < MOTOR_BOARDS_COUNT; i++) {
		if (motor_boards_allocated[i] && strcmp(board_id,
		    motor_boards[i].board_id) == 0) {
			return i;
		}
	}
	return -1;
}

/* ==========================
 * OPC UA server callback stuff
 * ==========================
 **/

static void on_stop(int signal)
{
	printf("Received signal %d\n", signal);
	UA_LOG_INFO(UA_Log_Stdout, UA_LOGCATEGORY_SERVER, "received ctrl-c");
	running = false;
}

static void motor_msg_show(struct motor_msg *msg)
{
	fprintf(stdout, "Message from board id %s:\n", msg->board_id);
	fprintf(stdout, "Left motor: position %.3f, rotation %.3f\n",
	        msg->left.position, msg->left.rotation);
	fprintf(stdout, "Right motor: position %.3f, rotation %.3f\n",
	        msg->right.position, msg->right.rotation);
}

static void on_repeated_job(UA_Server *server, void *data)
{
	/* Same as motor_listener_sockfd */
	int sockfd = *(int*) data;
	char buf[1024];
	struct motor_msg msg;
	char sender_addr[INET6_ADDRSTRLEN];
	int rc;
	int index;

	/* Will break the loop as soon as there is no message left
	 * in the socket. Used to drain all enqueued messages at once
	 * (in the same on_repeated_job call).
	 */
	while (1) {
		rc = listener_poll(sockfd, buf, 1023, sender_addr);
		if (rc < 0) {
			UA_LOG_ERROR(UA_Log_Stdout, UA_LOGCATEGORY_SERVER,
			             "listener_poll returned %d", rc);
			running = false;
			return;
		}
		if (rc == 0) {
			break;
		}
		memset(&msg, 0, sizeof(msg));
		if (json_msg_parse(&msg, buf) < 0) {
			UA_LOG_ERROR(UA_Log_Stdout, UA_LOGCATEGORY_SERVER,
			             "malformed message received from %s: \"%s\"\n",
			             sender_addr, buf);
			continue;
		}
		motor_msg_show(&msg);
		index = motor_board_get(msg.board_id);
		if (index < 0) {
			index = motor_board_create(server, &msg);
			if (index < 0) {
				UA_LOG_ERROR(UA_Log_Stdout, UA_LOGCATEGORY_SERVER,
				             "cannot allocate space for new board \"%s\"\n",
				             msg.board_id);
				return;
			}
		}
		motor_board_update(server, index, &msg);
	}
}

int main(void)
{
	signal(SIGINT,  on_stop);
	signal(SIGTERM, on_stop);

	motor_listener_sockfd = listener_setup(MOTOR_STATUS_LISTENER_PORT);
	if (motor_listener_sockfd < 0) {
		UA_LOG_ERROR(UA_Log_Stdout, UA_LOGCATEGORY_SERVER,
		             "could not bind motor listener to port %d",
		             MOTOR_STATUS_LISTENER_PORT);
		return 1;
	}

	UA_ServerConfig config = UA_ServerConfig_standard;
	UA_ServerNetworkLayer nl =
		UA_ServerNetworkLayerTCP(UA_ConnectionConfig_standard, OPC_UA_SERVER_PORT);
	config.networkLayers = &nl;
	config.networkLayersSize = 1;
	UA_Server *server = UA_Server_new(config);

	object_types_create(server, &g_types);
	/* add a repeated job to the server */
	UA_Job job = {
		.type = UA_JOBTYPE_METHODCALL,
		.job.methodCall = {
			.method = on_repeated_job,
			.data = &motor_listener_sockfd
		}
	};
	UA_Server_addRepeatedJob(server, job, 100, NULL);

	UA_Server_run(server, &running);
	UA_Server_delete(server);
	listener_close(motor_listener_sockfd);
	nl.deleteMembers(&nl);
	return 0;
}
