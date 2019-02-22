################################################################################
#
# netopeer-cli
#
################################################################################
NETOPEER_CLIENT_VERSION = $(NETOPEER_VERSION)
# Reuse the sources of netopeer.
NETOPEER_CLIENT_SITE = $(BUILD_DIR)/netopeer-$(NETOPEER_VERSION)/cli
NETOPEER_CLIENT_SITE_METHOD = local
NETOPEER_CLIENT_LICENSE = MIT
NETOPEER_CLIENT_LICENSE_FILES = COPYING
NETOPEER_CLIENT_DEPENDENCIES = netopeer
NETOPEER_CLIENT_CONF_OPTS += --prefix=/usr/local/
NETOPEER_CLIENT_CONF_OPTS += --host=arm-buildroot-linux-gnueabihf
NETOPEER_CLIENT_CONF_OPTS += --build=x86_64-pc-linux-gnu
NETOPEER_CLIENT_CONF_OPTS += --with-libxml2=$(STAGING_DIR)/usr/bin
$(eval $(autotools-package))
