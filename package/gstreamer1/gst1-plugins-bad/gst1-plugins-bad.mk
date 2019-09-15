################################################################################
#
# gst1-plugins-bad
#
################################################################################

GST1_PLUGINS_BAD_VERSION = 1.16.0
GST1_PLUGINS_BAD_SOURCE = gst-plugins-bad-$(GST1_PLUGINS_BAD_VERSION).tar.xz
GST1_PLUGINS_BAD_SITE = https://gstreamer.freedesktop.org/src/gst-plugins-bad
GST1_PLUGINS_BAD_INSTALL_STAGING = YES
# Additional plugin licenses will be appended to GST1_PLUGINS_BAD_LICENSE and
# GST1_PLUGINS_BAD_LICENSE_FILES if enabled.
GST1_PLUGINS_BAD_LICENSE_FILES = COPYING.LIB
GST1_PLUGINS_BAD_LICENSE := LGPL-2.0+, LGPL-2.1+

GST1_PLUGINS_BAD_CONF_OPTS = \
	--disable-examples \
	--disable-valgrind \
	--disable-directsound \
	--disable-direct3d \
	--disable-winks \
	--disable-android_media \
	--disable-apple_media \
	--disable-introspection

# Options which require currently unpackaged libraries
GST1_PLUGINS_BAD_CONF_OPTS += \
	--disable-avc \
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
	--disable-fluidsynth \
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
	--disable-vdpau \
	--disable-schro \
	--disable-spandsp \
	--disable-gtk3 \
	--disable-iqa \
	--disable-opencv

GST1_PLUGINS_BAD_DEPENDENCIES = gst1-plugins-base gstreamer1

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
# RPI has odd locations for several required headers.
GST1_PLUGINS_BAD_CONF_ENV += \
	CPPFLAGS="$(TARGET_CPPFLAGS) \
	-I$(STAGING_DIR)/usr/include/IL \
	-I$(STAGING_DIR)/usr/include/interface/vcos/pthreads \
	-I$(STAGING_DIR)/usr/include/interface/vmcs_host/linux"
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_WAYLAND),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-wayland
GST1_PLUGINS_BAD_DEPENDENCIES += wayland wayland-protocols
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-wayland
endif

ifeq ($(BR2_PACKAGE_ORC),y)
GST1_PLUGINS_BAD_DEPENDENCIES += orc
GST1_PLUGINS_BAD_CONF_OPTS += --enable-orc
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_BLUEZ),y)
GST1_PLUGINS_BAD_DEPENDENCIES += bluez5_utils
GST1_PLUGINS_BAD_CONF_OPTS += --enable-bluez
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-bluez
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_ACCURIP),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-accurip
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-accurip
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_ADPCMDEC),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-adpcmdec
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-adpcmdec
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_ADPCMENC),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-adpcmenc
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-adpcmenc
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_AIFF),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-aiff
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-aiff
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_ASFMUX),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-asfmux
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-asfmux
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_AUDIOBUFFERSPLIT),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-audiobuffersplit
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-audiobuffersplit
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_AUDIOFXBAD),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-audiofxbad
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-audiofxbad
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_AUDIOLATENCY),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-audiolatency
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-audiolatency
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_AUDIOMIXMATRIX),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-audiomixmatrix
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-audiomixmatrix
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_AUDIOVISUALIZERS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-audiovisualizers
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-audiovisualizers
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_AUTOCONVERT),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-autoconvert
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-autoconvert
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_BAYER),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-bayer
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-bayer
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_CAMERABIN2),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-camerabin2
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-camerabin2
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_COLOREFFECTS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-coloreffects
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-coloreffects
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_DEBUGUTILS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-debugutils
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-debugutils
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_DVBSUBOVERLAY),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-dvbsuboverlay
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-dvbsuboverlay
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_DVDSPU),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-dvdspu
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-dvdspu
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_FACEOVERLAY),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-faceoverlay
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-faceoverlay
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_FESTIVAL),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-festival
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-festival
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_FIELDANALYSIS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-fieldanalysis
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-fieldanalysis
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_FREEVERB),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-freeverb
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-freeverb
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_FREI0R),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-frei0r
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-frei0r
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_GAUDIEFFECTS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-gaudieffects
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-gaudieffects
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_GEOMETRICTRANSFORM),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-geometrictransform
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-geometrictransform
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_GDP),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-gdp
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-gdp
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_ID3TAG),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-id3tag
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-id3tag
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_INTER),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-inter
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-inter
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_INTERLACE),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-interlace
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-interlace
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_IVFPARSE),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-ivfparse
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-ivfparse
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_IVTC),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-ivtc
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-ivtc
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_JP2KDECIMATOR),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-jp2kdecimator
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-jp2kdecimator
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_JPEGFORMAT),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-jpegformat
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-jpegformat
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_LIBRFB),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-librfb
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-librfb
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_MIDI),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-midi
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-midi
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_MPEGDEMUX),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-mpegdemux
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-mpegdemux
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_MPEGTSDEMUX),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-mpegtsdemux
GST1_PLUGINS_BAD_HAS_UNKNOWN_LICENSE = y
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-mpegtsdemux
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_MPEGTSMUX),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-mpegtsmux
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-mpegtsmux
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_MPEGPSMUX),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-mpegpsmux
GST1_PLUGINS_BAD_HAS_UNKNOWN_LICENSE = y
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-mpegpsmux
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_MXF),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-mxf
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-mxf
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_NETSIM),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-netsim
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-netsim
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_ONVIF),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-onvif
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-onvif
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_PCAPPARSE),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-pcapparse
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-pcapparse
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_PNM),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-pnm
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-pnm
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_PROXY),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-proxy
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-proxy
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_RAWPARSE),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-rawparse
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-rawparse
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_REMOVESILENCE),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-removesilence
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-removesilence
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_RTMP),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-rtmp
GST1_PLUGINS_BAD_DEPENDENCIES += rtmpdump
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-rtmp
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_SDP),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-sdp
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-sdp
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_SEGMENTCLIP),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-segmentclip
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-segmentclip
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_SIREN),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-siren
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-siren
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_SMOOTH),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-smooth
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-smooth
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_SPEED),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-speed
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-speed
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_SUBENC),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-subenc
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-subenc
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_TIMECODE),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-timecode
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-timecode
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_VIDEOFILTERS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-videofilters
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-videofilters
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_VIDEOFRAME_AUDIOLEVEL),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-videoframe_audiolevel
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-videoframe_audiolevel
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_VIDEOPARSERS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-videoparsers
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-videoparsers
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_VIDEOSIGNAL),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-videosignal
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-videosignal
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_VMNC),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-vmnc
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-vmnc
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_Y4M),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-y4m
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-y4m
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_YADIF),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-yadif
GST1_PLUGINS_BAD_HAS_GPL_LICENSE = y
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-yadif
endif

# Plugins with dependencies

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_ASSRENDER),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-assrender
GST1_PLUGINS_BAD_DEPENDENCIES += libass
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-assrender
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_BZ2),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-bz2
GST1_PLUGINS_BAD_DEPENDENCIES += bzip2
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-bz2
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_CURL),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-curl
GST1_PLUGINS_BAD_DEPENDENCIES += libcurl
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-curl
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_DASH),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-dash
GST1_PLUGINS_BAD_DEPENDENCIES += libxml2
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-dash
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_DECKLINK),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-decklink
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-decklink
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_DIRECTFB),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-directfb
GST1_PLUGINS_BAD_DEPENDENCIES += directfb
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-directfb
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_DVB),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-dvb
GST1_PLUGINS_BAD_DEPENDENCIES += dtv-scan-tables
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-dvb
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_FAAD),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-faad
GST1_PLUGINS_BAD_DEPENDENCIES += faad2
GST1_PLUGINS_BAD_HAS_GPL_LICENSE = y
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-faad
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_FBDEV),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-fbdev
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-fbdev
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_FDK_AAC),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-fdk_aac
GST1_PLUGINS_BAD_DEPENDENCIES += fdk-aac
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-fdk_aac
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_GL),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-gl
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-gl
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_HLS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-hls

ifeq ($(BR2_PACKAGE_NETTLE),y)
GST1_PLUGINS_BAD_DEPENDENCIES += nettle
GST1_PLUGINS_BAD_CONF_OPTS += --with-hls-crypto=nettle
else ifeq ($(BR2_PACKAGE_LIBGCRYPT),y)
GST1_PLUGINS_BAD_DEPENDENCIES += libgcrypt
GST1_PLUGINS_BAD_CONF_OPTS += --with-hls-crypto=libgcrypt \
	--with-libgcrypt-prefix=$(STAGING_DIR)/usr
else
GST1_PLUGINS_BAD_DEPENDENCIES += openssl
GST1_PLUGINS_BAD_CONF_OPTS += --with-hls-crypto=openssl
endif

else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-hls
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_KMS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-kms
GST1_PLUGINS_BAD_DEPENDENCIES += libdrm
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-kms
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_LIBMMS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-libmms
GST1_PLUGINS_BAD_DEPENDENCIES += libmms
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-libmms
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_DTLS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-dtls
GST1_PLUGINS_BAD_DEPENDENCIES += openssl
GST1_PLUGINS_BAD_HAS_BSD2C_LICENSE = y
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-dtls
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_TTML),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-ttml
GST1_PLUGINS_BAD_DEPENDENCIES += cairo libxml2 pango
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-ttml
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_MPEG2ENC),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-mpeg2enc
GST1_PLUGINS_BAD_DEPENDENCIES += libmpeg2 mjpegtools
GST1_PLUGINS_BAD_HAS_GPL_LICENSE = y
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-mpeg2enc
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_MUSEPACK),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-musepack
GST1_PLUGINS_BAD_DEPENDENCIES += musepack
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-musepack
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_NEON),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-neon
GST1_PLUGINS_BAD_DEPENDENCIES += neon
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-neon
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_OPENAL),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-openal
GST1_PLUGINS_BAD_DEPENDENCIES += openal
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-openal
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_OPENH264),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-openh264
GST1_PLUGINS_BAD_DEPENDENCIES += libopenh264
GST1_PLUGINS_BAD_HAS_BSD2C_LICENSE = y
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-openh264
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_OPENJPEG),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-openjpeg
GST1_PLUGINS_BAD_DEPENDENCIES += openjpeg
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-openjpeg
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_OPUS),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-opus
GST1_PLUGINS_BAD_DEPENDENCIES += opus
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-opus
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_RSVG),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-rsvg
GST1_PLUGINS_BAD_DEPENDENCIES += librsvg
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-rsvg
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_SBC),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-sbc
GST1_PLUGINS_BAD_DEPENDENCIES += sbc
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-sbc
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_SHM),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-shm
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-shm
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_SNDFILE),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-sndfile
GST1_PLUGINS_BAD_DEPENDENCIES += libsndfile
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-sndfile
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_SRTP),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-srtp
GST1_PLUGINS_BAD_DEPENDENCIES += libsrtp
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-srtp
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_VOAACENC),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-voaacenc
GST1_PLUGINS_BAD_DEPENDENCIES += vo-aacenc
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-voaacenc
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_WEBP),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-webp
GST1_PLUGINS_BAD_DEPENDENCIES += webp
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-webp
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_WEBRTC),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-webrtc
GST1_PLUGINS_BAD_DEPENDENCIES += gst1-plugins-base libnice
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-webrtc
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_WEBRTCDSP),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-webrtcdsp
GST1_PLUGINS_BAD_DEPENDENCIES += webrtc-audio-processing
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-webrtcdsp
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_WPE),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-wpe
GST1_PLUGINS_BAD_DEPENDENCIES += wpewebkit
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-wpe
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_X265),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-x265
GST1_PLUGINS_BAD_DEPENDENCIES += x265
GST1_PLUGINS_BAD_HAS_GPL_LICENSE = y
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-x265
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD_ZBAR),y)
GST1_PLUGINS_BAD_CONF_OPTS += --enable-zbar
GST1_PLUGINS_BAD_DEPENDENCIES += zbar
else
GST1_PLUGINS_BAD_CONF_OPTS += --disable-zbar
endif

# Add GPL license if GPL licensed plugins enabled.
ifeq ($(GST1_PLUGINS_BAD_HAS_GPL_LICENSE),y)
GST1_PLUGINS_BAD_LICENSE := $(GST1_PLUGINS_BAD_LICENSE), GPL-2.0+
GST1_PLUGINS_BAD_LICENSE_FILES += COPYING
endif

# Add BSD license if BSD licensed plugins enabled.
ifeq ($(GST1_PLUGINS_BAD_HAS_BSD2C_LICENSE),y)
GST1_PLUGINS_BAD_LICENSE := $(GST1_PLUGINS_BAD_LICENSE), BSD-2-Clause
endif

# Add Unknown license if Unknown licensed plugins enabled.
ifeq ($(GST1_PLUGINS_BAD_HAS_UNKNOWN_LICENSE),y)
GST1_PLUGINS_BAD_LICENSE := $(GST1_PLUGINS_BAD_LICENSE), UNKNOWN
endif

# Use the following command to extract license info for plugins.
# # find . -name 'plugin-*.xml' | xargs grep license

$(eval $(autotools-package))
