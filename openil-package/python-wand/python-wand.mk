################################################################################
#
# python-wand
#
################################################################################
PYTHON_WAND_VERSION = 0.4.4
PYTHON_WAND_SITE = https://github.com/emcconville/wand.git
PYTHON_WAND_SITE_METHOD = git
PYTHON_WAND_LICENSE = MIT
PYTHON_WAND_LICENSE_FILES = LICENSE
PYTHON_WAND_SETUP_TYPE = setuptools

$(eval $(python-package))
$(eval $(host-python-package))
