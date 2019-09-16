################################################################################
#
# CST
#
################################################################################

CST_VERSION = LSDK-18.06
CST_SITE = https://github.com/qoriq-open-source/cst.git
CST_SITE_METHOD = git
CST_LICENSE = NXP
CST_LICENSE_FILES = COPYING

export CST_VERSION

# host build
define HOST_CST_BUILD_CMDS
	cd $(@D) && $(MAKE);
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
