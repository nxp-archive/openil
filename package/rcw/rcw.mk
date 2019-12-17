################################################################################
#
# rcw image
#
################################################################################

RCW_VERSION = LSDK-19.09
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
	patch -p1 -s -d $(@D) < $(TARGET_DIR)/../../package/rcw/0002-ls1028ardb-Enable-CLK_OUT_PMUX-for-GPIO-function.patch.conditional;\
	patch -p1 -s -d $(@D) < $(TARGET_DIR)/../../package/rcw/0003-Enable-SAI-for-LS1028ARDB-baremetal.patch.conditional
endef
endif

define RCW_BUILD_CMDS
	cd $(@D)/$(RCW_PLATFORM) && $(MAKE); \
	cp -f $(@D)/$(RCW_BIN) $(BINARIES_DIR);
endef

$(eval $(generic-package))
