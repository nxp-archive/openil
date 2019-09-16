################################################################################
#
# ppa firmware for NXP layerscape platforms
#
################################################################################

PPA_VERSION = LSDK-18.09
PPA_SITE = https://source.codeaurora.org/external/qoriq/qoriq-components/ppa-generic
PPA_SITE_METHOD = git
PPA_LICENSE = BSD 3-clause "New" or "Revised" License
PPA_LICENSE_FILES = license.txt
PPA_DEPENDENCIES = host-uboot-tools

PPA_PLATFORM = $(call qstrip,$(BR2_PACKAGE_PPA_PLATFORM))

define PPA_BUILD_CMDS
	export PATH=${PATH}:$(dir ${TARGET_CROSS});\
	export CROSS_COMPILE="${TARGET_CROSS}";\
	cd $(@D)/ppa/ && ./build rdb-fit all
	cp -f $(@D)/ppa/soc-$(PPA_PLATFORM)/build/obj/ppa.itb $(BINARIES_DIR)/
endef

$(eval $(generic-package))
