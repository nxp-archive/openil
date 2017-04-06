################################################################################
#
# h-python-libxml2
#
################################################################################
H_PYTHON_LIBXML2_VERSION = $(LIBXML2_VERSION)
H_PYTHON_LIBXML2_SITE = $(BUILD_DIR)/libxml2-$(LIBXML2_VERSION)/python
H_PYTHON_LIBXML2_SITE_METHOD = local
H_PYTHON_LIBXML2_LICENSE = MIT
H_PYTHON_LIBXML2_LICENSE_FILES = COPYING
H_PYTHON_LIBXML2_SETUP_TYPE = distutils
H_PYTHON_LIBXML2_DEPENDENCIES = libxml2

#define PYTHON_LIBXML2_POST_INSTALL_TARGET_FIXUP
#	$(INSTALL) -D -m 0755 $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/libxml2.py* $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/
#	$(INSTALL) -D -m 0755 $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/libxml2mod.so $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/ 
#	$(INSTALL) -D -m 0755 $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/drv_libxml2.py* $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/
#    	rm $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/*libxml2*
#endef

#PYTHON_LIBXML2_POST_INSTALL_TARGET_HOOKS +=PYTHON_LIBXML2_POST_INSTALL_TARGET_FIXUP

$(eval $(host-python-package))
