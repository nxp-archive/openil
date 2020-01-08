################################################################################
#
# icc: inter-core communication for Linux and baremetal system
#
################################################################################

ICC_VERSION = 0.1
ICC_SITE = package/icc/src
ICC_SITE_METHOD = local
ICC_LICENSE = GPL
ifdef BR2_PACKAGE_ICC_GIC_OFFSET_ALIGN
ICC_CONFIGURE_OFFSET = "\#define CONFIG_ICC_GIC_OFFSET_ALIGN $(BR2_PACKAGE_ICC_GIC_OFFSET_ALIGN)"
endif
ifdef BR2_PACKAGE_ICC_GIC_IMX6Q
ICC_CONFIGURE_IMX6Q = "\#define CONFIG_ICC_GIC_IMX6Q $(BR2_PACKAGE_ICC_GIC_IMX6Q)"
endif
ifdef BR2_PACKAGE_ICC_MAX_CPUS
ICC_CONFIGURE_CPUS = "\#define CONFIG_ICC_MAX_CPUS $(BR2_PACKAGE_ICC_MAX_CPUS)"
endif

define ICC_BUILD_CMDS
	echo $(ICC_CONFIGURE_OFFSET) > $(@D)/icc_configure.h
	echo $(ICC_CONFIGURE_IMX6Q) >> $(@D)/icc_configure.h
	echo $(ICC_CONFIGURE_CPUS) >> $(@D)/icc_configure.h
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define ICC_INSTALL_TARGET_CMDS
	cp -dpfr $(@D)/icc $(TARGET_DIR)/usr/sbin/
endef

$(eval $(generic-package))
