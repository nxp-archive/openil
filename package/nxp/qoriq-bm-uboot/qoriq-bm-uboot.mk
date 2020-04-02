################################################################################
#
# qoriq-bm-uboot
#
################################################################################

QORIQ_BM_UBOOT_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_BM_UBOOT_VERSION))
QORIQ_BM_UBOOT_SITE = $(call qstrip,$(BR2_PACKAGE_QORIQ_BM_UBOOT_SITE))
QORIQ_BM_UBOOT_SITE_METHOD = git
QORIQ_BM_UBOOT_LICENSE = GPL-2.0+
QORIQ_BM_UBOOT_LICENSE_FILES = README
QORIQ_BM_UBOOT_DEPENDENCIES += host-dtc

QORIQ_BM_UBOOT_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \

QORIQ_BM_UBOOT_DEFCONFIG = $(call qstrip,$(BR2_PACKAGE_QORIQ_BM_UBOOT_DEFCONFIG))

define QORIQ_BM_UBOOT_BUILD_CMDS
	cd $(@D)/ && $(MAKE) distclean
	cd $(@D)/ && $(MAKE) $(QORIQ_BM_UBOOT_DEFCONFIG)
	$(TARGET_MAKE_ENV) $(MAKE) $(QORIQ_BM_UBOOT_MAKE_OPTS)-C $(@D)
endef

define QORIQ_BM_UBOOT_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/u-boot.bin $(BINARIES_DIR)/bm-u-boot.bin
endef

$(eval $(generic-package))
