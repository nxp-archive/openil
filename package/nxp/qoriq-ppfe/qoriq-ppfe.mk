################################################################################
#
# qoriq-ppfe
#
################################################################################

QORIQ_PPFE_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_PPFE_VERSION))
QORIQ_PPFE_SITE = https://github.com/NXP/qoriq-engine-pfe-bin.git
QORIQ_PPFE_SITE_METHOD = git
QORIQ_PPFE_LICENSE = NXP-Binary-EULA
QORIQ_PPFE_LICENSE_FILES = NXP-Binary-EULA
QORIQ_PPFE_INSTALL_STAGING = YES

define QORIQ_PPFE_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/lib/firmware
	$(INSTALL) -m 0755 $(@D)/ls1012a/slow_path/*.elf $(TARGET_DIR)/lib/firmware
endef

define QORIQ_PPFE_INSTALL_STAGING_CMDS
	$(INSTALL) -D $(@D)/ls1012a/u-boot/pfe_fw_sbl.itb $(BINARIES_DIR)
endef

$(eval $(generic-package))
