################################################################################
#
# H_LIBXML2
#
################################################################################

H_LIBXML2_VERSION = $(LIBXML2_VERSION)
H_LIBXML2_SOURCE = libxml2-$(H_LIBXML2_VERSION).tar.gz
H_LIBXML2_SITE = ftp://xmlsoft.org/libxml2
H_LIBXML2_LICENSE = MIT
H_LIBXML2_LICENSE_FILES = COPYING
H_LIBXML2_CONFIG_SCRIPTS = xml2-config

# relocation truncated to fit: R_68K_GOT16O
ifeq ($(BR2_m68k_cf),y)
H_LIBXML2_CONF_ENV += CFLAGS="$(TARGET_CFLAGS) -mxgot"
endif

H_LIBXML2_CONF_OPTS = --with-gnu-ld --without-python --without-debug

HOST_H_LIBXML2_DEPENDENCIES = host-pkgconf
H_LIBXML2_DEPENDENCIES = host-pkgconf

HOST_H_LIBXML2_CONF_OPTS = --without-zlib --without-lzma --without-python

ifeq ($(BR2_PACKAGE_ZLIB),y)
H_LIBXML2_DEPENDENCIES += zlib
H_LIBXML2_CONF_OPTS += --with-zlib=$(STAGING_DIR)/usr
else
H_LIBXML2_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_XZ),y)
H_LIBXML2_DEPENDENCIES += xz
H_LIBXML2_CONF_OPTS += --with-lzma
else
H_LIBXML2_CONF_OPTS += --without-lzma
endif

H_LIBXML2_DEPENDENCIES += $(if $(BR2_PACKAGE_LIBICONV),libiconv)

ifeq ($(BR2_ENABLE_LOCALE)$(BR2_PACKAGE_LIBICONV),y)
H_LIBXML2_CONF_OPTS += --with-iconv
else
H_LIBXML2_CONF_OPTS += --without-iconv
endif

$(eval $(host-autotools-package))
