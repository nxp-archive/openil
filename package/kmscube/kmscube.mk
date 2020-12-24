################################################################################
#
# kmscube
#
################################################################################

KMSCUBE_VERSION = e6386d1b99366ea7559438c0d3abd2ae2d6d61ac
KMSCUBE_SITE = https://gitlab.freedesktop.org/mesa/kmscube
KMSCUBE_SITE_METHOD = git
KMSCUBE_LICENSE = MIT
KMSCUBE_DEPENDENCIES = host-pkgconf libdrm-imx imx-gpu-viv

$(eval $(meson-package))
