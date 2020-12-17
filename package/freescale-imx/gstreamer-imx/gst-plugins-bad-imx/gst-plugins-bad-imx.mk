################################################################################
#
# gst-plugins-bad-imx
#
################################################################################

GST_PLUGINS_BAD_IMX_VERSION = rel_imx_5.4.24_2.1.0
GST_PLUGINS_BAD_IMX_SITE = https://source.codeaurora.org/external/imx/gst-plugins-bad
GST_PLUGINS_BAD_IMX_SITE_METHOD = git
GST_PLUGINS_BAD_IMX_GIT_SUBMODULES = YES
GST_PLUGINS_BAD_IMX_INSTALL_STAGING = YES
# Additional plugin licenses will be appended to GST_PLUGINS_BAD_IMX_LICENSE and
# GST_PLUGINS_BAD_IMX_LICENSE_FILES if enabled.
GST_PLUGINS_BAD_IMX_LICENSE_FILES = COPYING.LIB
GST_PLUGINS_BAD_IMX_LICENSE = LGPL-2.0+, LGPL-2.1+

GST_PLUGINS_BAD_IMX_LDFLAGS = $(TARGET_LDFLAGS) $(TARGET_NLS_LIBS)

GST_PLUGINS_BAD_IMX_CONF_OPTS = \
	--disable-examples \
	--disable-tests \
	--disable-directsound \
	--disable-d3dvideosink \
	--disable-winks \
	--disable-androidmedia \
	--disable-applemedia \
	--disable-introspection \
	--disable-gobject-cast-checks \
	--disable-glib-asserts \
	--disable-glib-checks

# Options which require currently unpackaged libraries
GST_PLUGINS_BAD_IMX_CONF_OPTS += \
	--disable-opensles \
	--disable-uvch264 \
	--disable-msdk \
	--disable-voamrwbenc \
	--disable-bs2b \
	--disable-chromaprint \
	--disable-dc1394 \
	--disable-dts \
	--disable-resindvd \
	--disable-faac \
	--disable-flite \
	--disable-gsm \
	--disable-kate \
	--disable-ladspa \
	--disable-lv2 \
	--disable-libde265 \
	--disable-modplug \
	--disable-mplex \
	--disable-ofa \
	--disable-openexr \
	--disable-openni2 \
	--disable-teletextdec \
	--disable-wildmidi \
	--disable-smoothstreaming \
	--disable-soundtouch \
	--disable-gme \
	-disable-vdpau \
	--disable-spandsp \
	--disable-iqa \
	--disable-opencv

GST_PLUGINS_BAD_IMX_DEPENDENCIES = gst-plugins-base-imx gstreamer-imx

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_WAYLAND),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-wayland
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libdrm-imx wayland wayland-protocols-imx
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-wayland
endif

ifeq ($(BR2_PACKAGE_ORC),y)
GST_PLUGINS_BAD_IMX_DEPENDENCIES += orc
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-orc
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-orc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_BLUEZ),y)
GST_PLUGINS_BAD_IMX_DEPENDENCIES += bluez5_utils
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-bluez
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-bluez
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_ACCURIP),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-accurip
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-accurip
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_ADPCMDEC),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-adpcmdec
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-adpcmdec
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_ADPCMENC),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-adpcmenc
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-adpcmenc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_AIFF),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-aiff
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-aiff
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_ASFMUX),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-asfmux
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-asfmux
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_AUDIOBUFFERSPLIT),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-audiobuffersplit
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-audiobuffersplit
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_AUDIOFXBAD),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-audiofxbad
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-audiofxbad
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_AUDIOLATENCY),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-audiolatency
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-audiolatency
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_AUDIOMIXMATRIX),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-audiomixmatrix
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-audiomixmatrix
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_AUDIOVISUALIZERS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-audiovisualizers
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-audiovisualizers
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_AUTOCONVERT),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-autoconvert
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-autoconvert
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_BAYER),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-bayer
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-bayer
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_CAMERABIN2),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-camerabin2
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-camerabin2
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_COLOREFFECTS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-coloreffects
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-coloreffects
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_DEBUGUTILS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-debugutils
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-debugutils
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_DVBSUBOVERLAY),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-dvbsuboverlay
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-dvbsuboverlay
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_DVDSPU),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-dvdspu
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-dvdspu
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_FACEOVERLAY),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-faceoverlay
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-faceoverlay
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_FESTIVAL),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-festival
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-festival
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_FIELDANALYSIS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-fieldanalysis
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-fieldanalysis
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_FREEVERB),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-freeverb
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-freeverb
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_FREI0R),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-frei0r
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-frei0r
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_GAUDIEFFECTS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-gaudieffects
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-gaudieffects
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_GEOMETRICTRANSFORM),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-geometrictransform
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-geometrictransform
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_GDP),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-gdp
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-gdp
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_ID3TAG),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-id3tag
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-id3tag
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_INTER),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-inter
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-inter
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_INTERLACE),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-interlace
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-interlace
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_IVFPARSE),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-ivfparse
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-ivfparse
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_IVTC),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-ivtc
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-ivtc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_JP2KDECIMATOR),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-jp2kdecimator
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-jp2kdecimator
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_JPEGFORMAT),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-jpegformat
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-jpegformat
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_LIBRFB),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-librfb
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-librfb
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_MIDI),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-midi
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-midi
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_MPEGDEMUX),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-mpegdemux
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-mpegdemux
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_MPEGPSMUX),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-mpegpsmux
GST_PLUGINS_BAD_IMX_HAS_UNKNOWN_LICENSE = y
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-mpegpsmux
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_MPEGTSMUX),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-mpegtsmux
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-mpegtsmux
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_MPEGTSDEMUX),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-mpegtsdemux
GST_PLUGINS_BAD_IMX_HAS_UNKNOWN_LICENSE = y
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-mpegtsdemux
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_MXF),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-mxf
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-mxf
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_NETSIM),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-netsim
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-netsim
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_ONVIF),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-onvif
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-onvif
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_PCAPPARSE),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-pcapparse
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-pcapparse
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_PNM),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-pnm
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-pnm
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_PROXY),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-proxy
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-proxy
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_RAWPARSE),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-rawparse
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-rawparse
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_REMOVESILENCE),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-removesilence
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-removesilence
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_RTMP),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-rtmp
GST_PLUGINS_BAD_IMX_DEPENDENCIES += rtmpdump
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-rtmp
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_SDP),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-sdp
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-sdp
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_SEGMENTCLIP),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-segmentclip
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-segmentclip
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_SIREN),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-siren
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-siren
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_SMOOTH),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-smooth
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-smooth
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_SPEED),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-speed
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-speed
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_SUBENC),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-subenc
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-subenc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_TIMECODE),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-timecode
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-timecode
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_VIDEOFILTERS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-videofilters
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-videofilters
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_VIDEOFRAME_AUDIOLEVEL),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-videoframe_audiolevel
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-videoframe_audiolevel
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_VIDEOPARSERS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-videoparsers
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-videoparsers
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_VIDEOSIGNAL),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-videosignal
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-videosignal
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_VMNC),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-vmnc
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-vmnc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_Y4M),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-y4m
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-y4m
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_YADIF),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-yadif
GST_PLUGINS_BAD_IMX_HAS_GPL_LICENSE = y
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-yadif
endif

# Plugins with dependencies

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_ASSRENDER),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-assrender
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libass
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-assrender
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_BZ2),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-bz2
GST_PLUGINS_BAD_IMX_DEPENDENCIES += bzip2
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-bz2
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_CURL),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-curl
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libcurl
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-curl
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_DASH),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-dash
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libxml2
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-dash
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_DECKLINK),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-decklink
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-decklink
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_DIRECTFB),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-directfb
GST_PLUGINS_BAD_IMX_DEPENDENCIES += directfb
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-directfb
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_DVB),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-dvb
GST_PLUGINS_BAD_IMX_DEPENDENCIES += dtv-scan-tables
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-dvb
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_FAAD),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-faad
GST_PLUGINS_BAD_IMX_DEPENDENCIES += faad2
GST_PLUGINS_BAD_IMX_HAS_GPL_LICENSE = y
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-faad
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_FBDEV),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-fbdev
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-fbdev
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_FDK_AAC),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-fdkaac
GST_PLUGINS_BAD_IMX_DEPENDENCIES += fdk-aac
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-fdkaac
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_FLUIDSYNTH),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-fluidsynth
GST_PLUGINS_BAD_IMX_DEPENDENCIES += fluidsynth
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-fluidsynth
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_GL),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-gl
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-gl
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_HLS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-hls

ifeq ($(BR2_PACKAGE_NETTLE),y)
GST_PLUGINS_BAD_IMX_DEPENDENCIES += nettle
GST_PLUGINS_BAD_IMX_CONF_OPTS += --with-hls-crypto=nettle
else ifeq ($(BR2_PACKAGE_LIBGCRYPT),y)
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libgcrypt
GST_PLUGINS_BAD_IMX_CONF_OPTS += --with-hls-crypto=libgcrypt \
	--with-libgcrypt-prefix=$(STAGING_DIR)/usr
else
GST_PLUGINS_BAD_IMX_DEPENDENCIES += openssl
GST_PLUGINS_BAD_IMX_CONF_OPTS += -with-hls-crypto=openssl
endif

else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-hls
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_KMS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-kms
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libdrm-imx
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-kms
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_LIBMMS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-libmms
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libmms
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-libmms
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_DTLS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-dtls
GST_PLUGINS_BAD_IMX_DEPENDENCIES += openssl
GST_PLUGINS_BAD_IMX_HAS_BSD2C_LICENSE = y
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-dtls
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_TTML),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-ttml
GST_PLUGINS_BAD_IMX_DEPENDENCIES += cairo libxml2 pango
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-ttml
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_MPEG2ENC),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-mpeg2enc
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libmpeg2 mjpegtools
GST_PLUGINS_BAD_IMX_HAS_GPL_LICENSE = y
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-mpeg2enc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_MUSEPACK),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-musepack
GST_PLUGINS_BAD_IMX_DEPENDENCIES += musepack
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-musepack
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_NEON),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-neon
GST_PLUGINS_BAD_IMX_DEPENDENCIES += neon
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-neon
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_OPENAL),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-openal
GST_PLUGINS_BAD_IMX_DEPENDENCIES += openal
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-openal
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_OPENH264),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-openh264
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libopenh264
GST_PLUGINS_BAD_IMX_HAS_BSD2C_LICENSE = y
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-openh264
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_OPENJPEG),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-openjpeg
GST_PLUGINS_BAD_IMX_DEPENDENCIES += openjpeg
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-openjpeg
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_OPUS),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-opus
GST_PLUGINS_BAD_IMX_DEPENDENCIES += opus
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-opus
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_RSVG),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-rsvg
GST_PLUGINS_BAD_IMX_DEPENDENCIES += librsvg
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-rsvg
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_SBC),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-sbc
GST_PLUGINS_BAD_IMX_DEPENDENCIES += sbc
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-sbc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_SHM),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-shm
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-shm
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_SNDFILE),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-sndfile
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libsndfile
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-sndfile
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_SRTP),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-srtp
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libsrtp
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-srtp
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_VOAACENC),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-voaacenc
GST_PLUGINS_BAD_IMX_DEPENDENCIES += vo-aacenc
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-voaacenc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_WEBP),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-webp
GST_PLUGINS_BAD_IMX_DEPENDENCIES += webp
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-webp
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_WEBRTC),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-webrtc
GST_PLUGINS_BAD_IMX_DEPENDENCIES += gst-plugins-base-imx libnice
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-webrtc
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_WEBRTCDSP),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-webrtcdsp
GST_PLUGINS_BAD_IMX_DEPENDENCIES += webrtc-audio-processing
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-webrtcdsp
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_WPE),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-wpe
GST_PLUGINS_BAD_IMX_DEPENDENCIES += libwpe wpewebkit wpebackend-fdo
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-wpe
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_PLUGIN_X265),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-x265
GST_PLUGINS_BAD_IMX_DEPENDENCIES += x265
GST_PLUGINS_BAD_IMX_HAS_GPL_LICENSE = y
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-x265
endif

ifeq ($(BR2_PACKAGE_GST_PLUGINS_BAD_IMX_ZBAR),y)
GST_PLUGINS_BAD_IMX_CONF_OPTS += --enable-zbar
GST_PLUGINS_BAD_IMX_DEPENDENCIES += zbar
else
GST_PLUGINS_BAD_IMX_CONF_OPTS += --disable-zbar
endif

# Add GPL license if GPL licensed plugins enabled.
ifeq ($(GST_PLUGINS_BAD_IMX_HAS_GPL_LICENSE),y)
GST_PLUGINS_BAD_IMX_LICENSE += , GPL-2.0+
GST_PLUGINS_BAD_IMX_LICENSE_FILES += COPYING
endif

# Add BSD license if BSD licensed plugins enabled.
ifeq ($(GST_PLUGINS_BAD_IMX_HAS_BSD2C_LICENSE),y)
GST_PLUGINS_BAD_IMX_LICENSE += , BSD-2-Clause
endif

# Add Unknown license if Unknown licensed plugins enabled.
ifeq ($(GST_PLUGINS_BAD_IMX_HAS_UNKNOWN_LICENSE),y)
GST_PLUGINS_BAD_IMX_LICENSE += , UNKNOWN
endif

# Use the following command to extract license info for plugins.
# # find . -name 'plugin-*.xml' | xargs grep license

define GST_PLUGINS_BAD_IMX_RUN_AUTOGEN
        cd $(@D) && ./autogen.sh
endef
GST_PLUGINS_BAD_IMX_PRE_CONFIGURE_HOOKS += GST_PLUGINS_BAD_IMX_RUN_AUTOGEN

$(eval $(autotools-package))
