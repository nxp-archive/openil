################################################################################
#
# tsntool
#
################################################################################

TSNTOOL_VERSION = v0.1
TSNTOOL_SITE = ssh://git@bitbucket.sw.nxp.com/dnind/tsntool.git
TSNTOOL_SITE_METHOD = git
TSNTOOL_LICENSE = MIT/GPL2.0
TSNTOOL_LICENSE_FILES = LICENSE
TSNTOOL_INSTALL_STAGING = YES
TSNTOOL_DEPENDENCIES = libnl readline ncurses

define TSNTOOL_BUILD_CMDS
	mkdir $(@D)/include/linux/;
	$(SED) 's/termcap/ncurses/' $(@D)/Makefile;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/linux-$(BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION)/include/uapi/linux/tsn.h $(@D)/include/linux/;
	$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(TARGET_MAKE_ENV) $(MAKE) $(TARGET_MAKE_OPTS) -C $(@D)
endef

define TSNTOOL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libtsn.so $(TARGET_DIR)/usr/lib/;
	$(INSTALL) -D -m 0755 $(@D)/tsntool $(TARGET_DIR)/usr/bin/;
	cp -rf package/tsntool/samples/ $(TARGET_DIR)/root
endef

$(eval $(generic-package))
