################################################################################
#
# qoriq-libblep
#
################################################################################

define QORIQ_LIBBLEP_CONFIGURE_CMDS
       cd $(@D)
endef

QORIQ_LIBBLEP_MAKE_OPTS = CC="$(TARGET_CC)" CROSS_COMPILE="$(TARGET_CROSS)"
define QORIQ_LIBBLEP_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(QORIQ_LIBBLEP_MAKE_OPTS) $(TARGET_MAKE_OPTS) -C $(@D)
endef

define QORIQ_LIBBLEP_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/blep_demo $(TARGET_DIR)/usr/bin/
endef

$(eval $(autotools-package))
