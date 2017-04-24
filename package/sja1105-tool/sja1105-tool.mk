################################################################################
#
# sja1105-tool
#
################################################################################

SJA1105_TOOL_VERSION = v0.2-rc1
SJA1105_TOOL_SITE = https://github.com/openil/sja1105-tool.git
SJA1105_TOOL_SITE_METHOD = git
SJA1105_TOOL_INSTALL_STAGING = YES
SJA1105_TOOL_LICENSE = BSD-3c
SJA1105_TOOL_LICENSE_FILES = COPYING
SJA1105_TOOL_DEPENDENCIES = libxml2

define SJA1105_TOOL_BUILD_CMDS
	cd $(@D); $(SED) '/\<VERSION /c\VERSION  = $(SJA1105_TOOL_VERSION)' $(@D)/Makefile; \
	$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(MAKE) $(TARGET_MAKE_OPTS) -C $(@D);
endef

define SJA1105_TOOL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/sja1105-tool $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
