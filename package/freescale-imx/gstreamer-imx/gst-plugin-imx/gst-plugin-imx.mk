################################################################################
#
# gst-plugin-imx
#
################################################################################

GST_PLUGIN_IMX_VERSION = rel_imx_5.4.70_2.3.0
GST_PLUGIN_IMX_SITE = git://source.codeaurora.org/external/imx/imx-gst1.0-plugin.git
GST_PLUGIN_IMX_SITE_METHOD = git
GST_PLUGIN_IMX_LICENSE = LGPL-2.0+
GST_PLUGIN_IMX_LICENSE_FILES = LICENSE

GST_PLUGIN_IMX_INSTALL_STAGING = YES

GST_PLUGIN_IMX_DEPENDENCIES += \
	host-pkgconf \
	imx-codec \
	imx-parser \
	gstreamer-imx \
	gst-plugins-base-imx \
	gst-plugins-bad-imx \
	gst-plugins-good-imx

GST_PLUGIN_IMX_CONF_OPTS = PLATFORM=MX8 --prefix="/usr"

define GST_PLUGIN_IMX_RUN_AUTOGEN
        cd $(@D) && ./autogen.sh PLATFORM=MX8
endef
GST_PLUGIN_IMX_PRE_CONFIGURE_HOOKS += GST_PLUGIN_IMX_RUN_AUTOGEN

$(eval $(autotools-package))
