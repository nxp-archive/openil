################################################################################
#
# sja1105-ptp
#
################################################################################

SJA1105_PTP_VERSION = master
SJA1105_PTP_SITE = https://github.com/openil/linuxptp.git
SJA1105_PTP_SITE_METHOD = git
SJA1105_PTP_LICENSE = GPL2
SJA1105_PTP_LICENSE_FILES = COPYING
ifeq ($(BR2_PACKAGE_SJA1105_TOOL),y)
SJA1105_PTP_DEPENDENCIES = sja1105-tool
SJA1105_OUTPUT=$(STAGING_DIR)/usr
endif

SJA1105_PTP_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	SJA1105_ROOTDIR="$(SJA1105_OUTPUT)" \
	SJA1105_PTP_TC=y \

define SJA1105_PTP_BUILD_CMDS
	export PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)"; \
	export KBUILD_OUTPUT="$(STAGING_DIR)"; \
	$(TARGET_MAKE_ENV) $(MAKE1) $(SJA1105_PTP_MAKE_OPTS) -C $(@D)
endef

define SJA1105_PTP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/sja1105-ptp $(TARGET_DIR)/usr/sbin/sja1105-ptp
	cp -dpfr $(@D)/sja1105-ptp-tc.sh $(TARGET_DIR)/usr/sbin/sja1105-ptp-tc.sh
endef

$(eval $(generic-package))
