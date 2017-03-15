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
#HOST_NETOPEER_DEPENDENCIES = host-pkgconf
#NETOPEER_CONF_ENV +=PKG_CONFIG
#define NETOPEER_CONFIGURE_CMDS
NETOPEER_CONF_ENV += XML2_CONFIG=$(STAGING_DIR)/usr/bin/xml2-config
NETOPEER_CONF_ENV += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"
NETOPEER_CONF_ENV += PYTHON_CONFIG="$(STAGING_DIR)/usr/bin/python-config"
NETOPEER_CONF_ENV += PYTHONPATH=$(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages
NETOPEER_CONF_ENV += PYTHON_LIB_PATH=$(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)
#PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)"
#PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)"
#PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH)"
#endef
#define NETOPEER_CONFIGURE_CMDS
#	$(@D)=$(@D)/server
#	cd $(@D)
#endef
define NETOPEER_BUILD_CMDS
	cd $(@D)/server;$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(NETOPEER_CONF_ENV) \
	    ./configure  --prefix=/usr/local/ \
	    --host=arm-buildroot-linux-gnueabihf \
	    --build=x86_64-pc-linux-gnu 
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_MAKE_OPTS) -C $(@D)/server
#	make
endef

define NETOPEER_INSTALL_TARGET_CMDS
	cd $(@D)/server;$(TARGET_MAKE_ENV) $(MAKE) DESTDIR=$(TARGET_DIR) install
#	$(TARGET_MAKE_ENV) $(MAKE) PREFIX="$(TARGET_DIR)/usr" -C $(@D) install
endef
#$(eval $(autotools-package))
$(eval $(generic-package))
