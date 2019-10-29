############################
## Ethernet PHY firmware
############################

ETH_PHY_VERSION = LSDK-19.09
ETH_PHY_SITE = https://github.com/NXP/qoriq-firmware-inphi.git
ETH_PHY_SITE_METHOD = git
ETH_PHY_LICENSE = GPL2.0

ETH_BIN = in112525-phy-ucode.txt
ETH_PHY_FILE = phy-ucode.txt

define ETH_PHY_BUILD_CMDS
	cp $(@D)/${ETH_BIN} $(BINARIES_DIR)/${ETH_PHY_FILE}
endef

$(eval $(generic-package))
