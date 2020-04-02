################################################################################
#
# qoriq-python-wand
#
################################################################################

QORIQ_PYTHON_WAND_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_PYTHON_WAND_VERSION))
QORIQ_PYTHON_WAND_SITE = https://github.com/emcconville/wand.git
QORIQ_PYTHON_WAND_SITE_METHOD = git
QORIQ_PYTHON_WAND_LICENSE = MIT
QORIQ_PYTHON_WAND_LICENSE_FILES = LICENSE
QORIQ_PYTHON_WAND_SETUP_TYPE = setuptools

$(eval $(python-package))
$(eval $(host-python-package))
