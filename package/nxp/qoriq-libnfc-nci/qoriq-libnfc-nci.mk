################################################################################
#
# qoriq-libnfc-nci
#
################################################################################

QORIQ_LIBNFC_NCI_VERSION = R2.4.1
QORIQ_LIBNFC_NCI_SITE = https://github.com/NXPNFCLinux/linux_libnfc-nci.git
QORIQ_LIBNFC_NCI_SITE_METHOD = git
QORIQ_LIBNFC_NCI_LICENSE = APACHE2.0
QORIQ_LIBNFC_NCI_LICENSE_FILES = COPYING LICENCE
QORIQ_LIBNFC_NCI_INSTALL_STAGING = YES

TARGET_NAME = $(call qstrip,$(BR2_TOOLCHAIN_EXTERNAL_PREFIX))
define QORIQ_LIBNFC_NCI_CONFIGURE_CMDS
	cd $(@D) && ./bootstrap && \
	$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(TARGET_MAKE_ENV) \
	./configure LDFLAGS=-static --host=$(TARGET_NAME)
endef

define QORIQ_LIBNFC_NCI_BUILD_CMDS
	$(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(TARGET_MAKE_ENV) $(MAKE) $(TARGET_MAKE_OPTS) -C $(@D) \
	CCLD="$(HOST_DIR)/bin/$(TARGET_NAME)-g++"
endef

define QORIQ_LIBNFC_NCI_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/data/nfc && \
		cp $(@D)/conf/*.conf $(TARGET_DIR)/data/nfc && \
		cp $(@D)/nfcDemoApp $(TARGET_DIR)/usr/bin/
endef

$(eval $(autotools-package))
