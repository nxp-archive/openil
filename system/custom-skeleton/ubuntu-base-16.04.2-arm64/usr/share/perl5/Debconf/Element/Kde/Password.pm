#!/usr/bin/perl -w
# This file was preprocessed, do not edit!


package Debconf::Element::Kde::Password;
use strict;
use QtCore4;
use QtGui4;
use base qw(Debconf::Element::Kde);


sub create {
	my $this=shift;
	
	$this->SUPER::create(@_);
	$this->startsect;
	$this->widget(Qt::LineEdit($this->cur->top));
	$this->widget->show;
	$this->widget->setEchoMode(2);
	$this->addwidget($this->description);
	$this->addhelp;
	$this->addwidget($this->widget);
	$this->endsect;
}


sub value {
	my $this=shift;
	
	my $text = $this->widget->text();
	$text = $this->question->value if $text eq '';
	return $text;
}


1
