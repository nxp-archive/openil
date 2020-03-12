################################################################################
#
# qoriq-h-python-libxml2
#
################################################################################

QORIQ_H_PYTHON_LIBXML2_VERSION = $(LIBXML2_VERSION)
QORIQ_H_PYTHON_LIBXML2_SITE = $(BUILD_DIR)/libxml2-$(LIBXML2_VERSION)/python
QORIQ_H_PYTHON_LIBXML2_SITE_METHOD = local
QORIQ_H_PYTHON_LIBXML2_LICENSE = MIT
QORIQ_H_PYTHON_LIBXML2_LICENSE_FILES = COPYING
QORIQ_H_PYTHON_LIBXML2_SETUP_TYPE = distutils
QORIQ_H_PYTHON_LIBXML2_DEPENDENCIES = libxml2 host-qoriq-h-libxml2
HOST_QORIQ_H_PYTHON_LIBXML2_DEPENDENCIES = libxml2 host-qoriq-h-libxml2
HOST_QORIQ_H_PYTHON_LIBXML2_ENV += HOME="$(HOST_DIR)/usr/include/"

$(eval $(host-python-package))
