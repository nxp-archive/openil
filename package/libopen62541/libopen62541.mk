################################################################################
#
# libopen62541
#
################################################################################

LIBOPEN62541_VERSION = v0.2
LIBOPEN62541_SITE = https://github.com/open62541/open62541.git
LIBOPEN62541_SITE_METHOD = git
LIBOPEN62541_LICENSE = MOZILLA
LIBOPEN62541_LICENSE_FILES = LICENSE
LIBOPEN62541_INSTALL_STAGING = YES
LIBOPEN62541_CONF_OPTS = -DUA_ENABLE_AMALGAMATION=ON

ifeq ($(BR2_PACKAGE_OPEN62541_EXAMPLES),y)

LIBOPEN62541_CONF_OPTS += -DUA_BUILD_EXAMPLES=ON

OPEN62541_EXAMPLES = \
	client \
	server \
	server_inheritance \
	server_instantiation \
	server_mainloop \
	server_repeated_job \
	tutorial_client_firststeps \
	tutorial_datatypes \
	tutorial_server_datasource \
	tutorial_server_firststeps \
	tutorial_server_method \
	tutorial_server_object \
	tutorial_server_variable \
	tutorial_server_variabletype

define OPEN62541_INSTALL_EXAMPLES
	$(foreach example, $(OPEN62541_EXAMPLES),
		$(INSTALL) -m 0755 -D $(BUILD_DIR)/libopen62541-$(LIBOPEN62541_VERSION)/examples/$(example) \
			$(TARGET_DIR)/usr/bin/open62541_$(example);)
endef

LIBOPEN62541_POST_INSTALL_TARGET_HOOKS += OPEN62541_INSTALL_EXAMPLES

endif

$(eval $(cmake-package))

