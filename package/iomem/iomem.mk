################################################################################
#
# iomem
#
################################################################################

IOMEM_VERSION = 1.0
IOMEM_SITE = package/iomem/src
IOMEM_SITE_METHOD = local
IOMEM_LICENSE = GPL
IOMEM_DEPENDENCIES = readline

define IOMEM_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) \
		CFLAGS+="-I$(STAGING_DIR)/usr/include" \
		LDFLAGS+="-L$(STAGING_DIR)/usr/lib"
endef

define IOMEM_INSTALL_TARGET_CMDS
	DESTDIR=$(TARGET_DIR) $(MAKE) -C $(@D) install;
endef

$(eval $(generic-package))
