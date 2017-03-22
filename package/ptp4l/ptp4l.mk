################################################################################
#
# ptp application for Linux
#
################################################################################

PTP4L_VERSION = master
PTP4L_SITE = http://sw-stash.freescale.net/scm/dnind/linux-ptp.git
PTP4L_SITE_METHOD = git
PTP4L_LICENSE = GPL2
PTP4L_LICENSE_FILES = COPYING

define PTP4L_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D)
endef

define PTP4L_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/ptp4l $(TARGET_DIR)/usr/sbin/ptp4l
	cp -dpfr $(@D)/ptp4l_default.cfg $(TARGET_DIR)/etc/
endef

$(eval $(generic-package))
