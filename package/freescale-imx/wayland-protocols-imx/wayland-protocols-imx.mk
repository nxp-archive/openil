################################################################################
#
# wayland-protocols-imx
#
################################################################################

WAYLAND_PROTOCOLS_IMX_VERSION = rel_imx_5.4.24_2.1.0
WAYLAND_PROTOCOLS_IMX_SITE = https://source.codeaurora.org/external/imx/wayland-protocols-imx
WAYLAND_PROTOCOLS_IMX_SITE_METHOD = git
WAYLAND_PROTOCOLS_IMX_LICENSE = GPL-2.0+
WAYLAND_PROTOCOLS_IMX_INSTALL_STAGING = YES
WAYLAND_PROTOCOLS_IMX_AUTORECONF = YES
WAYLAND_PROTOCOLS_IMX_DEPENDENCIES = host-pkgconf wayland

$(eval $(autotools-package))
