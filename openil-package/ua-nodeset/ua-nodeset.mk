################################################################################
#
# ua-nodeset
#
################################################################################

UA_NODESET_VERSION = UA-1.04.3-2019-09-09
UA_NODESET_SITE = https://github.com/OPCFoundation/UA-Nodeset.git
UA_NODESET_SITE_METHOD = git
UA_NODESET_LICENSE = MOZILLA
UA_NODESET_INSTALL_STAGING = YES

define UA_NODESET_INSTALL_STAGING_CMDS
	cp -rf $(@D) $(STAGING_DIR)/usr/share/ua-nodeset
endef

define UA_NODESET_INSTALL_TARGET_CMDS
	cp -rf $(@D) $(TARGET_DIR)/usr/share/ua-nodeset
endef

$(eval $(generic-package))
