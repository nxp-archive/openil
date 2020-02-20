################################################################################
#
# qoriq-eds-bootstrap
#
################################################################################

QORIQ_EDS_BOOTSTRAP_VERSION = 72abfd9b61cc8a6d10e4808a87ff4ce1e2b99020
QORIQ_EDS_BOOTSTRAP_SITE_METHOD = git
QORIQ_EDS_BOOTSTRAP_SITE = https://github.com/NXP/qoriq-eds-bootstrap.git
QORIQ_EDS_BOOTSTRAP_LICENSE = GPLv2+

define QORIQ_EDS_BOOTSTRAP_INSTALL_TARGET_CMDS
                cd $(@D); $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
