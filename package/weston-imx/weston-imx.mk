################################################################################
#
# weston-imx
#
################################################################################

WESTON_IMX_VERSION = rel_imx_5.4.70_2.3.0
WESTON_IMX_SITE = https://source.codeaurora.org/external/imx/weston-imx
WESTON_IMX_SITE_METHOD = git
WESTON_IMX_LICENSE = MIT
WESTON_IMX_LICENSE_FILES = COPYING

WESTON_IMX_DEPENDENCIES = host-pkgconf wayland wayland-protocols-imx \
	libxkbcommon pixman libpng jpeg udev cairo libinput libdrm-imx imx-gpu-g2d

WESTON_IMX_CONF_OPTS = \
	--prefix=/usr \
	-Dbuild.pkg_config_path=$(HOST_DIR)/lib/pkgconfig:$(HOST_DIR)/share/pkgconfig:$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/local/share/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig \
	-Dcolor-management-colord=false \
	-Dcolor-management-lcms=false \
	-Dbackend-drm-screencast-vaapi=false \
	-Dsimple-dmabuf-drm=auto \
	-Ddoc=false \
	-Drenderer-g2d=true \
	-Degl=true \
	-Dpipewire=false \
	-Dbackend-rdp=false \
	-Dremoting=false \
	-Dimage-webp=false \
	-Dbackend-drm=true \
	-Dbackend-x11=false \
	-Dimage-jpeg=false \
	-Dimage-webp=false \
	-Dweston-launch=false \
	-Dlauncher-logind=false \
	-Ddemo-clients=false \
	-Dlauncher-logind=false \
	-Dxwayland=false \
	-Dsystemd=false

$(eval $(meson-package))
