################################################################################
#
# qoriq-genavb-tsn-endpoint-tsn
#
################################################################################

QORIQ_GENAVB_TSN_ENDPOINT_TSN_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_GENAVB_TSN_ENDPOINT_TSN_VERSION))
QORIQ_GENAVB_TSN_ENDPOINT_TSN_SITE = $(call qstrip,$(BR2_PACKAGE_QORIQ_GENAVB_TSN_ENDPOINT_TSN_SITE))
QORIQ_GENAVB_TSN_ENDPOINT_TSN_SITE_METHOD = git
QORIQ_GENAVB_TSN_ENDPOINT_TSN_LICENSE = Proprietary (binaries), BSD-3-Clause (include, apps, scripts, public), GPL-2.0 (modules)
QORIQ_GENAVB_TSN_ENDPOINT_TSN_LICENSE_FILES = licenses/EULA.txt, licenses/COPYING, licenses/BSD-3-Clause
QORIQ_GENAVB_TSN_ENDPOINT_TSN_DEPENDENCIES = linux

define QORIQ_GENAVB_TSN_ENDPOINT_TSN_BUILD_CMDS
	# genavb kernel module
	$(MAKE) -C $(@D)/linux/modules CROSS_COMPILE="$(TARGET_CROSS)" KERNELDIR=$(BUILD_DIR)/linux-$(BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION) ARCH=arm64 modules
	# genavb apps
	$(MAKE) -C $(@D)/apps/linux/tsn-app CROSS_COMPILE="$(TARGET_CROSS)"
endef

define QORIQ_GENAVB_TSN_ENDPOINT_TSN_INSTALL_TARGET_CMDS
	# genavb binaries, configs files and scripts
	$(INSTALL) -m 755 $(@D)/bin/* $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 755 $(@D)/lib/* $(TARGET_DIR)/usr/lib
	ln -snfr $(TARGET_DIR)/usr/lib/libgenavb.so.1.0 $(TARGET_DIR)/usr/lib/libgenavb.so.1
	$(INSTALL) -d $(TARGET_DIR)/etc/genavb
	$(INSTALL) -m 660 $(@D)/configs/* $(TARGET_DIR)/etc/genavb
	# genavb kernel module
	$(MAKE) -C $(@D)/linux/modules CROSS_COMPILE="$(TARGET_CROSS)" KERNELDIR=$(LINUX_DIR) ARCH=$(KERNEL_ARCH) PREFIX=$(TARGET_DIR) install
	# genavb apps
	$(MAKE) -C $(@D)/apps/linux/tsn-app CROSS_COMPILE="$(TARGET_CROSS)" BIN_DIR="$(TARGET_DIR)/usr/bin" install
endef

define QORIQ_GENAVB_TSN_ENDPOINT_TSN_INSTALL_INIT_SYSV
	$(INSTALL) -d $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 755 $(@D)/scripts/genavb $(TARGET_DIR)/etc/init.d/genavb
	ln -snfr $(TARGET_DIR)/etc/init.d/genavb $(TARGET_DIR)/etc/init.d/S99genavb
	# disable autostart
	$(SED) 's/CFG_AUTO_START=.*/CFG_AUTO_START=0/' $(TARGET_DIR)/etc/genavb/config
endef

$(eval $(generic-package))
