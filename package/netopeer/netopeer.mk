################################################################################
#
# netopeer-cli/netopeer-server
#
################################################################################

NETOPEER_VERSION = master 
NETOPEER_SITE = https://github.com/CESNET/netopeer.git 
NETOPEER_SITE_METHOD = git
NETOPEER_LICENSE = MIT
NETOPEER_LICENSE_FILES = COPYING
NETOPEER_INSTALL_STAGING = YES
NETOPEER_DEPENDENCIES = pyang libnetconf 
NETOPEER_CONF_ENV += XML2_CONFIG=$(STAGING_DIR)/usr/bin/xml2-config
NETOPEER_CONF_ENV += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"
NETOPEER_CONF_ENV += PYTHON_CONFIG="$(STAGING_DIR)/usr/bin/python-config"
NETOPEER_CONF_ENV += PYTHONPATH=$(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages
NETOPEER_CONF_ENV += PYTHON_LIB_PATH=$(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)

define NETOPEER_BUILD_CMDS
	cd $(@D)/server;$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(NETOPEER_CONF_ENV) \
	    ./configure  --prefix=/usr/local/ \
	    --host=arm-buildroot-linux-gnueabihf \
	    --build=x86_64-pc-linux-gnu 
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_MAKE_OPTS) -C $(@D)/server
endef

define NETOPEER_INSTALL_TARGET_CMDS
	cd $(@D)/server;$(TARGET_MAKE_ENV) $(MAKE) DESTDIR=$(TARGET_DIR) install

endef

define NETOPEER_INSTALL_DATASTORE
	$(INSTALL) -D -m 0755 package/netopeer/datastore.xml $(TARGET_DIR)/usr/local/etc/netopeer/cfgnetopeer/
endef

define NETOPEER_INSTALL_NETOPEER_MANAGER_HOST
	$(INSTALL) -D -m 0755 package/netopeer/netopeer-manager.host $(HOST_DIR)/usr/bin/
endef

NETOPEER_POST_INSTALL_TARGET_HOOKS +=NETOPEER_INSTALL_DATASTORE
NETOPEER_POST_INSTALL_TARGET_HOOKS +=NETOPEER_INSTALL_NETOPEER_MANAGER_HOST

$(eval $(generic-package))
