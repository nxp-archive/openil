################################################################################
#
# rcw image
#
################################################################################

RCW_VERSION = fsl-sdk-v2.0-1701
RCW_SITE = git://git.freescale.com/ppc/sdk/ls2-rcw.git
RCW_LICENSE = Freescale-Binary-EULA
RCW_LICENSE_FILES = Freescale-Binary-EULA

define RCW_CONFIGURE_CMDS
       echo "No building is needed for rcw"
endef

$(eval $(generic-package))
