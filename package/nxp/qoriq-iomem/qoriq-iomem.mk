################################################################################
#
# qoriq-iomem
#
################################################################################

QORIQ_IOMEM_VERSION = 1.0
QORIQ_IOMEM_SITE = package/nxp/qoriq-iomem/src
QORIQ_IOMEM_SITE_METHOD = local
QORIQ_IOMEM_LICENSE = GPL
QORIQ_IOMEM_DEPENDENCIES = readline

define QORIQ_IOMEM_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) \
		CFLAGS+="-I$(STAGING_DIR)/usr/include" \
		LDFLAGS+="-L$(STAGING_DIR)/usr/lib"
endef

define QORIQ_IOMEM_INSTALL_TARGET_CMDS
	DESTDIR=$(TARGET_DIR) $(MAKE) -C $(@D) install;
endef

$(eval $(generic-package))
