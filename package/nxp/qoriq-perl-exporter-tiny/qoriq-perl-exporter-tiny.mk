################################################################################
#
# qoriq-perl-exporter-tiny
#
################################################################################

QORIQ_PERL_EXPORTER_TINY_VERSION = 1.000000
QORIQ_PERL_EXPORTER_TINY_SOURCE = Exporter-Tiny-$(QORIQ_PERL_EXPORTER_TINY_VERSION).tar.gz
QORIQ_PERL_EXPORTER_TINY_SITE = http://search.cpan.org/CPAN/authors/id/T/TO/TOBYINK
QORIQ_PERL_EXPORTER_TINY_LICENSE = Artistic or GPL-1.0+
QORIQ_PERL_EXPORTER_TINY_LICENSE_FILES = LICENSE

$(eval $(perl-package))
