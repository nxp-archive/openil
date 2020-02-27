################################################################################
#
# sja1105-ptp
#
################################################################################

SJA1105_PTP_VERSION = eee6d0fb995dddf27acde2addfb1fe89b71ab82d
SJA1105_PTP_SITE = https://github.com/openil/linuxptp.git
SJA1105_PTP_SITE_METHOD = git
SJA1105_PTP_LICENSE = GPL2
SJA1105_PTP_LICENSE_FILES = COPYING

define SJA1105_PTP_BUILD_CMDS
endef

define SJA1105_PTP_INSTALL_TARGET_CMDS
	cp -dpfr $(@D)/sja1105-ptp-free-tc.sh $(TARGET_DIR)/usr/sbin/sja1105-ptp-free-tc.sh
endef

$(eval $(generic-package))
