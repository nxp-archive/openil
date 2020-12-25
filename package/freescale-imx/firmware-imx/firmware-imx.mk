################################################################################
#
# firmware-imx
#
################################################################################

FIRMWARE_IMX_VERSION = 8.10
FIRMWARE_IMX_SITE = $(FREESCALE_IMX_SITE)
FIRMWARE_IMX_SOURCE = firmware-imx-$(FIRMWARE_IMX_VERSION).bin

FIRMWARE_IMX_LICENSE = NXP Semiconductor Software License Agreement
FIRMWARE_IMX_LICENSE_FILES = EULA COPYING
FIRMWARE_IMX_REDISTRIBUTE = NO

FIRMWARE_IMX_BLOBS = sdma vpu

define FIRMWARE_IMX_EXTRACT_CMDS
	$(call FREESCALE_IMX_EXTRACT_HELPER,$(FIRMWARE_IMX_DL_DIR)/$(FIRMWARE_IMX_SOURCE))
endef

ifeq ($(BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8M)$(BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MM)$(BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MP)$(BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MN),y)
FIRMWARE_IMX_INSTALL_IMAGES = YES
LPDDR_FW_VERSION = _201904
FIRMWARE_IMX_DDRFW_DIR = $(@D)/firmware/ddr/synopsys
define FIRMWARE_IMX_BUILD_CMDS
	$(TARGET_OBJCOPY) -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_1d_imem$(LPDDR_FW_VERSION).bin \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_1d_imem_pad.bin
	$(TARGET_OBJCOPY) -I binary -O binary --pad-to 0x4000 --gap-fill=0x0 \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_1d_dmem$(LPDDR_FW_VERSION).bin \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_1d_dmem_pad.bin
	cat $(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_1d_imem_pad.bin \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_1d_dmem_pad.bin > \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_1d_fw.bin

	$(TARGET_OBJCOPY) -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_2d_imem$(LPDDR_FW_VERSION).bin \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_2d_imem_pad.bin
	cat $(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_2d_imem_pad.bin \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_2d_dmem$(LPDDR_FW_VERSION).bin > \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_2d_fw.bin
endef

define FIRMWARE_IMX_INSTALL_IMAGES_CMDS
	# Create padded versions of lpddr4_pmu_* and generate lpddr4_pmu_train_fw.bin.
	# lpddr4_pmu_train_fw.bin is needed when generating imx8-boot-sd.bin
	# which is done in post-image script.
	cat $(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_1d_fw.bin \
		$(FIRMWARE_IMX_DDRFW_DIR)/lpddr4_pmu_train_2d_fw.bin > \
		$(BINARIES_DIR)/lpddr4_pmu_train_fw.bin
	cp $(@D)/firmware/hdmi/cadence/signed_hdmi_imx8m.bin \
		$(BINARIES_DIR)/signed_hdmi_imx8m.bin
endef

ifeq ($(BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MM)$(BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MP),y)
FIRMWARE_IMX_BLOBS = sdma
define FIRMWARE_IMX_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/imx
	for blobdir in $(FIRMWARE_IMX_BLOBS); do \
		cp -r $(@D)/firmware/$${blobdir} $(TARGET_DIR)/lib/firmware/imx; \
	done
endef
endif
else ifeq ($(BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8X),y)
define FIRMWARE_IMX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/firmware/vpu/vpu_fw_imx8_dec.bin \
		$(TARGET_DIR)/lib/firmware/vpu/vpu_fw_imx8_dec.bin
	$(INSTALL) -D -m 0644 $(@D)/firmware/vpu/vpu_fw_imx8_enc.bin \
		$(TARGET_DIR)/lib/firmware/vpu/vpu_fw_imx8_enc.bin
endef
else
define FIRMWARE_IMX_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/imx
	for blobdir in $(FIRMWARE_IMX_BLOBS); do \
		cp -r $(@D)/firmware/$${blobdir} $(TARGET_DIR)/lib/firmware; \
	done
	cp -r $(@D)/firmware/epdc $(TARGET_DIR)/lib/firmware/imx
	mv $(TARGET_DIR)/lib/firmware/imx/epdc/epdc_ED060XH2C1.fw.nonrestricted \
		$(TARGET_DIR)/lib/firmware/imx/epdc/epdc_ED060XH2C1.fw
endef
endif

$(eval $(generic-package))
