################################################################################
#
# gst-plugins-base-imx
#
################################################################################

GST_PLUGINS_BASE_IMX_VERSION = rel_imx_5.4.47_2.2.0
GST_PLUGINS_BASE_IMX_SITE = https://source.codeaurora.org/external/imx/gst-plugins-base
GST_PLUGINS_BASE_IMX_SITE_METHOD = git
GST_PLUGINS_BASE_IMX_GIT_SUBMODULES = YES
GST_PLUGINS_BASE_IMX_INSTALL_STAGING = YES
GST_PLUGINS_BASE_IMX_LICENSE_FILES = COPYING
GST_PLUGINS_BASE_IMX_LICENSE = LGPL-2.0+, LGPL-2.1+

GST_PLUGINS_BASE_IMX_CONF_OPTS = \
	--disable-examples \
	--disable-tests \
	--disable-gobject-cast-checks \
	--disable-glib-asserts \
	--disable-glib-checks \
	--disable-gtk_doc \
	--disable-introspection

# Options which require currently unpackaged libraries
GST_PLUGINS_BASE_IMX_CONF_OPTS += \
	--disable-cdparanoia \
	--disable-libvisual \
	--disable-iso-codes

GST_PLUGINS_BASE_IMX_DEPENDENCIES = gstreamer-imx $(TARGET_NLS_DEPENDENCIES)

GST_PLUGINS_BASE_IMX_LDFLAGS = $(TARGET_LDFLAGS) $(TARGET_NLS_LIBS)

# These plugins are listed in the order from ./configure --help
ifeq ($(BR2_PACKAGE_ORC),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += orc
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-orc
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-orc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_LIB_OPENGL_HAS_API),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += -enable-gl
ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_LIB_OPENGL_OPENGL),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += libgl libglu
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-opengl
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-opengl
endif
ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_LIB_OPENGL_GLES2),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += libgles
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-gles2
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-gles2
endif
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-gl
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_LIB_OPENGL_GLX),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += xorgproto xlib_libXrender
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-glx
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-glx
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_LIB_OPENGL_EGL),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += libegl
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-egl
GST_PLUGINS_BASE_IMX_CONF_ENV += \
	CPPFLAGS="$(TARGET_CPPFLAGS) `$(PKG_CONFIG_HOST_BINARY) --cflags egl`" \
	LIBS="`$(PKG_CONFIG_HOST_BINARY) --libs egl`"
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-egl
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_LIB_OPENGL_X11),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += xlib_libX11 xlib_libXext
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-x11
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-x11
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_LIB_OPENGL_WAYLAND),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += wayland wayland-protocols-imx
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-wayland
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-wayland
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_LIB_OPENGL_DISPMANX),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += rpi-userland
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-dispmanx
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-dispmanx
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_ADDER),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-adder
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-adder
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_APP),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-app
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-app
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_AUDIOCONVERT),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-audioconvert
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-audioconvert
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_AUDIOMIXER),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-audiomixer
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-audiomixer
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_AUDIORATE),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-audiorate
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-audiorate
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_AUDIOTESTSRC),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-audiotestsrc
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-audiotestsrc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_COMPOSITOR),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-compositor
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-compositor
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_ENCODING),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-encoding
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-encoding
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_VIDEOCONVERT),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-videoconvert
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-videoconvert
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_GIO),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-gio
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-gio
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_OVERLAYCOMPOSITION),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-overlaycomposition
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-overlaycomposition
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_PLAYBACK),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-playback
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-playback
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_AUDIORESAMPLE),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-audioresample
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-audioresample
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_RAWPARSE),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-rawparse
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-rawparse
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_SUBPARSE),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-subparse
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-subparse
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_TCP),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-tcp
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-tcp
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_TYPEFIND),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-typefind
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-typefind
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_VIDEOTESTSRC),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-videotestsrc
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-videotestsrc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_VIDEORATE),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-videorate
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-videorate
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_VIDEOSCALE),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-videoscale
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-videoscale
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_VOLUME),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-volume
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-volume
endif

# Zlib is checked for headers and is not an option.
ifeq ($(BR2_PACKAGE_ZLIB),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += zlib
endif

ifeq ($(BR2_PACKAGE_XORG7),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += xlib_libX11 xlib_libXext
GST_PLUGINS_BASE_IMX_CONF_OPTS += \
	--enable-x11 \
	--enable-xshm \
	--enable-xvideo
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += \
	--disable-x11 \
	--disable-xshm \
	--disable-xvideo
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_ALSA),y)
GST_PLUGINS_BASE_IMX_DEPENDENCIES += alsa-lib
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-alsa
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-alsa
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_TREMOR),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-tremor
GST_PLUGINS_BASE_IMX_DEPENDENCIES += tremor
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-tremor
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_OPUS),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-opus
GST_PLUGINS_BASE_IMX_DEPENDENCIES += opus
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-opus
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_OGG),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-ogg
GST_PLUGINS_BASE_IMX_DEPENDENCIES += libogg
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-ogg
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_PANGO),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-pango
GST_PLUGINS_BASE_IMX_DEPENDENCIES += pango
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-pango
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_THEORA),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-theora
GST_PLUGINS_BASE_IMX_DEPENDENCIES += libtheora
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-theora
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BASE_IMX_PLUGIN_VORBIS),y)
GST_PLUGINS_BASE_IMX_CONF_OPTS += --enable-vorbis
GST_PLUGINS_BASE_IMX_DEPENDENCIES += libvorbis
else
GST_PLUGINS_BASE_IMX_CONF_OPTS += --disable-vorbis
endif

define GST_PLUGINS_BASE_IMX_RUN_AUTOGEN
        cd $(@D) && ./autogen.sh
endef
GST_PLUGINS_BASE_IMX_PRE_CONFIGURE_HOOKS += GST_PLUGINS_BASE_IMX_RUN_AUTOGEN

$(eval $(autotools-package))
