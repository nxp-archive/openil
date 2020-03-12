################################################################################
#
# qoriq-python-libxml2
#
################################################################################

QORIQ_PYTHON_LIBXML2_VERSION = $(LIBXML2_VERSION)
QORIQ_PYTHON_LIBXML2_SITE = $(BUILD_DIR)/libxml2-$(LIBXML2_VERSION)/python
QORIQ_PYTHON_LIBXML2_SITE_METHOD = local
QORIQ_PYTHON_LIBXML2_LICENSE = MIT
QORIQ_PYTHON_LIBXML2_LICENSE_FILES = COPYING
QORIQ_PYTHON_LIBXML2_SETUP_TYPE = distutils
QORIQ_PYTHON_LIBXML2_DEPENDENCIES = libxml2
define QORIQ_PYTHON_LIBXML2_CONFIGURE_CMDS
	$(APPLY_PATCHES) $(@D) package/nxp/qoriq-python-libxml2 0001-python-libxml2-Add-python-libxml2-support-on-target-.patch
	echo "python_libxml2_lib_dir = $(STAGING_DIR)/usr/lib" >> $(@D)/Setup
	echo "python_libxml2_include_dir = $(STAGING_DIR)/usr/include" >> $(@D)/Setup
endef

define QORIQ_PYTHON_LIBXML2_POST_INSTALL_TARGET_FIXUP
	$(INSTALL) -D -m 0755 $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/libxml2.py* $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/
	$(INSTALL) -D -m 0755 $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/libxml2mod.so $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/
	$(INSTALL) -D -m 0755 $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/drv_libxml2.py* $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/
	rm $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/*libxml2*
endef

QORIQ_PYTHON_LIBXML2_POST_INSTALL_TARGET_HOOKS +=QORIQ_PYTHON_LIBXML2_POST_INSTALL_TARGET_FIXUP

$(eval $(python-package))
