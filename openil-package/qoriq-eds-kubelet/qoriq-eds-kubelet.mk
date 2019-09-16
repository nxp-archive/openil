###############################################################################
#
# qoriq-eds-kubelet
#
################################################################################

QORIQ_EDS_KUBELET_VERSION = cf5175b3186e1308cc29a6295fb7bd012b614a22
QORIQ_EDS_KUBELET_SITE_METHOD = git
QORIQ_EDS_KUBELET_SITE = https://github.com/NXP/qoriq-eds-kubelet.git
QORIQ_EDS_KUBELET_LICENSE = GPLv2+

QORIQ_EDS_KUBELET_DEPENDENCIES = host-go host-pkgconf

QORIQ_EDS_KUBELET_GOPATH = "$(@D)"
QORIQ_EDS_KUBELET_MAKE_ENV = $(HOST_GO_TARGET_ENV) \
	CGO_ENABLED=1 \
	CGO_NO_EMULATION=1 \
	GOBIN="$(@D)/bin" \
	GOPATH="$(QORIQ_EDS_KUBELET_GOPATH)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	$(TARGET_MAKE_ENV)


define QORIQ_EDS_KUBELET_BUILD_CMDS
		cd $(@D); $(QORIQ_EDS_KUBELET_MAKE_ENV) \
			$(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR)
endef

define QORIQ_EDS_KUBELET_INSTALL_TARGET_CMDS
		cd $(@D); $(QORIQ_EDS_KUBELET_MAKE_ENV) \
			$(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
