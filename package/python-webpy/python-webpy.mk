################################################################################
#
# python-webpy
#
################################################################################

PYTHON_WEBPY_VERSION = 0.39
PYTHON_WEBPY_SITE = $(call github,webpy,webpy,webpy-$(PYTHON_WEBPY_VERSION))
PYTHON_WEBPY_SETUP_TYPE = setuptools
PYTHON_WEBPY_LICENSE = Public Domain, CherryPy License
PYTHON_WEBPY_LICENSE_FILES = LICENSE.txt web/wsgiserver/LICENSE.txt

$(eval $(python-package))
