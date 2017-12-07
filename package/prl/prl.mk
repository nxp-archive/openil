PRL_VERSION = 0.1
PRL_SITE = package/prl/src
PRL_SITE_METHOD = local
PRL_LICENSE = BSD-3c
PRL_LICENSE_FILES = COPYING

define PRL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define PRL_INSTALL_TARGET_CMDS
	DESTDIR=$(TARGET_DIR) $(MAKE) -C $(@D) install;
endef

$(eval $(generic-package))

