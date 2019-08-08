################################################################################
#
# rcw image
#
################################################################################

RCW_VERSION = ls1028a-early-access
RCW_SITE = https://source.codeaurora.org/external/qoriq/qoriq-components/rcw
RCW_SITE_METHOD = git
RCW_LICENSE = BSD License
RCW_LICENSE_FILES = LICENSE

RCW_BIN = $(call qstrip,$(BR2_PACKAGE_RCW_BIN))
RCW_PLATFORM = $(firstword $(subst /, ,$(RCW_BIN)))

FIND = ls1028ardb
ifeq ($(findstring $(FIND), $(BR2_TARGET_UBOOT_BOARDNAME)), $(FIND))
define RCW_CONFIGURE_CMDS
	patch -p1 -s -d $(@D) < $(TARGET_DIR)/../../package/rcw/0001-ls1028ardb-Enable-IIC5_PMUX-for-GPIO-function.patch.conditional;\
	patch -p1 -s -d $(@D) < $(TARGET_DIR)/../../package/rcw/0002-ls1028ardb-Enable-CLK_OUT_PMUX-for-GPIO-function.patch.conditional
endef
endif

define RCW_BUILD_CMDS
	cd $(@D)/$(RCW_PLATFORM) && $(MAKE); \
	if [ $(RCW_PLATFORM) = ls1046ardb ] || [ $(RCW_PLATFORM) = ls1012ardb ]; then \
		tclsh board/nxp/common/byte_swap.tcl $(@D)/$(RCW_BIN) $(@D)/$(RCW_BIN) 8; \
		cp -f $(@D)/$(RCW_BIN).swapped $(BINARIES_DIR); \
	else \
		cp -f $(@D)/$(RCW_BIN) $(BINARIES_DIR); \
	fi
endef

$(eval $(generic-package))
