################################################################################
#
# qoriq-ddr-phy
#
################################################################################

QORIQ_DDR_PHY_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_DDR_PHY_VERSION))
QORIQ_DDR_PHY_SITE = https://github.com/NXP/ddr-phy-binary.git
QORIQ_DDR_PHY_SITE_METHOD = git
QORIQ_DDR_PHY_LICENSE = GPL2.0
QORIQ_DDR_PHY_INSTALL_STAGING = YES

UBOOT_BOARDNAME = $(call qstrip,$(BR2_TARGET_UBOOT_BOARDNAME))
BOARD_NAME = $(firstword $(subst _, ,$(UBOOT_BOARDNAME)))

ifeq ($(findstring lx2160a, $(BOARD_NAME)), lx2160a)
DDR_PHY_BOARDPATH = lx2160a
BINFILE = fip_ddr.bin
endif

DDR_PHY_FILE = fip_ddr.bin

define QORIQ_DDR_PHY_INSTALL_STAGING_CMDS
	$(INSTALL) -D $(@D)/${DDR_PHY_BOARDPATH}/${BINFILE} $(BINARIES_DIR)/${DDR_PHY_FILE}
endef

$(eval $(generic-package))
