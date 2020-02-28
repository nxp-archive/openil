###############################################################################
#
# qoriq-cst
#
################################################################################

QORIQ_CST_VERSION = $(call qstrip,$(BR2_PACKAGE_HOST_QORIQ_CST_VERSION))
QORIQ_CST_SITE = https://source.codeaurora.org/external/qoriq/qoriq-components/cst
QORIQ_CST_SITE_METHOD = git
QORIQ_CST_LICENSE = NXP
QORIQ_CST_LICENSE_FILES = COPYING

export QORIQ_CST_VERSION

# host build
define HOST_QORIQ_CST_BUILD_CMDS
	cd $(@D) && $(MAKE) && ./gen_keys 1024;
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
