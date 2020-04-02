################################################################################
#
# qoriq-netopeer2-cli
#
################################################################################

QORIQ_NETOPEER2_CLI_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_NETOPEER2_CLI_VERSION))
QORIQ_NETOPEER2_CLI_SITE = $(call github,CESNET,Netopeer2,v$(QORIQ_NETOPEER2_CLI_VERSION))
QORIQ_NETOPEER2_CLI_SUBDIR = cli
QORIQ_NETOPEER2_CLI_INSTALL_STAGING = NO
QORIQ_NETOPEER2_CLI_LICENSE = BSD-3c
QORIQ_NETOPEER2_CLI_LICENSE_FILES = LICENSE
QORIQ_NETOPEER2_CLI_DEPENDENCIES = libyang libnetconf2
QORIQ_NETOPEER2_CLI_IMAKE_ENV = LD_LIBRARY_PATH+=$(HOST_DIR)/usr/lib:$(HOST_DIR)/lib

$(eval $(cmake-package))
