#!/usr/bin/perl -w
# This file was preprocessed, do not edit!


package Debconf::Element::Kde::Multiselect;
use strict;
use QtCore4;
use QtGui4;
use base qw(Debconf::Element::Kde Debconf::Element::Multiselect);
use Debconf::Encoding qw(to_Unicode);


sub create {
	my $this=shift;
	
	my @choices = $this->question->choices_split;
	my %default = map { $_ => 1 } $this->translate_default;
	
	$this->SUPER::create(@_);
	$this->startsect;
	$this->adddescription;
	$this->addhelp;
    
	my @buttons;
	for (my $i=0; $i <= $#choices; $i++) {
		$buttons[$i] = Qt::CheckBox($this->cur->top);
		$buttons[$i]->setText(to_Unicode($choices[$i]));
		$buttons[$i]->show;
		$buttons[$i]->setChecked($default{$choices[$i]} ? 1 : 0);
		$this->addwidget($buttons[$i]);
	}
	
	$this->buttons(\@buttons);
	$this->endsect;
}


sub value {
	my $this = shift;
	my @buttons = @{$this->buttons};
	my ($ret, $val);
	my @vals;
	$this->question->template->i18n('');
	my @choices=$this->question->choices_split;
	$this->question->template->i18n(1);
	
	for (my $i = 0; $i <= $#choices; $i++) {
	if ($buttons [$i] -> isChecked()) {
		push @vals, $choices[$i];
	}
	}
	return join(', ', $this->order_values(@vals));
}

*visible = \&Debconf::Element::Multiselect::visible;


1
