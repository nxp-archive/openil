################################################################################
#
# fmucode
#
################################################################################

FMUCODE_VERSION = fsl-sdk-v2.0
FMUCODE_SITE = git://git.freescale.com/ppc/sdk/fm-ucode.git
FMUCODE_LICENSE = Freescale-Binary-EULA
FMUCODE_LICENSE_FILES = Freescale-Binary-EULA

define FMUCODE_CONFIGURE_CMDS
       echo "No building is needed for fmucode"
endef

$(eval $(generic-package))
