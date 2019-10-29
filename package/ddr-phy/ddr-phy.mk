#########################
## DDR PHY firmware
#########################

DDR_PHY_VERSION = LSDK-19.09
DDR_PHY_SITE = https://github.com/NXP/ddr-phy-binary.git
DDR_PHY_SITE_METHOD = git
DDR_PHY_LICENSE = GPL2.0

UBOOT_BOARDNAME = $(call qstrip,$(BR2_TARGET_UBOOT_BOARDNAME))
BOARD_NAME = $(firstword $(subst _, ,$(UBOOT_BOARDNAME)))

ifeq ($(findstring lx2160a, $(BOARD_NAME)), lx2160a)
DDR_PHY_BOARDPATH = lx2160a
BINFILE = fip_ddr.bin
endif

DDR_PHY_FILE = fip_ddr.bin

define DDR_PHY_BUILD_CMDS
	cp $(@D)/${DDR_PHY_BOARDPATH}/${BINFILE} $(BINARIES_DIR)/${DDR_PHY_FILE}
endef

$(eval $(generic-package))
