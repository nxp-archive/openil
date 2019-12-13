#################################
#
# nxp-servo
#
######################################

NXP_SERVO_VERSION = v1.0
NXP_SERVO_SITE = https://github.com/openil/nxp-servo.git
NXP_SERVO_SITE_METHOD = git
NXP_SERVO_DEPENDENCIES = igh-ethercat libxml2
NXP_SERVO_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_XENOMAI),y)
	CONFIG_INFO := XENO_CONFIG=${STAGING_DIR}/usr/bin/xeno-config
	CONFIG_INFO += XENO_DESTDIR=${STAGING_DIR}
else
	CONFIG_INFO := XENO_CONFIG=
	CONFIG_INFO += XENO_DESTDIR=
endif

CONFIG_INFO += XML2_CONFIG=${STAGING_DIR}/usr/bin/xml2-config
define NXP_SERVO_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(CONFIG_INFO) $(MAKE) -C $(@D) all
endef

define NXP_SERVO_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) $(CONFIG_INFO)  -C $(@D) DESTDIR=$(STAGING_DIR) install-libs
endef

define NXP_SERVO_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) $(CONFIG_INFO)  -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
