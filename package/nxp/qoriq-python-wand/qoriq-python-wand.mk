################################################################################
#
# qoriq-python-wand
#
################################################################################

QORIQ_PYTHON_WAND_VERSION = 0.4.4
QORIQ_PYTHON_WAND_SITE = https://github.com/emcconville/wand.git
QORIQ_PYTHON_WAND_SITE_METHOD = git
QORIQ_PYTHON_WAND_LICENSE = MIT
QORIQ_PYTHON_WAND_LICENSE_FILES = LICENSE
QORIQ_PYTHON_WAND_SETUP_TYPE = setuptools

$(eval $(python-package))
$(eval $(host-python-package))
