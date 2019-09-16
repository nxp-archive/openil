#!/bin/bash
# First board: should get created
./motor-status-talker 192.168.0.2 '{ "board_id": "first board", "motors": [ { "motor_id": "left", "position": 1234, "rotation": 4321 }, { "motor_id": "right", "position": 5678, "rotation": 8765 } ] }'
# Second board: should get created
./motor-status-talker 192.168.0.2 '{ "board_id": "second board", "motors": [ { "motor_id": "left", "position": 10, "rotation": 20 }, { "motor_id": "right", "position": 30.1, "rotation": 40.2 } ] }'
# Malformed input: should ignore it
./motor-status-talker 192.168.0.2 'invalid { "board_id2": "hello", "motors": [ { "motor_id": "left", "position": 1234, "rotation": 4321 }, { "motor_id": "right", "position": 5678, "rotation": 8765 } ] }'
# Second board: should update the node with the new values
./motor-status-talker 192.168.0.2 '{ "board_id": "second board", "motors": [ { "motor_id": "left", "position": 11, "rotation": 21 }, { "motor_id": "right", "position": 30.2, "rotation": 40.3 } ] }'
