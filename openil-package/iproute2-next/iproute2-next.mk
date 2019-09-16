################################################################################
#
# iproute2-next
#
################################################################################

IPROUTE2_NEXT_VERSION = 9b13cddfe268 # devlink: implement flash status monitoring
IPROUTE2_NEXT_SITE = https://git.kernel.org/pub/scm/network/iproute2/iproute2-next.git
IPROUTE2_NEXT_SITE_METHOD = git
IPROUTE2_NEXT_DEPENDENCIES = host-bison host-flex host-pkgconf \
	$(if $(BR2_PACKAGE_LIBMNL),libmnl)
IPROUTE2_NEXT_LICENSE = GPL-2.0+
IPROUTE2_NEXT_LICENSE_FILES = COPYING

ifeq ($(BR2_PACKAGE_ELFUTILS),y)
IPROUTE2_NEXT_DEPENDENCIES += elfutils
endif

ifeq ($(BR2_PACKAGE_IPTABLES)x$(BR2_STATIC_LIBS),yx)
IPROUTE2_NEXT_DEPENDENCIES += iptables
else
define IPROUTE2_NEXT_DISABLE_IPTABLES
	# m_xt.so is built unconditionally
	echo "TC_CONFIG_XT:=n" >>$(@D)/config.mk
endef
endif

ifeq ($(BR2_PACKAGE_BERKELEYDB_COMPAT185),y)
IPROUTE2_NEXT_DEPENDENCIES += berkeleydb
endif

define IPROUTE2_NEXT_CONFIGURE_CMDS
	cd $(@D) && $(TARGET_CONFIGURE_OPTS) ./configure
	$(IPROUTE2_NEXT_DISABLE_IPTABLES)
endef

define IPROUTE2_NEXT_BUILD_CMDS
	$(TARGET_MAKE_ENV) LDFLAGS="$(TARGET_LDFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS) -DXT_LIB_DIR=\\\"/usr/lib/xtables\\\"" \
		CBUILD_CFLAGS="$(HOST_CFLAGS)" $(MAKE) V=1 LIBDB_LIBS=-lpthread \
		DBM_INCLUDE="$(STAGING_DIR)/usr/include" \
		SHARED_LIBS="$(if $(BR2_STATIC_LIBS),n,y)" -C $(@D)
endef

define IPROUTE2_NEXT_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) DESTDIR="$(TARGET_DIR)" $(MAKE) -C $(@D) install
endef

$(eval $(generic-package))
