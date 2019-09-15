################################################################################
#
# kodi-screensaver-asterwave
#
################################################################################

KODI_SCREENSAVER_ASTERWAVE_VERSION = 1.1.0
KODI_SCREENSAVER_ASTERWAVE_SITE = $(call github,notspiff,screensaver.asterwave,v$(KODI_SCREENSAVER_ASTERWAVE_VERSION))
KODI_SCREENSAVER_ASTERWAVE_DEPENDENCIES = kodi libglu libsoil

$(eval $(cmake-package))
