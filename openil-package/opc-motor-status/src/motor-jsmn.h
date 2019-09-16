#pragma once

struct motor_coords {
	float position;
	float rotation;
};

struct motor_msg {
	char board_id[100];
	struct motor_coords left;
	struct motor_coords right;
};

int json_msg_parse(struct motor_msg *msg, const char *buf);
