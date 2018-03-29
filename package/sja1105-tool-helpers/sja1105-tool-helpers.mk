################################################################################
#
# sja1105-tool helper scripts
#
################################################################################

SJA1105_TOOL_HELPERS_VERSION = $(SJA1105_TOOL_VERSION)
SJA1105_TOOL_HELPERS_SITE = $(BUILD_DIR)/sja1105-tool
SJA1105_TOOL_HELPERS_SITE_METHOD = local
SJA1105_TOOL_HELPERS_LICENSE = BSD-3c
SJA1105_TOOL_HELPERS_LICENSE_FILES = COPYING
SJA1105_TOOL_HELPERS_DEPENDENCIES = sja1105-tool bash jq

define SJA1105_TOOL_INSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/usr/share/sja1105-helpers && cp -r $(@D)/src/helpers $(TARGET_DIR)/usr/share/sja1105-helpers;
endef

$(eval $(generic-package))

