################################################################################
#
# supertuxkart
#
################################################################################

SUPERTUXKART_VERSION = 1.0
SUPERTUXKART_SOURCE = supertuxkart-$(SUPERTUXKART_VERSION)-src.tar.xz
SUPERTUXKART_SITE = http://downloads.sourceforge.net/project/supertuxkart/SuperTuxKart/$(SUPERTUXKART_VERSION)

# Supertuxkart itself is GPL-3.0+, but it bundles a few libraries with different
# licenses. Irrlicht, bullet and angelscript have Zlib license, while glew is
# BSD-3-Clause. Since they are linked statically, the result is GPL-3.0+.
SUPERTUXKART_LICENSE = GPL-3.0+
SUPERTUXKART_LICENSE_FILES = COPYING

SUPERTUXKART_DEPENDENCIES = \
	host-pkgconf \
	freetype \
	enet \
	jpeg \
	libcurl \
	libgl \
	libglew \
	libglu \
	libogg \
	libpng \
	libsquish \
	libvorbis \
	nettle \
	openal \
	xlib_libXrandr \
	zlib

# Since supertuxkart is not installing libstkirrlicht.so, and since it is
# the only user of the bundled libraries, turn off shared libraries entirely.
# Disable In-game recorder (there is no libopenglrecorder package)
SUPERTUXKART_CONF_OPTS = -DBUILD_SHARED_LIBS=OFF \
	-DBUILD_RECORDER=OFF \
	-DUSE_SYSTEM_GLEW=ON \
	-DUSE_SYSTEM_ENET=ON

ifeq ($(BR2_PACKAGE_LIBFRIBIDI),y)
SUPERTUXKART_DEPENDENCIES += libfribidi
SUPERTUXKART_CONF_OPTS += -DUSE_FRIBIDI=ON
else
SUPERTUXKART_CONF_OPTS += -DUSE_FRIBIDI=OFF
endif

ifeq ($(BR2_PACKAGE_BLUEZ5_UTILS),y)
SUPERTUXKART_DEPENDENCIES += bluez5_utils
SUPERTUXKART_CONF_OPTS += -DUSE_WIIUSE=ON -DUSE_SYSTEM_WIIUSE=ON
else
# Wiimote support relies on bluez5.
SUPERTUXKART_CONF_OPTS += -DUSE_WIIUSE=OFF
endif

$(eval $(cmake-package))
