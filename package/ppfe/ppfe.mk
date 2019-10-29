################################################################################
#
# ppfe firmware for NXP ls1012a platform
#
################################################################################

PPFE_VERSION = LSDK-19.09
PPFE_SITE = https://github.com/NXP/qoriq-engine-pfe-bin.git
PPFE_SITE_METHOD = git
PPFE_LICENSE = NXP-Binary-EULA
PPFE_LICENSE_FILES = NXP-Binary-EULA

define PPFE_INSTALL_TARGET_CMDS
$(INSTALL) -d $(TARGET_DIR)/lib/firmware
$(INSTALL) -m 0755 $(@D)/ls1012a/slow_path/*.elf $(TARGET_DIR)/lib/firmware
cp -f $(@D)/ls1012a/u-boot/pfe_fw_sbl.itb $(BINARIES_DIR)
endef

$(eval $(generic-package))
