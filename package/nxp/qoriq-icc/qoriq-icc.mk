################################################################################
#
# qoriq-icc
#
################################################################################

QORIQ_ICC_VERSION = 0.1
QORIQ_ICC_SITE = package/nxp/qoriq-icc/src
QORIQ_ICC_SITE_METHOD = local
QORIQ_ICC_LICENSE = GPL
ifdef BR2_PACKAGE_QORIQ_ICC_GIC_OFFSET_ALIGN
QORIQ_ICC_CONFIGURE_OFFSET = "\#define CONFIG_ICC_GIC_OFFSET_ALIGN $(BR2_PACKAGE_QORIQ_ICC_GIC_OFFSET_ALIGN)"
endif
ifdef BR2_PACKAGE_QORIQ_ICC_GIC_IMX6Q
QORIQ_ICC_CONFIGURE_IMX6Q = "\#define CONFIG_ICC_GIC_IMX6Q $(BR2_PACKAGE_QORIQ_ICC_GIC_IMX6Q)"
endif
ifdef BR2_PACKAGE_QORIQ_ICC_GIC_LX2160A
QORIQ_ICC_CONFIGURE_LX2160A = "\#define CONFIG_ICC_LX2160A $(BR2_PACKAGE_QORIQ_ICC_GIC_LX2160A)"
endif
ifdef BR2_PACKAGE_QORIQ_ICC_MAX_CPUS
QORIQ_ICC_CONFIGURE_CPUS = "\#define CONFIG_ICC_MAX_CPUS $(BR2_PACKAGE_QORIQ_ICC_MAX_CPUS)"
endif

define QORIQ_ICC_BUILD_CMDS
	echo $(QORIQ_ICC_CONFIGURE_OFFSET) > $(@D)/icc_configure.h
	echo $(QORIQ_ICC_CONFIGURE_IMX6Q) >> $(@D)/icc_configure.h
	echo $(QORIQ_ICC_CONFIGURE_LX2160A) >> $(@D)/icc_configure.h
	echo $(QORIQ_ICC_CONFIGURE_CPUS) >> $(@D)/icc_configure.h
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define QORIQ_ICC_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/icc $(TARGET_DIR)/usr/sbin/
endef

$(eval $(generic-package))
