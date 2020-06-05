################################################################################
#
# qoriq-netopeer2-server
#
################################################################################

QORIQ_NETOPEER2_SERVER_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_NETOPEER2_SERVER_VERSION))
QORIQ_NETOPEER2_SERVER_SITE = $(call github,CESNET,Netopeer2,v$(QORIQ_NETOPEER2_SERVER_VERSION))
QORIQ_NETOPEER2_SERVER_SUBDIR = server
QORIQ_NETOPEER2_SERVER_INSTALL_STAGING = NO
QORIQ_NETOPEER2_SERVER_LICENSE = BSD-3c
QORIQ_NETOPEER2_SERVER_LICENSE_FILES = LICENSE
QORIQ_NETOPEER2_SERVER_DEPENDENCIES = libnetconf2 sysrepo libyang qoriq-netopeer2-keystored

define QORIQ_NETOPEER2_SERVER_INSTALL_DAEMON_SCRIPT
	$(INSTALL) -D -m 0751 package/nxp/qoriq-netopeer2-server/S91netopeer2-server \
		$(TARGET_DIR)/etc/init.d/
endef

define QORIQ_NETOPEER2_SERVER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 package/nxp/qoriq-netopeer2-server/netopeer2-server.service \
		$(TARGET_DIR)/usr/lib/systemd/system/netopeer2-server.service
endef

define  QORIQ_NETOPEER2_SERVER_CREATE_SERVICE_LINK
       cd $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/ && rm -f netopeer2-server.service && ln -sf /usr/lib/systemd/system/netopeer2-server.service netopeer2-server.service
endef

QORIQ_NETOPEER2_SERVER_POST_INSTALL_TARGET_HOOKS = QORIQ_NETOPEER2_SERVER_INSTALL_DAEMON_SCRIPT

ifneq ($(BR2_ROOTFS_SKELETON_CUSTOM_SITE),)
QORIQ_NETOPEER2_SERVER_POST_INSTALL_TARGET_HOOKS += QORIQ_NETOPEER2_SERVER_INSTALL_INIT_SYSTEMD
QORIQ_NETOPEER2_SERVER_POST_INSTALL_TARGET_HOOKS += QORIQ_NETOPEER2_SERVER_CREATE_SERVICE_LINK
endif

# prevent an attempted chown to root:root
QORIQ_NETOPEER2_SERVER_CONF_OPTS += -DSYSREPOCTL_ROOT_PERMS="-p 666"
QORIQ_NETOPEER2_SERVER_MAKE_ENV = LD_LIBRARY_PATH+=$(HOST_DIR)/usr/lib:$(HOST_DIR)/lib
# the .pc file is for the target, and therefore not consulted during the build
QORIQ_NETOPEER2_SERVER_CONF_OPTS += -DKEYSTORED_KEYS_DIR=/etc/keystored/keys

$(eval $(cmake-package))
