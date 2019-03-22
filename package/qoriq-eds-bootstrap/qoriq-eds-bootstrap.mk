################################################################################
#
# qoriq-eds-bootstrap
#
################################################################################

QORIQ_EDS_BOOTSTRAP_VERSION = master
QORIQ_EDS_BOOTSTRAP_SITE_METHOD = git
QORIQ_EDS_BOOTSTRAP_SITE = ssh://git@bitbucket.sw.nxp.com/dcca/qoriq-eds-bootstrap.git
QORIQ_EDS_BOOTSTRAP_LICENSE = GPLv2+

define QORIQ_EDS_BOOTSTRAP_INSTALL_TARGET_CMDS
                cd $(@D); $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
