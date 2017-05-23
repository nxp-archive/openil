################################################################################
#
# ppa firmware for NXP layerscape platforms
#
################################################################################

PPA_VERSION = fsl-sdk-v2.0-1703
PPA_SITE = git://git.freescale.com/ppc/sdk/ppa-generic.git
PPA_LICENSE = Freescale-EULA
PPA_LICENSE_FILES = EULA

# export ARMV8_TOOLS_DIR="$(dir ${TARGET_CROSS})";\
# export ARMV8_TOOLS_PREFIX="$(notdir ${TARGET_CROSS})";\
#

define PPA_BUILD_CMDS
	export PATH=${PATH}:$(dir ${TARGET_CROSS});\
	export CROSS_COMPILE="${TARGET_CROSS}";\
	cd $(@D)/ppa/ && ./build rdb-fit all
endef

$(eval $(generic-package))
