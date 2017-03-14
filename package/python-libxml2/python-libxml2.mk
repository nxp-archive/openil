################################################################################
#
# python-libxml2
#
################################################################################
PYTHON_LIBXML2_VERSION = $(LIBXML2_VERSION)
PYTHON_LIBXML2_SITE = $(BUILD_DIR)/libxml2-$(LIBXML2_VERSION)/python
PYTHON_LIBXML2_SITE_METHOD = local
PYTHON_LIBXML2_LICENSE = MIT
PYTHON_LIBXML2_LICENSE_FILES = COPYING
PYTHON_LIBXML2_SETUP_TYPE = distutils
PYTHON_LIBXML2_DEPENDENCIES = libxml2

define PYTHON_LIBXML2_CONFIGURE_CMDS
	$(APPLY_PATCHES) $(@D) package/python-libxml2 0001-python-libxml2-Add-python-libxml2-support-on-target-.patch
	echo "python_libxml2_lib_dir = $(STAGING_DIR)/usr/lib" >> $(@D)/Setup
	echo "python_libxml2_include_dir = $(STAGING_DIR)/usr/include" >> $(@D)/Setup
endef

$(eval $(python-package))
