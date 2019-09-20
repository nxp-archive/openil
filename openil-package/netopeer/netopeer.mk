################################################################################
#
# netopeer-cli/netopeer-server
#
################################################################################

NETOPEER_VERSION = ead52915c138 # DOC update README - deprecate Netopeer and advice to move to Netopeer2
NETOPEER_SITE = https://github.com/CESNET/netopeer.git
NETOPEER_SITE_METHOD = git
NETOPEER_LICENSE = MIT
NETOPEER_LICENSE_FILES = COPYING
NETOPEER_INSTALL_STAGING = YES
NETOPEER_DEPENDENCIES = pyang libnetconf libssh
NETOPEER_SUBDIR=server

define NETOPEER_INSTALL_DATASTORE
	$(INSTALL) -D -m 0755 $(NETOPEER_PKGDIR)/datastore.xml \
		$(TARGET_DIR)/etc/netopeer/cfgnetopeer/datastore.xml
endef

define NETOPEER_INSTALL_NETOPEER_MANAGER_HOST
	$(INSTALL) -D -m 0755 $(NETOPEER_PKGDIR)/netopeer-manager.host \
		$(HOST_DIR)/usr/bin/netopeer-manager.host
	$(INSTALL) -D -m 0755 $(NETOPEER_PKGDIR)/S90netconf \
		$(TARGET_DIR)/etc/init.d/S90netconf
endef
# edit and install environment init script by build type
ifeq ($(BR2_ROOTFS_SKELETON_CUSTOM),y)
define NETOPEER_INSTALL_NETOPEER_SET_ENV
	sed -i '1d' $(TARGET_DIR)/usr/bin/netopeer-configurator
	sed -i '1i\#!\/usr\/bin\/python' $(TARGET_DIR)/usr/bin/netopeer-configurator
	rm -f $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
	$(INSTALL) -D -m 0755 $(NETOPEER_PKGDIR)/setenvfornetopeer.sh \
		$(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
	sed -i "/^#2/ a\export PYTHONPATH=/usr/local/lib/python$(PYTHON_VERSION_MAJOR)/site-packages" \
		$(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
endef
else
define NETOPEER_INSTALL_NETOPEER_SET_ENV
	sed -i '1d' $(TARGET_DIR)/usr/bin/netopeer-configurator
	sed -i '1i\#!\/usr\/bin\/python' $(TARGET_DIR)/usr/bin/netopeer-configurator
	rm -f $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
	$(INSTALL) -D -m 0755 $(NETOPEER_PKGDIR)/setenvfornetopeer.sh \
		$(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
	sed -i '/^#1/ a\export PATH=$$PATH:/usr/bin' $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
	sed -i "/^#2/ a\export PYTHONPATH=/usr/local/lib/python$(PYTHON_VERSION_MAJOR)/site-packages" $(TARGET_DIR)/etc/profile.d/setenvfornetopeer.sh
endef
endif
NETOPEER_POST_INSTALL_TARGET_HOOKS +=NETOPEER_INSTALL_DATASTORE
NETOPEER_POST_INSTALL_TARGET_HOOKS +=NETOPEER_INSTALL_NETOPEER_MANAGER_HOST
NETOPEER_POST_INSTALL_TARGET_HOOKS +=NETOPEER_INSTALL_NETOPEER_SET_ENV

$(eval $(autotools-package))
