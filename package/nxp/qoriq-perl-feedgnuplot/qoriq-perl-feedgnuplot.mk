################################################################################
#
# qoriq-perl-feedgnuplot
#
################################################################################

QORIQ_PERL_FEEDGNUPLOT_VERSION = $(call qstrip,$(BR2_PACKAGE_QORIQ_PERL_FEEDGNUPLOT_VERSION))
QORIQ_PERL_FEEDGNUPLOT_SITE = https://github.com/dkogan/feedgnuplot.git
QORIQ_PERL_FEEDGNUPLOT_SITE_METHOD = git
QORIQ_PERL_FEEDGNUPLOT_DEPENDENCIES = gnuplot qoriq-perl-list-moreutils qoriq-perl-exporter-tiny
QORIQ_PERL_FEEDGNUPLOT_LICENSE = Artistic or GPL-1.0+
QORIQ_PERL_FEEDGNUPLOT_LICENSE_FILES = LICENSE

$(eval $(perl-package))
