################################################################################
#
# ppfe firmware for NXP ls1012a platform
#
################################################################################

PPFE_VERSION = fsl-sdk-v2.0-1701
PPFE_SITE = git://git.freescale.com/ppc/sdk/engine-pfe-bin.git
PPFE_LICENSE = Freescale-Binary-EULA
PPFE_LICENSE_FILES = Freescale-Binary-EULA

define PPFE_INSTALL_TARGET_CMDS
$(INSTALL) -d $(TARGET_DIR)/lib/firmware
$(INSTALL) -m 0644 $(@D)/Freescale-Binary-EULA $(TARGET_DIR)/lib/firmware
$(INSTALL) -m 0755 $(@D)/ls1012a/slow_path/*.elf $(TARGET_DIR)/lib/firmware
endef

$(eval $(generic-package))
