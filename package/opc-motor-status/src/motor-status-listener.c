/*
** listener.c -- a datagram sockets "server" demo
** Borrowed from: http://beej.us/guide/bgnet/html/single/bgnet.html
*/

/* Courtesy of:
 * https://stackoverflow.com/questions/37541985/storage-size-of-addrinfo-isnt-known
 */
#define _POSIX_C_SOURCE 200112L

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

/* get sockaddr, IPv4 or IPv6: */
static void *get_in_addr(struct sockaddr *sa)
{
	if (sa->sa_family == AF_INET) {
		return &(((struct sockaddr_in*)sa)->sin_addr);
	}
	return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int listener_poll(int sockfd, char *buf, int max_bytes, char *sender_addr)
{
	socklen_t addr_len;
	struct sockaddr_storage their_addr;
	int rc;

	addr_len = sizeof their_addr;
	rc = recvfrom(sockfd, buf, max_bytes, MSG_DONTWAIT,
	             (struct sockaddr*) &their_addr, &addr_len);
	if (rc < 0) {
		if (errno == EAGAIN || errno == EWOULDBLOCK) {
			return 0;
		} else {
			perror("recvfrom");
			return -errno;
		}
	}
	/* rc contains number of read bytes */
	buf[rc] = '\0';
	if (sender_addr != NULL) {
		inet_ntop(their_addr.ss_family,
		          get_in_addr((struct sockaddr*) &their_addr),
		                      sender_addr, INET6_ADDRSTRLEN);
	}
	return rc;
}

void listener_close(int sockfd)
{
	close(sockfd);
}

int listener_setup(int port)
{
	struct addrinfo hints, *servinfo, *p;
	char port_str[7];
	int sockfd;
	int rc;

	memset(&hints, 0, sizeof hints);
	/* set to AF_INET to force IPv4 */
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_DGRAM;
	/* use my IP */
	hints.ai_flags = AI_PASSIVE;

	snprintf(port_str, 6, "%d", port);
	rc = getaddrinfo(NULL, port_str, &hints, &servinfo);
	if (rc != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rc));
		return -1;
	}

	// loop through all the results and bind to the first we can
	for (p = servinfo; p != NULL; p = p->ai_next) {
		sockfd = socket(p->ai_family, p->ai_socktype,
		                p->ai_protocol);
		if (sockfd == -1) {
			perror("listener: socket");
			continue;
		}
		if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
			close(sockfd);
			perror("listener: bind");
			continue;
		}
		break;
	}
	if (p == NULL) {
		fprintf(stderr, "listener: failed to bind socket\n");
		return -2;
	}
	freeaddrinfo(servinfo);
	return sockfd;
}
