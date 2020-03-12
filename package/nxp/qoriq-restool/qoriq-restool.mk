###############################################################################
#
# qoriq-restool
#
################################################################################

QORIQ_RESTOOL_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_RESTOOL_VERSION))
QORIQ_RESTOOL_SITE = https://source.codeaurora.org/external/qoriq/qoriq-components/restool
QORIQ_RESTOOL_SITE_METHOD = git
QORIQ_RESTOOL_LICENSE = GPL2.0
QORIQ_RESTOOL_INSTALL_STAGING = YES

QORIQ_RESTOOL_MAKE_OPTS = \
        CC="$(TARGET_CC)" \
        CROSS_COMPILE="$(TARGET_CROSS)" \

define QORIQ_RESTOOL_BUILD_CMDS
	cd $(@D) && $(TARGET_MAKE_ENV) $(MAKE) $(QORIQ_RESTOOL_MAKE_OPTS)
endef

define QORIQ_RESTOOL_INSTALL_STAGING_CMDS
	$(INSTALL) -D $(@D)/restool $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D $(@D)/scripts/ls-main $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D $(@D)/scripts/ls-append-dpl $(TARGET_DIR)/usr/bin/
	cd $(TARGET_DIR)/usr/bin/ && ln -sf ls-main ls-addmux
	cd $(TARGET_DIR)/usr/bin/ && ln -sf ls-main ls-addsw
	cd $(TARGET_DIR)/usr/bin/ && ln -sf ls-main ls-addni
	cd $(TARGET_DIR)/usr/bin/ && ln -sf ls-main ls-listni
	cd $(TARGET_DIR)/usr/bin/ && ln -sf ls-main ls-listmac
endef

$(eval $(generic-package))
