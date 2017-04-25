################################################################################
#
# yang module sja1105 
#
################################################################################
YANG_SJA1105_VERSION = 0.1
YANG_SJA1105_SITE = package/yang-sja1105/sja1105 
YANG_SJA1105_SITE_METHOD = local
YANG_SJA1105_LICENSE = MIT
YANG_SJA1105_LICENSE_FILES = COPYING
YANG_SJA1105_DEPENDENCIES = libxml2 pyang libnetconf sja1105-tool
YANG_SJA1105_CONF_ENV += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"
YANG_SJA1105_CONF_ENV += PYTHON_CONFIG="$(STAGING_DIR)/usr/bin/python-config"
YANG_SJA1105_CONF_ENV += ac_cv_path_NETOPEER_MANAGER="$(HOST_DIR)/usr/bin/netopeer-manager.host"

define YANG_SJA1105_CREATE_CONFIGURE
	cd $(@D); $(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/lnctool --model ./sja1105.yang transapi --paths ./paths.txt; \
	$(INSTALL) -D -m 0755 $(TOPDIR)/package/yang-sja1105/sja1105/sja1105.c $(BUILD_DIR)/yang-sja1105-$(YANG_SJA1105_VERSION)/;\
	$(INSTALL) -D -m 0755 $(TOPDIR)/package/yang-sja1105/sja1105/sja1105-init.c $(BUILD_DIR)/yang-sja1105-$(YANG_SJA1105_VERSION)/;\
	cd $(TOPDIR); \
	$(APPLY_PATCHES) $(@D) package/yang-sja1105/ 0001-yang-sja1105-modify-configure-file-pass-buildroot.patch; \
	cd $(@D); \
	$(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/autoreconf --force --install
endef
YANG_SJA1105_PRE_CONFIGURE_HOOKS += YANG_SJA1105_CREATE_CONFIGURE

define YANG_SJA1105_CONFIGURE_CMDS
	cd $(@D); \
	$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(YANG_SJA1105_CONF_ENV) \
	    ./configure  --prefix=/usr/local/ \
	    --host=arm-buildroot-linux-gnueabihf \
	    --build=x86_64-pc-linux-gnu \
	    --with-libxml2=$(STAGING_DIR)/usr/bin
endef

define YANG_SJA1105_LNCTOOL_CREATE_FILES
	cd $(@D); \
	$(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/lnctool --model `pwd`/sja1105.yang --search-path `pwd` --output-dir `pwd` validation;
endef

YANG_SJA1105_POST_BUILD_HOOKS +=YANG_SJA1105_LNCTOOL_CREATE_FILES


$(eval $(autotools-package))
