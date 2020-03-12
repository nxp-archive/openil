################################################################################
#
# qoriq-perl-list-moreutils
#
################################################################################

QORIQ_PERL_LIST_MOREUTILS_VERSION = 0.426
QORIQ_PERL_LIST_MOREUTILS_SOURCE = List-MoreUtils-$(QORIQ_PERL_LIST_MOREUTILS_VERSION).tar.gz
QORIQ_PERL_LIST_MOREUTILS_SITE = http://search.cpan.org/CPAN/authors/id/R/RE/REHSACK
QORIQ_PERL_LIST_MOREUTILS_LICENSE = Apache
QORIQ_PERL_LIST_MOREUTILS_LICENSE_FILES = LICENSE

$(eval $(perl-package))
