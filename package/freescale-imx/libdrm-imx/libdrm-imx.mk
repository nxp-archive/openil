################################################################################
#
# libdrm-imx
#
################################################################################

LIBDRM_IMX_VERSION = rel_imx_5.4.24_2.1.0
LIBDRM_IMX_SITE = https://source.codeaurora.org/external/imx/libdrm-imx
LIBDRM_IMX_SITE_METHOD = git
LIBDRM_IMX_LICENSE = GPL-2.0+
LIBDRM_IMX_INSTALL_STAGING = YES
LIBDRM_IMX_DEPENDENCIES += host-automake host-autoconf host-libtool host-xutil_util-macros

LIBDRM_IMX_CONF_OPTS = \
	-Dcairo-tests=false \
	-Dmanpages=false \
	-Dvc4=false \
	-Dvivante-experimental-api=false \
	-Dfreedreno=false \
	-Dvmwgfx=false \
	-Dnouveau=false \
	-Damdgpu=false \
	-Dradeon=false \
	-Dintel=false \
	-Detnaviv-experimental-api=true

$(eval $(meson-package))
