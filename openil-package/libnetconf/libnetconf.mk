################################################################################
#
# libnetconf
#
################################################################################

LIBNETCONF_VERSION = 313fdadd1542 # Merge pull request #280 from adamjrichter/master
LIBNETCONF_SITE = https://github.com/CESNET/libnetconf.git
LIBNETCONF_SITE_METHOD = git
LIBNETCONF_INSTALL_STAGING = YES
LIBNETCONF_LICENSE = MIT
LIBNETCONF_LICENSE_FILES = COPYING
LIBNETCONF_CONF_OPTS += --with-rpm
HOST_LIBNETCONF_DEPENDENCIES = host-pkgconf host-pyang host-xsltproc
LIBNETCONF_DEPENDENCIES  = openssl libgcrypt libssh libxslt ncurses readline
LIBNETCONF_DEPENDENCIES += dbus host-pyang host-h-python-libxml2 libcurl
LIBNETCONF_CONF_ENV += PKG_CONFIG=$(HOST_DIR)/usr/bin/pkg-config
LIBNETCONF_CONF_ENV += enable_validation=no
LIBNETCONF_AUTORECONF := YES

define LIBNETCONF_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/dev-tools/lnctool/lnctool $(HOST_DIR)/usr/bin
	sed -i '1c\#!$(HOST_DIR)/usr/bin/python'  $(HOST_DIR)/usr/bin/lnctool
	$(INSTALL) -D -m 0755 $(@D)/.libs/libnetconf.so* $(STAGING_DIR)/usr/lib/
	$(INSTALL) -D -m 0755 $(@D)/headers/*.h $(STAGING_DIR)/usr/include
	mkdir -p $(STAGING_DIR)/usr/include/libnetconf
	$(INSTALL) -D -m 0755 $(@D)/src/*.h $(STAGING_DIR)/usr/include/libnetconf/
	$(INSTALL) -D -m 0755 $(@D)/src/datastore/custom/datastore_custom.h $(STAGING_DIR)/usr/include/libnetconf/
	$(INSTALL) -D -m 0755 $(@D)/libnetconf.pc $(STAGING_DIR)/usr/lib/pkgconfig/
endef

$(eval $(autotools-package))
#$(eval $(host-autotools-package))

