################################################################################
#
# qoriq-tsntool
#
################################################################################

QORIQ_TSNTOOL_VERSION = v0.4
QORIQ_TSNTOOL_SITE = https://github.com/openil/tsntool.git
QORIQ_TSNTOOL_SITE_METHOD = git
QORIQ_TSNTOOL_LICENSE = MIT/GPL2.0
QORIQ_TSNTOOL_LICENSE_FILES = LICENSE
QORIQ_TSNTOOL_INSTALL_STAGING = YES
QORIQ_TSNTOOL_DEPENDENCIES = linux libnl readline ncurses cjson

define QORIQ_TSNTOOL_BUILD_CMDS
	mkdir -p $(@D)/include/linux/;
	$(SED) 's/termcap/ncurses/' $(@D)/Makefile;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/linux-$(BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION)/include/uapi/linux/tsn.h $(@D)/include/linux/;
	$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(TARGET_MAKE_ENV) $(MAKE) -j1 $(TARGET_MAKE_OPTS) -C $(@D)
endef

define QORIQ_TSNTOOL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libtsn.so $(TARGET_DIR)/usr/lib/;
	$(INSTALL) -D -m 0755 $(@D)/tsntool $(TARGET_DIR)/usr/bin/;
	cp -rf package/nxp/qoriq-tsntool/samples/ $(TARGET_DIR)/root
endef

define QORIQ_TSNTOOL_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/linux-$(BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION)/include/uapi/linux/tsn.h \
		$(STAGING_DIR)/usr/include/linux/;
	$(INSTALL) -d $(STAGING_DIR)/usr/include/tsn;
	$(INSTALL) -D -m 0755 $(@D)/include/tsn/genl_tsn.h $(STAGING_DIR)/usr/include/tsn;
	$(INSTALL) -D -m 0755 $(@D)/libtsn.so $(STAGING_DIR)/usr/lib/;
endef

$(eval $(generic-package))
