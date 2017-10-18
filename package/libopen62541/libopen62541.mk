################################################################################
#
# libopen62541
#
################################################################################

LIBOPEN62541_VERSION = v0.2
LIBOPEN62541_SITE = https://github.com/open62541/open62541.git
LIBOPEN62541_SITE_METHOD = git
LIBOPEN62541_LICENSE = MOZILLA
LIBOPEN62541_LICENSE_FILES = LICENSE
LIBOPEN62541_INSTALL_STAGING = YES
LIBOPEN62541_CONF_OPTS = -DUA_ENABLE_AMALGAMATION=ON

$(eval $(cmake-package))

