#####################################################
#
# mc-utils
#
#####################################################

MC_UTILS_VERSION = LSDK-19.09
MC_UTILS_SITE = https://source.codeaurora.org/external/qoriq/qoriq-components/mc-utils
MC_UTILS_SITE_METHOD = git
MC_UTILS_LICENSE = GPL2.0

UBOOT_BOARDNAME = $(call qstrip,$(BR2_TARGET_UBOOT_BOARDNAME))
BOARD_NAME = $(firstword $(subst _, ,$(UBOOT_BOARDNAME)))

ifeq ($(BOARD_NAME), lx2160ardb)
MC_UTILS_BOARDPATH = lx2160a/RDB
FPL_FILE = dpl-eth.19.dtb
DPC_FILE = dpc-usxgmii.dtb
endif

define MC_UTILS_BUILD_CMDS
	make -C $(@D)/config/
	cp $(@D)/config/${MC_UTILS_BOARDPATH}/${DPC_FILE} $(BINARIES_DIR)/
	cp $(@D)/config/${MC_UTILS_BOARDPATH}/${FPL_FILE} $(BINARIES_DIR)/
endef

$(eval $(generic-package))
