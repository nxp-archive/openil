################################################################################
#
# fmucode
#
################################################################################

FMUCODE_VERSION = LSDK-17.09
FMUCODE_SITE = https://github.com/qoriq-open-source/fm-ucode.git
FMUCODE_SITE_METHOD = git
FMUCODE_LICENSE = Freescale-Binary-EULA
FMUCODE_LICENSE_FILES = Freescale-Binary-EULA

define FMUCODE_BUILD_CMDS
       echo "No building is needed for fmucode, just copy the binary to output/images/"
       cp -f $(@D)/$(BR2_PACKAGE_FMUCODE_BIN) $(BINARIES_DIR)/fmucode.bin
endef

$(eval $(generic-package))
