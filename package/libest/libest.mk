################################################################################
#
# libest
#
################################################################################

LIBEST_VERSION = 1.1.0
LIBEST_SITE = https://github.com/cisco/libest.git 
LIBEST_SITE_METHOD = git
LIBEST_LICENSE = Cisco Systems, Inc.
LIBEST_LICENSE_FILES = LICENSE COPYING
LIBEST_DEPENDENCIES = openssl

define LIBEST_RUN_CONFIG
	cd $(@D)/ && ./configure
endef
LIBEST_POST_EXTRACT_HOOKS += LIBEST_RUN_CONFIG

$(eval $(autotools-package))
