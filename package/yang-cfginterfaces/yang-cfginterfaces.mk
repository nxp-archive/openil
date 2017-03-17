################################################################################
#
# yang cfginterfaces 
#
################################################################################
YANG_CFGINTERFACES_VERSION = $(NETOPEER_VERSION)
YANG_CFGINTERFACES_SITE = $(BUILD_DIR)/netopeer-$(NETOPEER_VERSION)/transAPI/cfginterfaces
YANG_CFGINTERFACES_SITE_METHOD = local
YANG_CFGINTERFACES_LICENSE = MIT
YANG_CFGINTERFACES_LICENSE_FILES = COPYING
YANG_CFGINTERFACES_DEPENDENCIES = libxml2 pyang libnetconf
YANG_CFGINTERFACES_CONF_ENV += CFLAGS="-I$(STAGING_DIR)/usr/include/libxml2 -pthread"
YANG_CFGINTERFACES_CONF_ENV += LIBS="-L$(STAGING_DIR)/usr/lib"
YANG_CFGINTERFACES_CONF_ENV += XML2_CONFIG=$(STAGING_DIR)/usr/bin/xml2-config
YANG_CFGINTERFACES_CONF_ENV += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"
YANG_CFGINTERFACES_CONF_ENV += PYTHON_CONFIG="$(STAGING_DIR)/usr/bin/python-config"
YANG_CFGINTERFACES_CONF_ENV += ac_cv_path_NETOPEER_MANAGER="$(HOST_DIR)/usr/bin/netopeer-manager.host"

define YANG_CFGINTERFACES_CONFIGURE_CMDS
	cd $(@D);$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(YANG_CFGINTERFACES_CONF_ENV) \
	    ./configure  --prefix=/usr/local/ \
	    --host=arm-buildroot-linux-gnueabihf \
	    --build=x86_64-pc-linux-gnu 
endef

$(eval $(autotools-package))
