#!/usr/bin/perl -w
# This file was preprocessed, do not edit!


package Debconf::Element::Kde::Note;
use strict;
use Debconf::Gettext;
use Qt;
use Debconf::Element::Noninteractive::Note;
use base qw(Debconf::Element::Kde);


sub create {
	my $this=shift;
	$this->SUPER::create(@_);
	$this->startsect;
	$this->adddescription;
	$this->addhelp;
	$this->endsect;
}


1
