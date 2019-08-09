################################################################################
#
# Baremetal OS framework based on Uboot
#
################################################################################

BM_UBOOT_VERSION = OpenIL-Baremetal-201908
BM_UBOOT_SITE = https://github.com/openil/u-boot.git
BM_UBOOT_SITE_METHOD = git
BM_UBOOT_LICENSE = GPL-2.0+
BM_UBOOT_LICENSE_FILES = README
BM_UBOOT_DEPENDENCIES += host-dtc

BM_UBOOT_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \

BM_UBOOT_DEFCONFIG = $(call qstrip,$(BR2_PACKAGE_BM_UBOOT_DEFCONFIG))

define BM_UBOOT_BUILD_CMDS
	cd $(@D)/ && $(MAKE) distclean
	cd $(@D)/ && $(MAKE) $(BM_UBOOT_DEFCONFIG)
	$(TARGET_MAKE_ENV) $(MAKE) $(BM_UBOOT_MAKE_OPTS)-C $(@D)
endef

define BM_UBOOT_INSTALL_TARGET_CMDS
	cp -dpfr $(@D)/u-boot.bin $(BINARIES_DIR)/bm-u-boot.bin
endef

$(eval $(generic-package))
