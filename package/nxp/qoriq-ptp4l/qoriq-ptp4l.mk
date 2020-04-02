################################################################################
#
# qoriq-ptp4l
#
################################################################################

QORIQ_PTP4L_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_PTP4L_VERSION))
QORIQ_PTP4L_SITE = $(call qstrip,$(BR2_PACKAGE_QORIQ_PTP4L_SITE))
QORIQ_PTP4L_SITE_METHOD = git
QORIQ_PTP4L_LICENSE = GPL2
QORIQ_PTP4L_LICENSE_FILES = COPYING
ifeq ($(BR2_PACKAGE_SJA1105_TOOL),y)
QORIQ_PTP4L_DEPENDENCIES = sja1105-tool
SJA1105_OUTPUT=$(STAGING_DIR)/usr
endif

QORIQ_PTP4L_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	SJA1105_ROOTDIR="$(SJA1105_OUTPUT)" \

define QORIQ_PTP4L_BUILD_CMDS
	export PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)"; \
	export KBUILD_OUTPUT="$(STAGING_DIR)"; \
	$(TARGET_MAKE_ENV) $(MAKE1) $(QORIQ_PTP4L_MAKE_OPTS) -C $(@D)
endef

define QORIQ_PTP4L_INSTALL_TARGET_CMDS
	export PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)"; \
	export KBUILD_OUTPUT="$(STAGING_DIR)"; \
	$(TARGET_MAKE_ENV) $(MAKE1) $(QORIQ_PTP4L_MAKE_OPTS) -C $(@D) DESTDIR=$(TARGET_DIR) install; \
	$(INSTALL) -d $(TARGET_DIR)/etc/ptp4l_cfg; \
	$(INSTALL) $(@D)/configs/* $(TARGET_DIR)/etc/ptp4l_cfg
endef

$(eval $(generic-package))
