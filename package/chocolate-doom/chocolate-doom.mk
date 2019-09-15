################################################################################
#
# chocolate-doom
#
################################################################################

CHOCOLATE_DOOM_VERSION = 2.3.0
CHOCOLATE_DOOM_SITE = http://www.chocolate-doom.org/downloads/$(CHOCOLATE_DOOM_VERSION)
CHOCOLATE_DOOM_LICENSE = GPL-2.0+
CHOCOLATE_DOOM_LICENSE_FILES = COPYING
CHOCOLATE_DOOM_DEPENDENCIES = host-pkgconf sdl sdl_mixer sdl_net

# We're patching configure.ac, so we need to autoreconf
CHOCOLATE_DOOM_AUTORECONF = YES

# Avoid installing desktop entries, icons, etc.
CHOCOLATE_DOOM_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) install-exec

CHOCOLATE_DOOM_CONF_OPTS = \
	--disable-sdltest \
	--with-sdl-prefix=$(STAGING_DIR)/usr \
	--with-sdl-exec-prefix=$(STAGING_DIR)/usr

CHOCOLATE_DOOM_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_TOOLCHAIN_HAS_GCC_BUG_85180),y)
CHOCOLATE_DOOM_CFLAGS += -O0
endif

CHOCOLATE_DOOM_CONF_ENV += CFLAGS="$(CHOCOLATE_DOOM_CFLAGS)"

ifeq ($(BR2_PACKAGE_LIBPNG),y)
CHOCOLATE_DOOM_DEPENDENCIES += libpng
CHOCOLATE_DOOM_CONF_OPTS += --with-libpng
else
CHOCOLATE_DOOM_CONF_OPTS += --without-libpng
endif

ifeq ($(BR2_PACKAGE_LIBSAMPLERATE),y)
CHOCOLATE_DOOM_DEPENDENCIES += libsamplerate
CHOCOLATE_DOOM_CONF_OPTS += --with-libsamplerate
else
CHOCOLATE_DOOM_CONF_OPTS += --without-libsamplerate
endif

$(eval $(autotools-package))
