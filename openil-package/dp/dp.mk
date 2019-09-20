################################################################################
#
# DP firmware for NXP layerscape platforms
#
################################################################################

DP_BIN = $(call qstrip,$(BR2_PACKAGE_DP_BIN))
 
define DP_BUILD_CMDS
	cd $(@D)/ && wget https://www.nxp.com/lgfiles/sdk/ls1028a_bsp_01/ls1028a-dp-fw.bin &&\
	chmod +x ls1028a-dp-fw.bin && ./ls1028a-dp-fw.bin --auto-accept && \
	$(INSTALL) -Dm0644 ls1028a-dp-fw/cadence/$(DP_BIN) $(BINARIES_DIR)/ls1028a-dp-fw.bin;
endef

$(eval $(generic-package))
