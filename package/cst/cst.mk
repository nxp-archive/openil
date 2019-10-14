################################################################################
#
# CST
#
################################################################################

CST_VERSION = LSDK-19.09
CST_SITE = https://source.codeaurora.org/external/qoriq/qoriq-components/cst
CST_SITE_METHOD = git
CST_LICENSE = NXP
CST_LICENSE_FILES = COPYING

export CST_VERSION

# host build
define HOST_CST_BUILD_CMDS
	cd $(@D) && $(MAKE) && ./gen_keys 1024;
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
