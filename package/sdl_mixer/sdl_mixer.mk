################################################################################
#
# sdl_mixer
#
################################################################################

SDL_MIXER_VERSION = 1.2.12
SDL_MIXER_SOURCE = SDL_mixer-$(SDL_MIXER_VERSION).tar.gz
SDL_MIXER_SITE = http://www.libsdl.org/projects/SDL_mixer/release
SDL_MIXER_LICENSE = Zlib
SDL_MIXER_LICENSE_FILES = COPYING

SDL_MIXER_INSTALL_STAGING = YES
SDL_MIXER_DEPENDENCIES = sdl

# We're patching configure.in, so we need to autoreconf
SDL_MIXER_AUTORECONF = YES
SDL_MIXER_AUTORECONF_OPTS = -Iacinclude

SDL_MIXER_CONF_OPTS = \
	--without-x \
	--with-sdl-prefix=$(STAGING_DIR)/usr \
	--disable-music-midi \
	--disable-music-mod \
	--disable-music-mp3 \
	--disable-music-flac # configure script fails when cross compiling

ifeq ($(BR2_PACKAGE_LIBMAD),y)
SDL_MIXER_CONF_OPTS += --enable-music-mp3-mad-gpl
SDL_MIXER_DEPENDENCIES += libmad
else
SDL_MIXER_CONF_OPTS += --disable-music-mp3-mad-gpl
endif

ifeq ($(BR2_PACKAGE_LIBVORBIS),y)
SDL_MIXER_CONF_OPTS += --enable-music-ogg
SDL_MIXER_DEPENDENCIES += libvorbis
else
SDL_MIXER_CONF_OPTS += --disable-music-ogg
endif

$(eval $(autotools-package))
