################################################################################
#
# qoriq-sysrepo-tsn
#
################################################################################

QORIQ_SYSREPO_TSN_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_SYSREPO_TSN_VERSION))
QORIQ_SYSREPO_TSN_SITE = $(call qstrip,$(BR2_PACKAGE_QORIQ_SYSREPO_TSN_SITE))
QORIQ_SYSREPO_TSN_SITE_METHOD = git
QORIQ_SYSREPO_TSN_LICENSE = GPL2.0
QORIQ_SYSREPO_TSN_LICENSE_FILES = LICENSE
QORIQ_SYSREPO_TSN_DEPENDENCIES = qoriq-netopeer2-server qoriq-tsntool qoriq-yang-model cjson

QORIQ_SYSREPO_TSN_MAKE_ENV = LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib:$(HOST_DIR)/lib
ifeq ($(BR2_PACKAGE_QORIQ_SYSREPO_TSN_TC),y)
QORIQ_SYSREPO_TSN_CONF_OPTS += -DCONF_SYSREPO_TSN_TC=true
endif

# copying models from standard model repo
define QORIQ_SYSREPO_TSN_COPY_BRIDGE_MODELS
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/qoriq-yang-model-$(QORIQ_YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-interfaces@2014-05-08.yang \
		$(@D)/modules/ietf-interfaces@2014-05-08.yang;
	$(INSTALL) -D -t $(@D)/modules $(BUILD_DIR)/qoriq-yang-model-$(QORIQ_YANG_MODEL_VERSION)/standard/ieee/draft/802.1/Qcw/*;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/qoriq-yang-model-$(QORIQ_YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-yang-types.yang \
		$(@D)/modules/ietf-yang-types.yang;
	$(INSTALL) -D -m 0755   $(BUILD_DIR)/qoriq-yang-model-$(QORIQ_YANG_MODEL_VERSION)/standard/ieee/published/802.1/ieee802-dot1q-types.yang \
		$(@D)/modules/ieee802-dot1q-types.yang;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/qoriq-yang-model-$(QORIQ_YANG_MODEL_VERSION)/standard/ieee/published/802/ieee802-types.yang \
		$(@D)/modules/ieee802-types.yang;
	$(INSTALL) -D -t $(@D)/modules $(BUILD_DIR)/qoriq-yang-model-$(QORIQ_YANG_MODEL_VERSION)/standard/ieee/published/802.1/*;
	$(INSTALL) -D -t $(@D)/modules $(BUILD_DIR)/qoriq-yang-model-$(QORIQ_YANG_MODEL_VERSION)/standard/ieee/draft/802.1/Qcr/*;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/qoriq-yang-model-$(QORIQ_YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-inet-types@2013-07-15.yang \
		$(@D)/modules/ietf-inet-types@2013-07-15.yang;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/qoriq-yang-model-$(QORIQ_YANG_MODEL_VERSION)/standard/ietf/RFC/iana-if-type@2017-01-19.yang \
		$(@D)/modules/iana-if-type@2017-01-19.yang;
endef

define QORIQ_SYSREPO_TSN_INSTALL_INIT_SYSV
	$(INSTALL) -m 755 -D package/nxp/qoriq-sysrepo-tsn/S52sysrepo-tsn \
		$(TARGET_DIR)/etc/init.d/S52sysrepo-tsn
endef

define QORIQ_SYSREPO_TSN_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 package/nxp/qoriq-sysrepo-tsn/sysrepo-tsn.service \
		$(TARGET_DIR)/usr/lib/systemd/system/sysrepo-tsn.service
endef

QORIQ_SYSREPO_TSN_PRE_CONFIGURE_HOOKS += QORIQ_SYSREPO_TSN_COPY_BRIDGE_MODELS

$(eval $(cmake-package))
