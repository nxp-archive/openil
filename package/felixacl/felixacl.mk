################################################################################
#
# felix-acl-tool
#
################################################################################

FELIXACL_VERSION = a6367162c6024e2b62759bbba394be6c185f2159
FELIXACL_SITE = https://github.com/openil/felix-acl-tool.git
FELIXACL_SITE_METHOD = git
FELIXACL_INSTALL_STAGING = YES
FELIXACL_LICENSE = MIT
FELIXACL_LICENSE_FILES = LICENSE

define FELIXACL_BUILD_CMDS
	mkdir -p $(@D)/include/linux/;
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/linux-$(BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION)/include/uapi/linux/tsn.h $(@D)/include/linux/;
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

$(eval $(cmake-package))
