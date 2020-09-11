################################################################################
#
# qoriq-prl
#
################################################################################

QORIQ_PRL_VERSION = 0.1
QORIQ_PRL_SITE = package/nxp/qoriq-prl/src
QORIQ_PRL_SITE_METHOD = local
QORIQ_PRL_LICENSE = BSD-3c
QORIQ_PRL_LICENSE_FILES = COPYING

define QORIQ_PRL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define QORIQ_PRL_INSTALL_TARGET_CMDS
	DESTDIR=$(TARGET_DIR) $(MAKE) -C $(@D) install;
endef

$(eval $(generic-package))
