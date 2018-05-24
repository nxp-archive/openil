PHYTOOL_VERSION = v2
PHYTOOL_SITE = https://github.com/wkz/phytool.git
PHYTOOL_SITE_METHOD = git
PHYTOOL_LICENSE = GPLv2

define PHYTOOL_BUILD_CMDS
	$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(TARGET_MAKE_OPTS);
endef

define PHYTOOL_INSTALL_TARGET_CMDS
	PREFIX=usr DESTDIR=$(TARGET_DIR) $(MAKE) -C $(@D) install;
endef

$(eval $(generic-package))

