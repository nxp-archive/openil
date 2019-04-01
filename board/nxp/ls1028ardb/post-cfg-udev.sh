#!/usr/bin/env bash

main()
{
	cp board/nxp/ls1028ardb/ls1028-10-network.rules ${TARGET_DIR}/etc/udev/rules.d/10-network.rules

	exit $?
}

main $@
