################################################################################
#
# ppfe firmware for NXP ls1012a platform
#
################################################################################

PPFE_VERSION = integration
PPFE_SITE = https://github.com/NXP/qoriq-engine-pfe-bin.git
PPFE_SITE_METHOD = git
PPFE_LICENSE = NXP-Binary-EULA.txt
PPFE_LICENSE_FILES = NXP-Binary-EULA.txt

define PPFE_INSTALL_TARGET_CMDS
$(INSTALL) -d $(TARGET_DIR)/lib/firmware
$(INSTALL) -m 0644 $(@D)/NXP-Binary-EULA.txt $(TARGET_DIR)/lib/firmware
$(INSTALL) -m 0755 $(@D)/ls1012a/slow_path/*.elf $(TARGET_DIR)/lib/firmware
endef

$(eval $(generic-package))
