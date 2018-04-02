################################################################################
#
# rcw image
#
################################################################################

RCW_VERSION = LSDK-17.09
RCW_SITE = https://github.com/qoriq-open-source/rcw.git
RCW_SITE_METHOD = git
RCW_LICENSE = BSD License
RCW_LICENSE_FILES = LICENSE

RCW_BIN = $(call qstrip,$(BR2_PACKAGE_RCW_BIN))
RCW_PLATFORM = $(firstword $(subst /, ,$(RCW_BIN)))

define RCW_BUILD_CMDS
	if [ $(RCW_PLATFORM) != ls1012ardb ]; then \
		cd $(@D)/$(RCW_PLATFORM) && $(MAKE); \
	fi
	if [ $(RCW_PLATFORM) = ls1046ardb ]; then \
		tclsh board/nxp/common/byte_swap.tcl $(@D)/$(RCW_BIN) $(@D)/$(RCW_BIN).swap 8; \
		cp -f $(@D)/$(RCW_BIN).swap $(BINARIES_DIR); \
	else \
		cp -f $(@D)/$(RCW_BIN) $(BINARIES_DIR); \
	fi
endef

$(eval $(generic-package))
