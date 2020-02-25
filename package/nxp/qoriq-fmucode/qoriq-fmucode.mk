################################################################################
#
# qoriq-fmucode
#
################################################################################

QORIQ_FMUCODE_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_FMUCODE_VERSION))
QORIQ_FMUCODE_SITE = https://github.com/NXP/qoriq-fm-ucode.git
QORIQ_FMUCODE_SITE_METHOD = git
QORIQ_FMUCODE_LICENSE = Freescale-Binary-EULA
QORIQ_FMUCODE_LICENSE_FILES = Freescale-Binary-EULA
QORIQ_FMUCODE_INSTALL_STAGING = YES

define QORIQ_FMUCODE_INSTALL_STAGING_CMDS
       echo "No building is needed for fmucode, just copy the binary to output/images/"
       $(INSTALL) -D $(@D)/$(BR2_PACKAGE_QORIQ_FMUCODE_BIN) $(BINARIES_DIR)/fmucode.bin
endef

$(eval $(generic-package))
