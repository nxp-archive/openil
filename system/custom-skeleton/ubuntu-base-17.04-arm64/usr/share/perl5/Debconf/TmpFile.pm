#!/usr/bin/perl
# This file was preprocessed, do not edit!


package Debconf::TmpFile;
use strict;
use IO::File;
use Fcntl;


my $filename;

sub open {
	my $fh; # will be autovivified
	my $ext=shift || '';
	do { $filename=POSIX::tmpnam().$ext }
	until sysopen($fh, $filename, O_WRONLY|O_TRUNC|O_CREAT|O_EXCL, 0600);
	return $fh;
}


sub filename {
	return $filename;
}


sub cleanup {
	unlink $filename;
}


1
