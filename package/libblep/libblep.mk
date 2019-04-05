################################################################################
#
# libblep
#
################################################################################
define LIBBLEP_CONFIGURE_CMDS
	cd $(@D)
endef

define LIBBLEP_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_MAKE_OPTS) -C $(@D)
endef

define LIBBLEP_INSTALL_TARGET_CMDS
	cp $(@D)/blep_demo $(TARGET_DIR)/usr/bin/
endef

$(eval $(autotools-package))
