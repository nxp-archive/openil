################################################################################
#
# fmucode
#
################################################################################

FMUCODE_VERSION = fsl-sdk-v2.0
FMUCODE_SITE = git://git.freescale.com/ppc/sdk/fm-ucode.git
FMUCODE_LICENSE = Freescale-Binary-EULA
FMUCODE_LICENSE_FILES = Freescale-Binary-EULA

FMUCODE_INSTALL_TARGET = NO
FMUCODE_BUILD_CMDS = NO

$(eval $(generic-package))
