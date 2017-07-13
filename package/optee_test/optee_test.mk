################################################################################
#
# optee_test
#
################################################################################

OPTEE_TEST_VERSION = 2.4.0
OPTEE_TEST_SITE = https://github.com/OP-TEE/optee_test.git
OPTEE_TEST_SITE_METHOD = git
OPTEE_TEST_LICENSE =  GPL-2.0
OPTEE_TEST_LICENSE_FILES = LICENSE.md
OPTEE_TEST_DEPENDENCIES = optee_client optee_os

OPTEE_TEST_MAKE_OPTS = \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	TA_DEV_KIT_DIR="$(BUILD_DIR)/optee_os-$(OPTEE_OS_VERSION)/out/arm-plat-ls/export-ta_arm32" \
	OPTEE_CLIENT_EXPORT="$(BUILD_DIR)/optee_client-$(OPTEE_CLIENT_VERSION)/out/export" \
	CFG_ARM32=y

define OPTEE_TEST_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(OPTEE_TEST_MAKE_OPTS) -C $(@D)
endef

define OPTEE_TEST_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install DESTDIR=$(TARGET_DIR)
endef

$(eval $(generic-package))
