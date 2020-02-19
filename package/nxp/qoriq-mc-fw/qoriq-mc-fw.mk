################################################################################
#
# qoriq-mc-fw
#
################################################################################

QORIQ_MC_FW_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_MC_FW_VERSION))
QORIQ_MC_FW_SITE = https://github.com/NXP/qoriq-mc-binary.git
QORIQ_MC_FW_SITE_METHOD = git
QORIQ_MC_FW_LICENSE = GPL2.0
QORIQ_MC_FW_INSTALL_STAGING = YES

UBOOT_BOARDNAME = $(call qstrip,$(BR2_TARGET_UBOOT_BOARDNAME))
BOARD_NAME = $(firstword $(subst _, ,$(UBOOT_BOARDNAME)))

ifeq ($(findstring lx2160a, $(BOARD_NAME)), lx2160a)
BOARD_PATH = lx2160a
BIN_FILE = $(call qstrip,$(BR2_PACKAGE_QORIQ_MC_FW_BIN))
endif

MC_FW_FILE = mc.itb

define QORIQ_MC_FW_INSTALL_STAGING_CMDS
	$(INSTALL) -D $(@D)/${BOARD_PATH}/${BIN_FILE} $(BINARIES_DIR)/${MC_FW_FILE}
endef

$(eval $(generic-package))
