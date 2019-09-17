################################################################################
#
# python-pyang
#
################################################################################

PYANG_VERSION = pyang-2.0.1
PYANG_SITE = https://github.com/mbj4668/pyang.git 
PYANG_SITE_METHOD = git
PYANG_INSTALL_STAGING = YES
PYANG_LICENSE = MIT
PYANG_LICENSE_FILES = COPYING
PYANG_SETUP_TYPE = setuptools
HOST_PYANG_DEPENDENCIES = host-python-lxml host-libxslt
PYANG_DEPENDENCIES = python-lxml python

define PYANG_INSTALL_STAGING_CMDS
	export PYTHONPATH=$(HOST_DIR)/usr/lib/python2.7/site-packages
	cd $(@D);$(HOST_DIR)/usr/bin/python $(@D)/setup.py install --prefix=$(HOST_DIR)/usr
endef

$(eval $(python-package))
$(eval $(host-python-package))

