################################################################################
#
# qoriq-edgescale-eds
#
################################################################################

QORIQ_EDGESCALE_EDS_VERSION = 7d70a8767941aed135d609300a0594dfdc60e5ea
QORIQ_EDGESCALE_EDS_SITE_METHOD = git
QORIQ_EDGESCALE_EDS_SITE = https://github.com/NXP/qoriq-edgescale-eds.git
QORIQ_EDGESCALE_EDS_LICENSE = GPLv2+

QORIQ_EDGESCALE_EDS_DEPENDENCIES = host-go host-pkgconf

QORIQ_EDGESCALE_EDS_GOPATH = "$(@D)/vendor"
QORIQ_EDGESCALE_EDS_MAKE_ENV = $(HOST_GO_TARGET_ENV) \
        CGO_ENABLED=1 \
        CGO_NO_EMULATION=1 \
        GOBIN="$(@D)/bin" \
        GOPATH="$(QORIQ_EDGESCALE_EDS_GOPATH)" \
        PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
        $(TARGET_MAKE_ENV)


define QORIQ_EDGESCALE_EDS_BUILD_CMDS
                cd $(@D); $(QORIQ_EDGESCALE_EDS_MAKE_ENV) \
                        $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR)
endef

define QORIQ_EDGESCALE_EDS_INSTALL_TARGET_CMDS
                cd $(@D); $(QORIQ_EDGESCALE_EDS_MAKE_ENV) \
			$(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
