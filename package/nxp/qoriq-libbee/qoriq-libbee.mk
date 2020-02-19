################################################################################
#
# qoriq-libbee
#
################################################################################

define QORIQ_LIBBEE_CONFIGURE_CMDS
	cd $(@D)
endef

QORIQ_LIBBEE_MAKE_OPTS = CC="$(TARGET_CC)" CROSS_COMPILE="$(TARGET_CROSS)"
define QORIQ_LIBBEE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(QORIQ_LIBBEE_MAKE_OPTS) $(TARGET_MAKE_OPTS) -C $(@D)
endef

define QORIQ_LIBBEE_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/bee_demo $(TARGET_DIR)/usr/bin/
endef

$(eval $(autotools-package))
