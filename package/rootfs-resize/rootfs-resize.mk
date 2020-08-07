################################################################################
#
# rootfs-resize
#
################################################################################

ROOTFS_RESIZE_VERSION = 0.1
ROOTFS_RESIZE_SITE = package/rootfs-resize/src
ROOTFS_RESIZE_SITE_METHOD = local

define ROOTFS_RESIZE_INSTALL_INIT_SYSV
	$(INSTALL) -m 755 -D $(@D)/S60rootfs-resize $(TARGET_DIR)/etc/init.d/
endef

define ROOTFS_RESIZE_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 755 -D $(@D)/S60rootfs-resize $(TARGET_DIR)/etc/init.d/
	$(INSTALL) -m 644 -D $(@D)/systemd-rootfs-resize.service $(TARGET_DIR)/usr/lib/systemd/system/
endef

$(eval $(generic-package))
