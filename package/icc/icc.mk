################################################################################
#
# icc: inter-core communication for Linux and baremetal system
#
################################################################################

ICC_VERSION = 0.1
ICC_SITE = package/icc/src
ICC_SITE_METHOD = local
ICC_LICENSE = GPL

define ICC_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define ICC_INSTALL_TARGET_CMDS
	cp -dpfr $(@D)/icc $(TARGET_DIR)/usr/sbin/
endef

$(eval $(generic-package))
