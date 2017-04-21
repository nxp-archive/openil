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
YANG_CFGINTERFACES_CONF_ENV += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"
YANG_CFGINTERFACES_CONF_ENV += PYTHON_CONFIG="$(STAGING_DIR)/usr/bin/python-config"
YANG_CFGINTERFACES_CONF_ENV += ac_cv_path_NETOPEER_MANAGER="$(HOST_DIR)/usr/bin/netopeer-manager.host"
YANG_CFGINTERFACES_CONF_ENV += ac_cv_file__etc_debian_version=yes
YANG_CFGINTERFACES_CONF_ENV += WITH_LIBXML2_DIR=$(STAGING_DIR)/usr/bin/ 
YANG_CFGINTERFACES_CONF_ENV += ac_cv_prog_AVAHI_AUTOIPD=no
YANG_CFGINTERFACES_CONF_ENV += ac_cv_prog_AVAHI_DAEMON=no

define YANG_CFGINTERFACES_UPDATE_INIT_BIN
	sed -i "s/.\/model/\/usr\/local\/etc\/netopeer\/ietf-interfaces/g"  `grep "./model" -rl $(@D)/cfginterfaces-init.c`
endef

YANG_CFGINTERFACES_POST_CONFIGURE_HOOKS += YANG_CFGINTERFACES_UPDATE_INIT_BIN 

define YANG_CFGINTERFACES_INSTALL_INITCMD
	$(INSTALL) -D -m 0755 $(@D)/cfginterfaces-init $(TARGET_DIR)/usr/local/bin/; \
	$(INSTALL) -D -m 0755 $(@D)/model/ietf-yang-types.yin $(TARGET_DIR)/usr/local/etc/netopeer/ietf-interfaces/; \
	$(INSTALL) -D -m 0755 $(@D)/model/ietf-inet-types.yin $(TARGET_DIR)/usr/local/etc/netopeer/ietf-interfaces/
endef

YANG_CFGINTERFACES_POST_INSTALL_TARGET_HOOKS +=YANG_CFGINTERFACES_INSTALL_INITCMD

define YANG_CFGINTERFACES_CONFIGURE_CMDS
	cd $(@D);$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(YANG_CFGINTERFACES_CONF_ENV) \
	    ./configure  --prefix=/usr/local/ \
	    --host=arm-buildroot-linux-gnueabihf \
	    --build=x86_64-pc-linux-gnu
endef

$(eval $(autotools-package))
