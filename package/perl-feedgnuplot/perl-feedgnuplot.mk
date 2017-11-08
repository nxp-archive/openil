PERL_FEEDGNUPLOT_VERSION = v1.45
PERL_FEEDGNUPLOT_SITE = https://github.com/dkogan/feedgnuplot.git
PERL_FEEDGNUPLOT_SITE_METHOD = git
PERL_FEEDGNUPLOT_DEPENDENCIES = gnuplot perl-list-moreutils perl-exporter-tiny
PERL_FEEDGNUPLOT_LICENSE = Artistic or GPL-1.0+
PERL_FEEDGNUPLOT_LICENSE_FILES = LICENSE

$(eval $(perl-package))
