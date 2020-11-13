################################################################################
#
# gstreamer-imx
#
################################################################################

GSTREAMER_IMX_VERSION = rel_imx_5.4.24_2.1.0
GSTREAMER_IMX_SITE = https://source.codeaurora.org/external/imx/gstreamer
GSTREAMER_IMX_SITE_METHOD = git
GSTREAMER_IMX_GIT_SUBMODULES = YES
GSTREAMER_IMX_INSTALL_STAGING = YES
GSTREAMER_IMX_LICENSE_FILES = COPYING
GSTREAMER_IMX_LICENSE = LGPL-2.0+, LGPL-2.1+

GSTREAMER_IMX_CONF_OPTS = \
	--disable-examples \
	--disable-etests \
	--disable-ebenchmarks \
	--disable-egtk_doc \
	--disable-eintrospection \
	--disable-eglib-asserts \
	--disable-eglib-checks \
	--disable-egobject-cast-checks

ifeq ($(BR2_PACKAGE_GSTREAMER_IMX_CHECK),y)
GSTREAMER_IMX_CONF_OPTS += --enable-check
else
GSTREAMER_IMX_CONF_OPTS += --disable-check
endif

ifeq ($(BR2_PACKAGE_GSTREAMER_IMX_TRACE),y)
GSTREAMER_IMX_CONF_OPTS += --enable-tracer_hooks
else
GSTREAMER_IMX_CONF_OPTS += --disable-tracer_hooks
endif

ifeq ($(BR2_PACKAGE_GSTREAMER_IMX_PARSE),y)
GSTREAMER_IMX_CONF_OPTS += --enable-option-parsing
else
GSTREAMER_IMX_CONF_OPTS += --disable-option-parsing
endif

ifeq ($(BR2_PACKAGE_GSTREAMER_IMX_GST_DEBUG),y)
GSTREAMER_IMX_CONF_OPTS += --enable-gst_debug
else
GSTREAMER_IMX_CONF_OPTS += --disable-gst_debug
endif

ifeq ($(BR2_PACKAGE_GSTREAMER_IMX_PLUGIN_REGISTRY),y)
GSTREAMER_IMX_CONF_OPTS += --enable-registry
else
GSTREAMER_IMX_CONF_OPTS += --disable-registry
endif

ifeq ($(BR2_PACKAGE_GSTREAMER_IMX_INSTALL_TOOLS),y)
GSTREAMER_IMX_CONF_OPTS += --enable-tools
else
GSTREAMER_IMX_CONF_OPTS += --disable-tools
endif

GSTREAMER_IMX_DEPENDENCIES = \
	host-bison \
	host-flex \
	host-pkgconf \
	libglib2 \
	$(if $(BR2_PACKAGE_LIBUNWIND),libunwind) \
	$(if $(BR2_PACKAGE_VALGRIND),valgrind) \
	$(TARGET_NLS_DEPENDENCIES)

GSTREAMER_IMX_LDFLAGS = $(TARGET_LDFLAGS) $(TARGET_NLS_LIBS)

define GSTREAMER_IMX_RUN_AUTOGEN
        cd $(@D) && ./autogen.sh
endef
GSTREAMER_IMX_PRE_CONFIGURE_HOOKS += GSTREAMER_IMX_RUN_AUTOGEN

$(eval $(autotools-package))
