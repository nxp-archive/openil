################################################################################
#
# libopen62541
#
################################################################################

LIBOPEN62541_VERSION = v1.0-rc5
LIBOPEN62541_SITE = https://github.com/open62541/open62541.git
LIBOPEN62541_SITE_METHOD = git
LIBOPEN62541_LICENSE = MOZILLA
LIBOPEN62541_LICENSE_FILES = LICENSE
LIBOPEN62541_INSTALL_STAGING = YES
LIBOPEN62541_DEPENDENCIES = ua-nodeset
#LIBOPEN62541_CONF_OPTS = -DUA_ENABLE_AMALGAMATION=ON
LIBOPEN62541_CONF_OPTS = \
	-DUA_ENABLE_SUBSCRIPTIONS_EVENTS=ON \
	-DUA_ENABLE_DISCOVERY_MULTICAST=OFF \
	-DUA_ENABLE_WEBSOCKET_SERVER=ON \
	-DUA_ENABLE_HISTORIZING=ON \
	-DUA_ENABLE_ENCRYPTION=OFF \
	-DUA_BUILD_TOOLS=ON \
	-DUA_NODESET_DIR=$(STAGING_DIR)/usr/share/ua-nodeset

ifeq ($(BR2_PACKAGE_OPEN62541_EXAMPLES),y)

LIBOPEN62541_CONF_OPTS += -DUA_BUILD_EXAMPLES=ON

OPEN62541_EXAMPLES = \
	access_control_client \
	access_control_server \
	client \
	client_async \
	client_connect \
	client_connectivitycheck_loop \
	client_connect_loop \
	client_historical \
	client_subscription_loop \
	custom_datatype_client \
	custom_datatype_server \
	server_ctt \
	server_inheritance \
	server_instantiation \
	server_mainloop \
	server_nodeset \
	server_repeated_job \
	tutorial_client_events \
	tutorial_client_firststeps \
	tutorial_datatypes \
	tutorial_server_datasource \
	tutorial_server_events \
	tutorial_server_firststeps \
	tutorial_server_historicaldata \
	tutorial_server_method \
	tutorial_server_monitoreditems \
	tutorial_server_object \
	tutorial_server_variable \
	tutorial_server_variabletype

define OPEN62541_INSTALL_EXAMPLES
	$(foreach example, $(OPEN62541_EXAMPLES),
		$(INSTALL) -m 0755 -D $(BUILD_DIR)/libopen62541-$(LIBOPEN62541_VERSION)/bin/examples/$(example) \
			$(TARGET_DIR)/usr/bin/open62541_$(example);)
endef

LIBOPEN62541_POST_INSTALL_TARGET_HOOKS += OPEN62541_INSTALL_EXAMPLES

endif

$(eval $(cmake-package))

