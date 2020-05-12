################################################################################
#
# qoriq-tsn-scripts
#
################################################################################

QORIQ_TSN_SCRIPTS_VERSION = isochron
QORIQ_TSN_SCRIPTS_SITE = https://github.com/vladimiroltean/tsn-scripts.git
QORIQ_TSN_SCRIPTS_SITE_METHOD = git
QORIQ_TSN_SCRIPTS_LICENSE = GPL2.0
QORIQ_TSN_SCRIPTS_LICENSE_FILES = COPYING
QORIQ_TSN_SCRIPTS_DEPENDENCIES = jq

define QORIQ_TSN_SCRIPTS_BUILD_CMDS
	$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(TARGET_MAKE_ENV) \
		$(MAKE) -j1 $(TARGET_MAKE_OPTS) -C $(@D)/isochron
endef

define QORIQ_TSN_SCRIPTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/isochron/isochron \
		$(TARGET_DIR)/usr/sbin/isochron
endef

$(eval $(generic-package))
