################################################################################
#
# qoriq-eth-phy
#
################################################################################

QORIQ_ETH_PHY_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_ETH_PHY_VERSION))
QORIQ_ETH_PHY_SITE = https://github.com/NXP/qoriq-firmware-inphi.git
QORIQ_ETH_PHY_SITE_METHOD = git
QORIQ_ETH_PHY_LICENSE = GPL2.0
QORIQ_ETH_PHY_INSTALL_STAGING = YES

ETH_BIN = in112525-phy-ucode.txt
ETH_PHY_FILE = phy-ucode.txt

define QORIQ_ETH_PHY_INSTALL_STAGING_CMDS
	$(INSTALL) -D $(@D)/${ETH_BIN} $(BINARIES_DIR)/${ETH_PHY_FILE}
endef

$(eval $(generic-package))
