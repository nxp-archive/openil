#!/usr/bin/perl -w
# This file was preprocessed, do not edit!


package Debconf::Element::Kde::Select;
use strict;
use QtCore4;
use QtGui4;
use base qw(Debconf::Element::Kde Debconf::Element::Select);
use Debconf::Encoding qw(to_Unicode);


sub create {
	my $this=shift;
	
	my $default=$this->translate_default;
	my @choices=map { to_Unicode($_) } $this->question->choices_split;
	
	$this->SUPER::create(@_);
	$this->startsect;
	$this->widget(Qt::ComboBox($this->cur->top));
	$this->widget->show;
	$this->widget->addItems(\@choices);
	if (defined($default) and length($default) != 0) {
		for (my $i = 0 ; $i < @choices ; $i++) {
			if ($choices[$i] eq $default ) {
				$this->widget->setCurrentIndex($i);# //FIXME find right index to_Unicode($default));
				last;
			}
		}
	}
	$this->addwidget($this->description);
	$this->addhelp;
	$this->addwidget($this->widget);
	$this->endsect;
}


sub value {
	my $this=shift;
	
	my @choices=$this->question->choices_split;
	return $this->translate_to_C_uni($this->widget->currentText());
}

*visible = \&Debconf::Element::Select::visible;


1
