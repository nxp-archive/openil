################################################################################
#
# olsr
#
################################################################################

OLSR_VERSION_MAJOR = 0.9
OLSR_VERSION = $(OLSR_VERSION_MAJOR).6.1
OLSR_SOURCE = olsrd-$(OLSR_VERSION).tar.bz2
OLSR_SITE = http://www.olsr.org/releases/$(OLSR_VERSION_MAJOR)
OLSR_PLUGINS = arprefresh bmf dot_draw dyn_gw dyn_gw_plain httpinfo jsoninfo \
	mdns nameservice p2pd pgraph secure txtinfo watchdog
# Doesn't really need quagga but not very useful without it
OLSR_PLUGINS += $(if $(BR2_PACKAGE_QUAGGA),quagga)
OLSR_LICENSE = BSD-3-Clause, LGPL-2.1+
OLSR_LICENSE_FILES = license.txt lib/pud/nmealib/LICENSE
OLSR_DEPENDENCIES = host-flex host-bison

define OLSR_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) ARCH=$(KERNEL_ARCH) -C $(@D) olsrd
	for p in $(OLSR_PLUGINS) ; do \
		$(TARGET_CONFIGURE_OPTS) $(MAKE) ARCH=$(KERNEL_ARCH) -C $(@D)/lib/$$p ; \
	done
endef

define OLSR_INSTALL_TARGET_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) \
		prefix="/usr" install_bin
	for p in $(OLSR_PLUGINS) ; do \
		$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/lib/$$p \
			LDCONFIG=/bin/true DESTDIR=$(TARGET_DIR) \
			prefix="/usr" install ; \
	done
	$(INSTALL) -D -m 0644 $(@D)/files/olsrd.conf.default.lq \
		$(TARGET_DIR)/etc/olsrd/olsrd.conf
endef

define OLSR_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/olsr/S50olsr \
		$(TARGET_DIR)/etc/init.d/S50olsr
endef

define OLSR_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/olsr/olsr.service \
		$(TARGET_DIR)/usr/lib/systemd/system/olsr.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -sf ../../../../usr/lib/systemd/system/olsr.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/olsr.service
endef

$(eval $(generic-package))
