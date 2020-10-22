################################################################################
#
# qoriq-genavb-tsn-bridge
#
################################################################################

QORIQ_GENAVB_TSN_BRIDGE_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_GENAVB_TSN_BRIDGE_VERSION))
QORIQ_GENAVB_TSN_BRIDGE_SITE = $(call qstrip,$(BR2_PACKAGE_QORIQ_GENAVB_TSN_BRIDGE_SITE))
QORIQ_GENAVB_TSN_BRIDGE_SITE_METHOD = git
QORIQ_GENAVB_TSN_BRIDGE_LICENSE = Proprietary (binaries), BSD-3-Clause (apps, scripts, public headers), GPL-2.0 (modules)
QORIQ_GENAVB_TSN_BRIDGE_LICENSE_FILES = EULA.txt, linux/modules/COPYING
QORIQ_GENAVB_TSN_BRIDGE_DEPENDENCIES = linux

define QORIQ_GENAVB_TSN_BRIDGE_BUILD_CMDS
	$(MAKE) -C $(@D)/linux/modules CROSS_COMPILE="$(TARGET_CROSS)" KERNELDIR=$(BUILD_DIR)/linux-$(BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION) ARCH=arm64 modules
endef

define QORIQ_GENAVB_TSN_BRIDGE_INSTALL_TARGET_CMDS
	# genavb binaries, configs files and scripts
	$(INSTALL) -m 755 $(@D)/bin/* $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 755 $(@D)/lib/* $(TARGET_DIR)/usr/lib
	$(INSTALL) -d $(TARGET_DIR)/etc/genavb
	$(INSTALL) -m 660 $(@D)/configs/* $(TARGET_DIR)/etc/genavb
	# genavb kernel module
	$(MAKE) -C $(@D)/linux/modules CROSS_COMPILE="$(TARGET_CROSS)" KERNELDIR=$(LINUX_DIR) ARCH=$(KERNEL_ARCH) PREFIX=$(TARGET_DIR) install
endef

define QORIQ_GENAVB_TSN_BRIDGE_INSTALL_INIT_SYSV
	$(INSTALL) -d $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 755 $(@D)/scripts/genavb $(TARGET_DIR)/etc/init.d/genavb
	ln -snf $(TARGET_DIR)/etc/init.d/genavb $(TARGET_DIR)/etc/init.d/S99genavb
	# disable autostart
	$(SED) 's/CFG_AUTO_START=.*/CFG_AUTO_START=0/' $(TARGET_DIR)/etc/genavb/config
endef

$(eval $(generic-package))
