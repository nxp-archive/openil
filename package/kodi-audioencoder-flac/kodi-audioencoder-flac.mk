################################################################################
#
# kodi-audioencoder-flac
#
################################################################################

KODI_AUDIOENCODER_FLAC_VERSION = 1.1.0
KODI_AUDIOENCODER_FLAC_SITE = $(call github,xbmc,audioencoder.flac,v$(KODI_AUDIOENCODER_FLAC_VERSION))
KODI_AUDIOENCODER_FLAC_LICENSE = GPL-2.0+
KODI_AUDIOENCODER_FLAC_LICENSE_FILES = src/EncoderFlac.cpp
KODI_AUDIOENCODER_FLAC_DEPENDENCIES = flac kodi libogg host-pkgconf

$(eval $(cmake-package))
