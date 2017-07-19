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

ifneq ($(BR2_PACKAGE_HOST_CST_CORE_HOLDOFF),y)
define CST_CORE_DISABLE_HOLDOFF
	$(APPLY_PATCHES) $(@D) package/cst/uni_pbi/ 0001-uni_pbi-ls1-Disable-the-core-hold-off.patch
endef

HOST_CST_PRE_PATCH_HOOKS += CST_CORE_DISABLE_HOLDOFF
endif

# host build
define HOST_CST_BUILD_CMDS
	$(HOST_CONFIGURE_OPTS) $(MAKE) -C $(@D)
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
