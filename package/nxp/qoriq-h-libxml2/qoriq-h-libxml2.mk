################################################################################
#
# qoriq-h-libxml2
#
################################################################################

QORIQ_H_LIBXML2_VERSION = $(LIBXML2_VERSION)
QORIQ_H_LIBXML2_SOURCE = libxml2-$(QORIQ_H_LIBXML2_VERSION).tar.gz
QORIQ_H_LIBXML2_SITE = http://xmlsoft.org/sources
QORIQ_H_LIBXML2_LICENSE = MIT
QORIQ_H_LIBXML2_LICENSE_FILES = COPYING
QORIQ_H_LIBXML2_CONFIG_SCRIPTS = xml2-config

# relocation truncated to fit: R_68K_GOT16O
ifeq ($(BR2_m68k_cf),y)
QORIQ_H_LIBXML2_CONF_ENV += CFLAGS="$(TARGET_CFLAGS) -mxgot"
endif

QORIQ_H_LIBXML2_CONF_OPTS = --with-gnu-ld --without-python --without-debug

HOST_QORIQ_H_LIBXML2_DEPENDENCIES = host-pkgconf
QORIQ_H_LIBXML2_DEPENDENCIES = host-pkgconf

HOST_QORIQ_H_LIBXML2_CONF_OPTS = --without-zlib --without-lzma --without-python

ifeq ($(BR2_PACKAGE_ZLIB),y)
QORIQ_H_LIBXML2_DEPENDENCIES += zlib
QORIQ_H_LIBXML2_CONF_OPTS += --with-zlib=$(STAGING_DIR)/usr
else
QORIQ_H_LIBXML2_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_XZ),y)
QORIQ_H_LIBXML2_DEPENDENCIES += xz
QORIQ_H_LIBXML2_CONF_OPTS += --with-lzma
else
QORIQ_H_LIBXML2_CONF_OPTS += --without-lzma
endif

QORIQ_H_LIBXML2_DEPENDENCIES += $(if $(BR2_PACKAGE_LIBICONV),libiconv)

ifeq ($(BR2_ENABLE_LOCALE)$(BR2_PACKAGE_LIBICONV),y)
QORIQ_H_LIBXML2_CONF_OPTS += --with-iconv
else
QORIQ_H_LIBXML2_CONF_OPTS += --without-iconv
endif

$(eval $(host-autotools-package))
