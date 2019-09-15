################################################################################
#
# tpm2-abrmd
#
################################################################################

TPM2_ABRMD_VERSION = 2.0.3
TPM2_ABRMD_SITE = https://github.com/tpm2-software/tpm2-abrmd/releases/download/$(TPM2_ABRMD_VERSION)
TPM2_ABRMD_LICENSE = BSD-2-Clause
TPM2_ABRMD_LICENSE_FILES = LICENSE
TPM2_ABRMD_INSTALL_STAGING = YES
TPM2_ABRMD_DEPENDENCIES = dbus libglib2 tpm2-tss host-pkgconf

# -fstack-protector-all and FORTIFY_SOURCE=2 is used by
# default. Disable that so the BR2_SSP_* / BR2_FORTIFY_SOURCE_* options
# in the toolchain wrapper and CFLAGS are used instead
TPM2_ABRMD_CONF_ENV = \
	ax_cv_check_cflags___________Werror_______fstack_protector_all=no \
	ax_cv_check_ccppflags___________Werror_______U_FORTIFY_SOURCE=no \
	ax_cv_check_ccppflags___________Werror_______D_FORTIFY_SOURCE_2=no

TPM2_ABRMD_CONF_OPTS += \
	--with-systemdsystemunitdir=$(if $(BR2_INIT_SYSTEMD),/usr/lib/systemd/system,no) \
	--with-udevrulesdir=$(if $(BR2_PACKAGE_HAS_UDEV),/usr/lib/udev/rules.d,no)

define TPM2_ABRMD_INSTALL_INIT_SYSTEMD
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) \
		install-systemdpresetDATA install-systemdsystemunitDATA
endef

define TPM2_ABRMD_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(TPM2_ABRMD_PKGDIR)/S80tpm2-abrmd \
		$(TARGET_DIR)/etc/init.d/S80tpm2-abrmd
endef

define TPM2_ABRMD_USERS
	tss -1 tss -1 * - - - TPM2 Access Broker & Resource Management daemon
endef

$(eval $(autotools-package))
