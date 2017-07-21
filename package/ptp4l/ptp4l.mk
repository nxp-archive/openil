################################################################################
#
# ptp application for Linux
#
################################################################################

PTP4L_VERSION = OpenIL-linuxptp-201705
PTP4L_SITE = https://github.com/openil/linuxptp.git
PTP4L_SITE_METHOD = git
PTP4L_LICENSE = GPL2
PTP4L_LICENSE_FILES = COPYING
ifeq ($(BR2_PACKAGE_SJA1105_TOOL),y)
PTP4L_DEPENDENCIES = sja1105-tool
SJA1105_OUTPUT=$(STAGING_DIR)
endif

PTP4L_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \

define PTP4L_BUILD_CMDS
	export PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)"; \
	export KBUILD_OUTPUT="$(STAGING_DIR)"; \
	export SJA1105_ROOTDIR="$(SJA1105_OUTPUT)"; \
	$(TARGET_MAKE_ENV) $(MAKE1) $(PTP4L_MAKE_OPTS) -C $(@D)
endef

define PTP4L_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/ptp4l $(TARGET_DIR)/usr/sbin/ptp4l
	cp -dpfr $(@D)/ptp4l_default.cfg $(TARGET_DIR)/etc/
endef

$(eval $(generic-package))
