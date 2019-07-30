################################################################################
#
# yang module tsn
#
################################################################################
YANG_MODEL_VERSION = b1df41d72ecbfb38c13e96eff42d8f027997baed
YANG_MODEL_SITE = https://github.com/YangModels/yang.git
YANG_MODEL_SITE_METHOD = git
YANG_MODEL_LICENSE = MIT
YANG_MODEL_LICENSE_FILES = LICENSE

define YANG_MODEL_CONFIGURE_CMDS
	@:
endef

define YANG_MODEL_BUILD_CMDS
	@:
endef

define YANG_MODEL_INSTALL_TARGET_CMDS
	@:
endef

$(eval $(autotools-package))
