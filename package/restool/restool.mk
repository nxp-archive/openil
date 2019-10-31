#########################
## MC binary
#########################

RESTOOL_VERSION = LSDK-19.09
RESTOOL_SITE = http://source.codeaurora.org/external/qoriq/qoriq-components/restool.git
RESTOOL_SITE_METHOD = git
RESTOOL_LICENSE = GPL2.0

RESTOOL_MAKE_OPTS = \
        CC="$(TARGET_CC)" \
        CROSS_COMPILE="$(TARGET_CROSS)" \

define RESTOOL_BUILD_CMDS
	cd $(@D) && $(TARGET_MAKE_ENV) $(MAKE) $(RESTOOL_MAKE_OPTS)
	cp $(@D)/restool $(TARGET_DIR)/usr/bin/
	cp $(@D)/scripts/ls-main $(TARGET_DIR)/usr/bin/
	cp $(@D)/scripts/ls-append-dpl $(TARGET_DIR)/usr/bin/
	cd $(TARGET_DIR)/usr/bin/ && ln -sf ls-main ls-addmux
	cd $(TARGET_DIR)/usr/bin/ && ln -sf ls-main ls-addsw
	cd $(TARGET_DIR)/usr/bin/ && ln -sf ls-main ls-addni
	cd $(TARGET_DIR)/usr/bin/ && ln -sf ls-main ls-listni
	cd $(TARGET_DIR)/usr/bin/ && ln -sf ls-main ls-listmac
endef

$(eval $(generic-package))
