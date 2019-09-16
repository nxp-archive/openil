################################################################################
#
# transapi
#
################################################################################

TRANSAPI_VERSION = v0.1
TRANSAPI_SITE = https://github.com/openil/transAPI.git
TRANSAPI_SITE_METHOD = git
TRANSAPI_LICENSE = MIT/GPL2.0
TRANSAPI_LICENSE_FILES = LICENSE
# if use libtool to install libraries, flowing command is necessary
TRANSAPI_AUTORECONF = YES
TRANSAPI_DEPENDENCIES = libxml2 pyang libnetconf netopeer tsntool yang-model
TRANSAPI_CONF_ENV += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"
TRANSAPI_CONF_ENV += PYTHON_CONFIG="$(STAGING_DIR)/usr/bin/python-config"
TRANSAPI_CONF_ENV += ac_cv_path_NETOPEER_MANAGER="$(HOST_DIR)/usr/bin/netopeer-manager.host"

LIBNL_HEADER_DIR = $(HOST_DIR)/usr/aarch64-buildroot-linux-gnu/sysroot/usr/include/libnl3
TSNTOOL_HEADER_DIR = $(BUILD_DIR)/tsntool-$(TSNTOOL_VERSION)/include

HOST_MODEL_DIR := $(TARGET_DIR)/usr/local/etc/netopeer/transapi/
TARGET_MODEL_DIR := /usr/local/etc/netopeer/transapi/
TARGET_NETOPEER_DIR := $(TARGET_DIR)/usr/local/etc/netopeer/
TARGET_NETOPEER_CFG_DIR := $(TARGET_NETOPEER_DIR)/cfgnetopeer/
TARGET_NETOPEER_MODEL_DIR := $(TARGET_NETOPEER_DIR)/modules.conf.d/

IF_SRC_NAME = cfginterfaces
BRIDGE_SRC_NAME = cfgbridges
# copying qbv and qbu  models from standard model repo
define TRANSAPI_COPY_IF_MODELS
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-interfaces@2014-05-08.yang \
		$(@D)/$(IF_SRC_NAME)/ietf-interfaces@2014-05-08.yang;
	$(INSTALL) -D -t $(@D)//$(IF_SRC_NAME) $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/draft/802.1/Qcw/*;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-yang-types.yang \
		$(@D)/$(IF_SRC_NAME)/ietf-yang-types.yang;
	$(INSTALL) -D -m 0755   $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/published/802.1/ieee802-dot1q-types.yang \
		$(@D)/$(IF_SRC_NAME)/ieee802-dot1q-types.yang;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/published/802/ieee802-types.yang \
		$(@D)/$(IF_SRC_NAME)/ieee802-types.yang;
endef

# copying qci models from standard model repo
define TRANSAPI_COPY_BRIDGE_MODELS
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-interfaces@2014-05-08.yang \
		$(@D)/$(BRIDGE_SRC_NAME)/ietf-interfaces@2014-05-08.yang;
	$(INSTALL) -D -t $(@D)/$(BRIDGE_SRC_NAME) $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/published/802.1/*;
	$(INSTALL) -D -t $(@D)/$(BRIDGE_SRC_NAME) $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/draft/802.1/Qcw/*;
	$(INSTALL) -D -t $(@D)/$(BRIDGE_SRC_NAME) $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/draft/802.1/Qcr/*;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-yang-types.yang \
		$(@D)/$(BRIDGE_SRC_NAME)/ietf-yang-types.yang;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ieee/published/802/ieee802-types.yang \
		$(@D)/$(BRIDGE_SRC_NAME)/ieee802-types.yang;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ietf/RFC/ietf-inet-types@2013-07-15.yang \
		$(@D)/$(BRIDGE_SRC_NAME)/ietf-inet-types@2013-07-15.yang;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/yang-model-$(YANG_MODEL_VERSION)/standard/ietf/RFC/iana-if-type@2017-01-19.yang \
		$(@D)/$(BRIDGE_SRC_NAME)/iana-if-type@2017-01-19.yang;
endef

# create configure
define TRANSAPI_CREATE_CONFIGURE
        cd $(@D); \
	$(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/lnctool \
		--model $(@D)/$(BRIDGE_SRC_NAME)/ietf-interfaces@2014-05-08.yang \
		--search-path $(@D)/$(BRIDGE_SRC_NAME)/ \
		--output-dir $(@D)/$(BRIDGE_SRC_NAME)/ \
		convert;\
	$(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/lnctool \
		--model $(@D)/$(BRIDGE_SRC_NAME)/ietf-interfaces@2014-05-08.yang \
		--search-path $(@D)/$(BRIDGE_SRC_NAME)/ \
		transapi;

        cd $(TOPDIR); \
        $(APPLY_PATCHES) $(@D) package/transapi\
		0001-modify-configure.in-to-change-parameters-to-fit-the-.patch.conditional; \
        $(APPLY_PATCHES) $(@D) package/transapi\
		0002-modify-Makefile.in-to-change-the-project.patch.conditional; \
        cd $(@D); \
        $(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/autoreconf --force --install
endef

# create Makefile
define TRANSAPI_CONFIGURE_CMDS
        cd $(@D); \
        $(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(TRANSAPI_CONF_ENV) \
		./configure  --prefix=/usr/local/ \
		--host=arm-buildroot-linux-gnueabihf \
		--build=x86_64-pc-linux-gnu \
		--includedir=$(STAGING_DIR)/usr/include/libnl3 \
		--with-libxml2=$(STAGING_DIR)/usr/bin; \
	rm -r -f autom4te.cache \
	rm -f   ietf-interfaces@2014-05-08.c \
		ietf-interfaces@2014-05-08-config.rng \
		ietf-interfaces@2014-05-08-gdefs-config.rng \
		ietf-interfaces@2014-05-08-schematron.xsl \
		ietf-interfaces@2014-05-08.yin \
		libtool
endef
# create validator for each transapi, this is needed for netopeer-server
define TRANSAPI_LNCTOOL_CREATE_FILES
        cd $(@D)/$(IF_SRC_NAME); \
        $(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/lnctool \
		--model ietf-interfaces@2014-05-08.yang \
		--augment-model ietf-yang-types.yang \
		--augment-model ieee802-dot1q-preemption.yang \
		--augment-model ieee802-dot1q-sched.yang \
		--augment-model ieee802-dot1q-types.yang \
		--augment-model ieee802-types.yang \
		--search-path cfginterfaces/ \
		validation;
        cd $(@D)/$(BRIDGE_SRC_NAME); \
        $(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/lnctool \
		--model ieee802-dot1q-bridge.yang \
		--augment-model ietf-interfaces@2014-05-08.yang \
		--augment-model ietf-yang-types.yang \
		--augment-model ieee802-dot1q-types.yang \
		--augment-model ieee802-types.yang \
		--augment-model iana-if-type@2017-01-19.yang \
		--augment-model ietf-inet-types@2013-07-15.yang \
		--augment-model ieee802-dot1q-stream-filters-gates.yang \
		--augment-model ieee802-dot1q-psfp.yang \
		--augment-model ieee802-dot1q-cb-stream-identification.yang \
		--search-path cfgbridges \
		validation;
endef

TRANSAPI_PRE_CONFIGURE_HOOKS += TRANSAPI_COPY_IF_MODELS
TRANSAPI_PRE_CONFIGURE_HOOKS += TRANSAPI_COPY_BRIDGE_MODELS
TRANSAPI_PRE_CONFIGURE_HOOKS += TRANSAPI_COPY_PLATFORM
TRANSAPI_PRE_CONFIGURE_HOOKS += TRANSAPI_CREATE_CONFIGURE
TRANSAPI_POST_BUILD_HOOKS += TRANSAPI_LNCTOOL_CREATE_FILES

$(eval $(autotools-package))
