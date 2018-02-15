#pragma once

void listener_close(int sockfd);
int listener_setup(int port);
int listener_poll(int sockfd, char *buf, int max_bytes, char *sender_addr);
