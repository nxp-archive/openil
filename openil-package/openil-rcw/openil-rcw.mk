################################################################################
#
# openil-rcw image
#
################################################################################

OPENIL_RCW_VERSION = ls1028a-early-access
OPENIL_RCW_SITE = https://source.codeaurora.org/external/qoriq/qoriq-components/rcw
OPENIL_RCW_SITE_METHOD = git
OPENIL_RCW_LICENSE = BSD License
OPENIL_RCW_LICENSE_FILES = LICENSE

OPENIL_RCW_BIN = $(call qstrip,$(BR2_PACKAGE_OPENIL_RCW_BIN))
OPENIL_RCW_PLATFORM = $(firstword $(subst /, ,$(OPENIL_RCW_BIN)))

FIND = ls1028ardb
ifeq ($(findstring $(FIND), $(BR2_TARGET_UBOOT_BOARDNAME)), $(FIND))
define OPENIL_RCW_CONFIGURE_CMDS
	$(APPLY_PATCHES) $(@D) $(OPENIL_RCW_PKGDIR) \
		0001-ls1028ardb-Enable-IIC5_PMUX-for-GPIO-function.patch.conditional; \
	$(APPLY_PATCHES) $(@D) $(OPENIL_RCW_PKGDIR) \
		0002-ls1028ardb-Enable-CLK_OUT_PMUX-for-GPIO-function.patch.conditional;
endef
endif

define OPENIL_RCW_BUILD_CMDS
	cd $(@D)/$(OPENIL_RCW_PLATFORM) && $(MAKE); \
	if [ $(OPENIL_RCW_PLATFORM) = ls1046ardb ] || [ $(OPENIL_RCW_PLATFORM) = ls1012ardb ]; then \
		tclsh board/nxp/common/byte_swap.tcl $(@D)/$(OPENIL_RCW_BIN) $(@D)/$(OPENIL_RCW_BIN) 8; \
		cp -f $(@D)/$(OPENIL_RCW_BIN).swapped $(BINARIES_DIR); \
	else \
		cp -f $(@D)/$(OPENIL_RCW_BIN) $(BINARIES_DIR); \
	fi
endef

$(eval $(generic-package))
