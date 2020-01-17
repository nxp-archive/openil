################################################################################
#
# sysrepo tsn application
#
################################################################################

SYSREPO_TSN_VERSION = v0.1
SYSREPO_TSN_SITE = ssh://git@bitbucket.sw.nxp.com/dnind/sysrepo-tsn.git
SYSREPO_TSN_SITE_METHOD = git
SYSREPO_TSN_LICENSE = GPL2.0
SYSREPO_TSN_LICENSE_FILES = LICENSE
SYSREPO_TSN_DEPENDENCIES = netopeer2-server tsntool yang-model cjson

SYSREPO_TSN_MAKE_ENV = LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib:$(HOST_DIR)/lib

# copying models from standard model repo
define SYSREPO_TSN_COPY_BRIDGE_MODELS
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-interfaces@2014-05-08.yang \
		$(@D)/modules/ietf-interfaces@2014-05-08.yang;
	$(INSTALL) -D -t $(@D)/modules $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/draft/802.1/Qcw/*;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-yang-types.yang \
		$(@D)/modules/ietf-yang-types.yang;
	$(INSTALL) -D -m 0755   $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/published/802.1/ieee802-dot1q-types.yang \
		$(@D)/modules/ieee802-dot1q-types.yang;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/published/802/ieee802-types.yang \
		$(@D)/modules/ieee802-types.yang;
	$(INSTALL) -D -t $(@D)/modules $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/published/802.1/*;
	$(INSTALL) -D -t $(@D)/modules $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/draft/802.1/Qcr/*;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-inet-types@2013-07-15.yang \
		$(@D)/modules/ietf-inet-types@2013-07-15.yang;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ietf/RFC/iana-if-type@2017-01-19.yang \
		$(@D)/modules/iana-if-type@2017-01-19.yang;
endef

define SYSREPO_TSN_INSTALL_INIT_SYSV
	$(INSTALL) -m 755 -D package/sysrepo-tsn/S52sysrepo-tsn \
		$(TARGET_DIR)/etc/init.d/S52sysrepo-tsn
endef

SYSREPO_TSN_PRE_CONFIGURE_HOOKS += SYSREPO_TSN_COPY_BRIDGE_MODELS

$(eval $(cmake-package))
