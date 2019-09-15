################################################################################
#
# mcrypt
#
################################################################################

MCRYPT_VERSION = 2.6.8
MCRYPT_SITE = http://downloads.sourceforge.net/project/mcrypt/MCrypt/$(MCRYPT_VERSION)
MCRYPT_DEPENDENCIES = libmcrypt libmhash \
	$(if $(BR2_PACKAGE_ZLIB),zlib) \
	$(if $(BR2_PACKAGE_LIBICONV),libiconv) \
	$(TARGET_NLS_DEPENDENCIES)
MCRYPT_CONF_OPTS = --with-libmcrypt-prefix=$(STAGING_DIR)/usr
MCRYPT_LICENSE = GPL-3.0
MCRYPT_LICENSE_FILES = COPYING

$(eval $(autotools-package))
