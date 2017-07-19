################################################################################
#
# CST
#
################################################################################

CST_VERSION = fsl-sdk-v2.0-1703
CST_SITE = git://git.freescale.com/ppc/sdk/cst.git
CST_SITE_METHOD = git
CST_LICENSE = NXP
CST_LICENSE_FILES = COPYING

# host build
define HOST_CST_BUILD_CMDS
	$(HOST_CONFIGURE_OPTS) $(MAKE) -C $(@D)
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
