################################################################################
#
# yang module sja1105 
#
################################################################################
YANG_SJA1105_VERSION = $(NETOPEER_VERSION)
YANG_SJA1105_SITE = $(BUILD_DIR)/netopeer-$(NETOPEER_VERSION)/transAPI/sja1105
YANG_SJA1105_SITE_METHOD = local
YANG_SJA1105_LICENSE = MIT
YANG_SJA1105_LICENSE_FILES = COPYING
YANG_SJA1105_DEPENDENCIES = libxml2 pyang libnetconf
YANG_SJA1105_CONF_ENV += CFLAGS="-I$(STAGING_DIR)/usr/include/libxml2 -pthread"
YANG_SJA1105_CONF_ENV += LIBS="-L$(STAGING_DIR)/usr/lib"
YANG_SJA1105_CONF_ENV += XML2_CONFIG=$(STAGING_DIR)/usr/bin/xml2-config
YANG_SJA1105_CONF_ENV += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"
YANG_SJA1105_CONF_ENV += PYTHON_CONFIG="$(STAGING_DIR)/usr/bin/python-config"
YANG_SJA1105_CONF_ENV += ac_cv_path_NETOPEER_MANAGER="$(HOST_DIR)/usr/bin/netopeer-manager.host"
#define YANG_SJA1105_INSTALL_INITCMD
#	$(INSTALL) -D -m 0755 $(@D)/SJA1105-init $(TARGET_DIR)/usr/bin/
#endef

#YANG_SJA1105_POST_INSTALL_TARGET_HOOKS +=YANG_CFGINTERFACES_INSTALL_INITCMD

define YANG_SJA1105_CONFIGURE_CMDS
	cd $(@D); $(HOST_DIR)/usr/bin/autoreconf --force --install; \
	$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(YANG_SJA1105_CONF_ENV) \
	    ./configure  --prefix=/usr/local/ \
	    --host=arm-buildroot-linux-gnueabihf \
	    --build=x86_64-pc-linux-gnu
endef

define YANG_SJA1105_LNCTOOL_CREATE_FILES
	cd $(@D); \
	$(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/lnctool --model `pwd`/sja1105.yang --search-path `pwd` --output-dir `pwd` validation;
endef

YANG_SJA1105_POST_BUILD_HOOKS +=YANG_SJA1105_LNCTOOL_CREATE_FILES

$(eval $(autotools-package))
