################################################################################
#
# yang module tsn
#
################################################################################
YANG_TSN_VERSION = 0.1-rc1
YANG_TSN_SITE = package/yang-tsn/tsn
YANG_TSN_SITE_METHOD = local
YANG_TSN_LICENSE = MIT
YANG_TSN_LICENSE_FILES = COPYING
YANG_TSN_DEPENDENCIES = libxml2 pyang libnetconf netopeer tsntool 
YANG_TSN_CONF_ENV += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"
YANG_TSN_CONF_ENV += PYTHON_CONFIG="$(STAGING_DIR)/usr/bin/python-config"
YANG_TSN_CONF_ENV += ac_cv_path_NETOPEER_MANAGER="$(HOST_DIR)/usr/bin/netopeer-manager.host"
LIBNL_HEADER_DIR = $(HOST_DIR)/usr/aarch64-buildroot-linux-gnu/sysroot/usr/include/libnl3
TSNTOOL_HEADER_DIR = $(BUILD_DIR)/tsntool-$(TSNTOOL_VERSION)/include
YANG_TSN_CONF_ENV += CFLAGS+="-Wextra -Wall -Wunused-function -Wunused-label -Werror"
YANG_TSN_CONF_ENV += SRCS+="tsn_qbv.c yin_access.c"
#YANG_TSN_CONF_ENV += CFLAGS+="-I$(TSNTOOL_HEADER_DIR) -I$(HOST_DIR)/usr/include"

HOST_MODEL_DIR := $(TARGET_DIR)/usr/local/etc/netopeer/tsn/
TARGET_MODEL_DIR := /usr/local/etc/netopeer/tsn/
TARGET_NETOPEER_DIR := $(TARGET_DIR)/usr/local/etc/netopeer/
TARGET_NETOPEER_CFG_DIR := $(TARGET_NETOPEER_DIR)/cfgnetopeer/
TARGET_NETOPEER_MODEL_DIR := $(TARGET_NETOPEER_DIR)/modules.conf.d/

define YANG_TSN_CREATE_CONFIGURE
        cd $(@D); \
        $(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/lnctool --model ./tsn.yang \
                                              --search-path ./models \
                                              transapi --paths ./paths.txt;
    $(INSTALL) -D -m 0755 $(TOPDIR)/package/yang-tsn/tsn/tsn.c \
                            $(BUILD_DIR)/yang-tsn-$(YANG_TSN_VERSION)/;
    $(INSTALL) -D -m 0755 $(BUILD_DIR)/tsntool-$(TSNTOOL_VERSION)/main/main.h \
                            $(BUILD_DIR)/yang-tsn-$(YANG_TSN_VERSION)/;
        cd $(TOPDIR); \
        $(APPLY_PATCHES) $(@D) package/yang-tsn\
                     0001-yang-tsn-modify-configure-file-pass-buildroot.patch; \
        $(APPLY_PATCHES) $(@D) package/yang-tsn\
				     0002-Modify-CFLAGS-LDFAGS-and-SRCS-macros-for-tsn.patch;
        cd $(@D); \
        $(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/autoreconf --force --install
endef

define YANG_TSN_CONFIGURE_CMDS
        cd $(@D); \
        $(TARGET_CONFIGURE_ARGS) $(TARGET_CONFIGURE_OPTS) $(YANG_TSN_CONF_ENV) \
            ./configure  --prefix=/usr/local/ \
            --host=arm-buildroot-linux-gnueabihf \
            --build=x86_64-pc-linux-gnu \
			--includedir=$(STAGING_DIR)/usr/include/libnl3 \
            --with-libxml2=$(STAGING_DIR)/usr/bin
endef

define YANG_TSN_LNCTOOL_CREATE_FILES
        cd $(@D); \
        $(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/lnctool --model \
            `pwd`/tsn.yang --search-path `pwd` --output-dir `pwd` validation; 
endef

define YANG_TSN_ADD_DEPENDENT_MODEL
		cd $(@D); \
		cp -rf ./models/ $(TARGET_DIR)/usr/local/etc/netopeer/tsn/; \
		$(HOST_DIR)/usr/bin/netopeer-manager.host add --name tsn \
			--import $(HOST_MODEL_DIR)/models/ietf-interfaces@2014-05-08.yin \
			--import_target $(TARGET_MODEL_DIR)/models/ietf-interfaces@2014-05-08.yin \
			--netopeer_config $(TARGET_NETOPEER_CFG_DIR)/datastore.xml \
            --datastore $(TARGET_MODEL_DIR)/datastore.xml \
            --modules_path $(TARGET_NETOPEER_MODEL_DIR); \
		$(HOST_DIR)/usr/bin/netopeer-manager.host add --name tsn \
			--import $(HOST_MODEL_DIR)/models/ieee802-dot1q-preemption.yin \
			--import_target $(TARGET_MODEL_DIR)/models/ieee802-dot1q-preemption.yin \
			--netopeer_config $(TARGET_NETOPEER_CFG_DIR)/datastore.xml \
            --datastore $(TARGET_MODEL_DIR)/datastore.xml \
            --modules_path $(TARGET_NETOPEER_MODEL_DIR); \
		$(HOST_DIR)/usr/bin/netopeer-manager.host add --name tsn \
			--import $(HOST_MODEL_DIR)/models/ieee802-dot1q-sched.yin \
			--import_target $(TARGET_MODEL_DIR)/models/ieee802-dot1q-sched.yin \
			--netopeer_config $(TARGET_NETOPEER_CFG_DIR)/datastore.xml \
            --datastore $(TARGET_MODEL_DIR)/datastore.xml \
            --modules_path $(TARGET_NETOPEER_MODEL_DIR); \
		$(HOST_DIR)/usr/bin/netopeer-manager.host add --name tsn \
			--import $(HOST_MODEL_DIR)/models/ieee802-dot1q-types.yin \
			--import_target $(TARGET_MODEL_DIR)/models/ieee802-dot1q-types.yin \
			--netopeer_config $(TARGET_NETOPEER_CFG_DIR)/datastore.xml \
            --datastore $(TARGET_MODEL_DIR)/datastore.xml \
            --modules_path $(TARGET_NETOPEER_MODEL_DIR);
endef
YANG_TSN_PRE_CONFIGURE_HOOKS += YANG_TSN_CREATE_CONFIGURE
YANG_TSN_POST_BUILD_HOOKS += YANG_TSN_LNCTOOL_CREATE_FILES
YANG_TSN_POST_INSTALL_TARGET_HOOKS += YANG_TSN_ADD_DEPENDENT_MODEL

$(eval $(autotools-package))
