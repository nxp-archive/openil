################################################################################
#
# libbee
#
################################################################################
define LIBBEE_CONFIGURE_CMDS
	cd $(@D)
endef

define LIBBEE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_MAKE_OPTS) -C $(@D)
endef

define LIBBEE_INSTALL_TARGET_CMDS
	cp $(@D)/bee_demo $(TARGET_DIR)/usr/bin/
endef

$(eval $(autotools-package))
