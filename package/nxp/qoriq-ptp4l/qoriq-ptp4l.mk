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
QORIQ_PTP4L_DEPENDENCIES = linux

QORIQ_PTP4L_MAKE_OPTS = \
	prefix=/usr \
	CC="$(TARGET_CC)" \
	CROSS_COMPILE="$(TARGET_CROSS)"

define QORIQ_PTP4L_BUILD_CMDS
	export PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)"; \
	export KBUILD_OUTPUT="$(BUILD_DIR)/linux-$(BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION)"; \
	$(TARGET_MAKE_ENV) $(MAKE1) $(QORIQ_PTP4L_MAKE_OPTS) -C $(@D)
endef

define QORIQ_PTP4L_INSTALL_TARGET_CMDS
	export PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)"; \
	export KBUILD_OUTPUT="$(BUILD_DIR)/linux-$(BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION)"; \
	$(TARGET_MAKE_ENV) $(MAKE1) $(QORIQ_PTP4L_MAKE_OPTS) -C $(@D) DESTDIR=$(TARGET_DIR) install; \
	$(INSTALL) -d $(TARGET_DIR)/etc/ptp4l_cfg; \
	$(INSTALL) $(@D)/configs/* $(TARGET_DIR)/etc/ptp4l_cfg
endef

$(eval $(generic-package))
