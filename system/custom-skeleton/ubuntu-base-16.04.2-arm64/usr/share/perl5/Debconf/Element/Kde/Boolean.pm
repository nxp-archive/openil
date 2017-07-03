#!/usr/bin/perl -w
# This file was preprocessed, do not edit!


package Debconf::Element::Kde::Boolean;
use strict;
use QtCore4;
use QtGui4;
use base qw(Debconf::Element::Kde);
use Debconf::Encoding qw(to_Unicode);


sub create {
	my $this=shift;
	
	$this->SUPER::create(@_);
	
	$this->startsect;
	$this->widget(Qt::CheckBox( to_Unicode($this->question->description)));
	$this->widget->setChecked(($this->question->value eq 'true') ? 1 : 0);
	$this->widget->setText(to_Unicode($this->question->description));
	$this->adddescription;
	$this->addhelp;
	$this->addwidget($this->widget);
	$this->endsect;
}


sub value {
	my $this = shift;
	
	if ($this -> widget -> isChecked) {
		return "true";
	}
	else {
		return "false";
	}
}


1
