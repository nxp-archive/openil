################################################################################
#
# fmlib
#
################################################################################

FMLIB_VERSION = LSDK-17.09
FMLIB_SITE = https://github.com/qoriq-open-source/fmlib.git
FMLIB_SITE_METHOD = git
FMLIB_LICENSE = GPL
FMLIB_LICENSE_FILES = COPYING
FMLIB_DEPENDENCIES = linux
FMLIB_INSTALL_STAGING = YES

# This package installs a static library only, so there's
# nothing to install to the target
FMLIB_INSTALL_TARGET = NO

FMLIB_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	KERNEL_SRC="$(LINUX_DIR)" \
	PREFIX="$(STAGING_DIR)/usr"

define FMLIB_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(FMLIB_MAKE_OPTS) -C $(@D) 
endef

define FMLIB_INSTALL_STAGING_CMDS
	$(RM) $(STAGING_DIR)/usr/lib/libfm.a
	$(TARGET_MAKE_ENV) $(MAKE) $(FMLIB_MAKE_OPTS) -C $(@D) install-libfm-arm
endef

$(eval $(generic-package))
