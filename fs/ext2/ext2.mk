################################################################################
#
# Build the ext2 root filesystem image
#
################################################################################

EXT2_SIZE = $(call qstrip,$(BR2_TARGET_ROOTFS_EXT2_SIZE))

EXT2_MKFS_OPTS = $(call qstrip,$(BR2_TARGET_ROOTFS_EXT2_MKFS_OPTIONS))

# qstrip results in stripping consecutive spaces into a single one. So the
# variable is not qstrip-ed to preserve the integrity of the string value.
EXT2_LABEL = $(subst ",,$(BR2_TARGET_ROOTFS_EXT2_LABEL))
#" Syntax highlighting... :-/ )

EXT2_OPTS = \
	-d $(TARGET_DIR) \
	-r $(BR2_TARGET_ROOTFS_EXT2_REV) \
	-N $(BR2_TARGET_ROOTFS_EXT2_INODES) \
	-m $(BR2_TARGET_ROOTFS_EXT2_RESBLKS) \
	-L "$(EXT2_LABEL)" \
	$(EXT2_MKFS_OPTS)

ROOTFS_EXT2_DEPENDENCIES = host-e2fsprogs

define ROOTFS_EXT2_CMD
	rm -f $@
	if [ "x$(EXT2_SIZE)" != "x" ]
	then
		echo "The size of rootfs.ext2 is $(EXT2_SIZE)"
		$(HOST_DIR)/sbin/mkfs.ext$(BR2_TARGET_ROOTFS_EXT2_GEN) $(EXT2_OPTS) $@ \
			"$(EXT2_SIZE)" || { ret=$$?; \
		echo "*** Maybe you need to increase the filesystem size (BR2_TARGET_ROOTFS_EXT2_SIZE)" 1>&2; \
		exit $$ret; }
	else
		EXT2_SIZE_E=`du -s  $(TARGET_DIR) | cut -f 1`
		while true
		do
			EXT2_SIZE_E=$$(($${EXT2_SIZE_E} + 100 * 1024))
			echo "The size of rootfs.ext2 will set to $${EXT2_SIZE_E}"
			$(HOST_DIR)/sbin/mkfs.ext$(BR2_TARGET_ROOTFS_EXT2_GEN) $(EXT2_OPTS) $@ "$${EXT2_SIZE_E}K" \
			&& break
		done

		FREE_BLOCK=`dumpe2fs $@  2>/dev/null  | grep -i "^Free blocks" | awk -F ':' '{print $$2}'`
		BLOCK_COUNT=`dumpe2fs $@  2>/dev/null  | grep -i "^Block count" | awk -F ':' '{print $$2}'`
		BLOCK_SIZE=`dumpe2fs $@  2>/dev/null  | grep -i "^Block size" | awk -F ':' '{print $$2}'`

		FREE_BLOCK=$$(($${FREE_BLOCK}*$${BLOCK_SIZE}/1024))
		BLOCK_COUNT=$$(($${BLOCK_COUNT}*$${BLOCK_SIZE}/1024))
		USED_BLOCK=$$(($${BLOCK_COUNT}-$${FREE_BLOCK}))

		EXT2_SIZE_E=$$(($${USED_BLOCK}*100/90))

		if [ $$(($${EXT2_SIZE_E} - $${USED_BLOCK})) -le 51200 ]
		then
			EXT2_SIZE_E=$$(($${USED_BLOCK} + 51200))
		fi

		rm -f $@
		$(HOST_DIR)/sbin/mkfs.ext$(BR2_TARGET_ROOTFS_EXT2_GEN) $(EXT2_OPTS) $@ "$${EXT2_SIZE_E}K"
	fi

endef

ifneq ($(BR2_TARGET_ROOTFS_EXT2_GEN),2)
define ROOTFS_EXT2_SYMLINK
	ln -sf rootfs.ext2$(ROOTFS_EXT2_COMPRESS_EXT) $(BINARIES_DIR)/rootfs.ext$(BR2_TARGET_ROOTFS_EXT2_GEN)$(ROOTFS_EXT2_COMPRESS_EXT)
endef
ROOTFS_EXT2_POST_GEN_HOOKS += ROOTFS_EXT2_SYMLINK
endif

$(eval $(rootfs))
