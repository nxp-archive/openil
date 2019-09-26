################################################################################
#
# atf
#
################################################################################

TFA_VERSION = LSDK-19.09
TFA_SITE = https://source.codeaurora.org/external/qoriq/qoriq-components/atf
TFA_SITE_METHOD = git
TFA_INSTALL_STAGING = YES
TFA_LICENSE = GPL2.0
TFA_DEPENDENCIES = uboot rcw

RCW_PATH = $(call qstrip,$(BR2_PACKAGE_RCW_BIN))
RCW_FILE = $(lastword $(subst /, ,$(RCW_PATH)))
UBOOT_BIN = $(call qstrip,$(BR2_TARGET_UBOOT_FORMAT_CUSTOM_NAME))

UBOOT_BOARDNAME = $(call qstrip,$(BR2_TARGET_UBOOT_BOARDNAME))
BOARD_NAME = $(firstword $(subst _, ,$(UBOOT_BOARDNAME)))

ifeq ($(findstring sdboot, $(RCW_FILE)), sdboot)
TFA_BOOT_MODE = \
	BOOT_MODE=sd
BOOTMODE = sd
endif
ifeq ($(findstring emmcboot, $(RCW_FILE)), emmcboot)
TFA_BOOT_MODE = \
	BOOT_MODE=emmc
BOOTMODE = emmc
endif
ifeq ($(findstring qspiboot, $(RCW_FILE)), qspiboot)
TFA_BOOT_MODE = \
	BOOT_MODE=qspi
BOOTMODE = qspi
endif

TFA_MAKE_OPTS = \
	CROSS_COMPILE="$(TARGET_CROSS)"
TFA_PLAT = \
	PLAT=${BOARD_NAME}
TFA_RCW = \
	RCW=${BINARIES_DIR}/${RCW_FILE}
TFA_BL33 = \
       BL33=${BINARIES_DIR}/${UBOOT_BIN}
TFA_OPTS = all fip pbl

BL2_FILE = bl2_${BOOTMODE}.pbl
BL2_RCW = bl2_rcw.pbl
FIP_FILE = fip.bin
UBOOT_FILE = fip_boot.bin

define TFA_BUILD_CMDS
	make -C $(@D) ${TFA_OPTS} ${TFA_PLAT} ${TFA_BOOT_MODE} ${TFA_RCW} ${TFA_BL33} ${TFA_MAKE_OPTS}
	cp $(@D)/build/${BOARD_NAME}/release/${BL2_FILE} $(BINARIES_DIR)/${BL2_RCW}
	cp $(@D)/build/${BOARD_NAME}/release/${FIP_FILE} $(BINARIES_DIR)/${UBOOT_FILE}
endef

$(eval $(generic-package))
