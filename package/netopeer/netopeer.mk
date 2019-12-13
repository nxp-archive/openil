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
NETOPEER_DEPENDENCIES = pyang libnetconf openssh
NETOPEER_CONF_ENV += XML2_CONFIG=$(STAGING_DIR)/usr/bin/xml2-config
NETOPEER_CONF_ENV += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"
NETOPEER_CONF_ENV += PYTHON_CONFIG="$(STAGING_DIR)/usr/bin/python-config"

LXML_MODULE_DIR = lxml-$(PYTHON_LXML_VERSION)-py2.7-linux-x86_64.egg
NETOPEER_CONF_ENV += PYTHONPATH=$(HOST_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/$(LXML_MODULE_DIR)
NETOPEER_CONF_ENV += PYTHON_LIB_PATH=$(HOST_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)

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
	$(INSTALL) -D -m 0755 package/netopeer/S90netconf $(TARGET_DIR)/etc/init.d/
endef
# edit and install environment init script by build type
ifeq ($(BR2_ROOTFS_SKELETON_CUSTOM),y)
define NETOPEER_INSTALL_NETOPEER_SET_ENV
	sed -i '1d' $(TARGET_DIR)/usr/local/bin/netopeer-configurator
	sed -i '1i\#!\/usr\/bin\/python' $(TARGET_DIR)/usr/local/bin/netopeer-configurator
	rm -f $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
	$(INSTALL) -D -m 0755 package/netopeer/setenvfornetopeer.sh $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
	sed -i "/^#2/ a\export PYTHONPATH=/usr/local/lib/python$(PYTHON_VERSION_MAJOR)/site-packages" $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
endef
else
define NETOPEER_INSTALL_NETOPEER_SET_ENV
	sed -i '1d' $(TARGET_DIR)/usr/local/bin/netopeer-configurator
	sed -i '1i\#!\/usr\/bin\/python' $(TARGET_DIR)/usr/local/bin/netopeer-configurator
	rm -f $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
	$(INSTALL) -D -m 0755 package/netopeer/setenvfornetopeer.sh $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
	sed -i '/^#1/ a\export PATH=$$PATH:/usr/local/bin' $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
	sed -i "/^#2/ a\export PYTHONPATH=/usr/local/lib/python$(PYTHON_VERSION_MAJOR)/site-packages" $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
endef
endif
NETOPEER_POST_INSTALL_TARGET_HOOKS +=NETOPEER_INSTALL_DATASTORE
NETOPEER_POST_INSTALL_TARGET_HOOKS +=NETOPEER_INSTALL_NETOPEER_MANAGER_HOST
NETOPEER_POST_INSTALL_TARGET_HOOKS +=NETOPEER_INSTALL_NETOPEER_SET_ENV

$(eval $(generic-package))
