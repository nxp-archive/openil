################################################################################
#
# kmscube
#
################################################################################

KMSCUBE_VERSION = 4660a7dca6512b6e658759d00cff7d4ad2a2059d
KMSCUBE_SITE = https://cgit.freedesktop.org/mesa/kmscube/snapshot
KMSCUBE_LICENSE = MIT
KMSCUBE_DEPENDENCIES = host-pkgconf libdrm-imx imx-gpu-viv

$(eval $(meson-package))
