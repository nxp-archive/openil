#!/usr/bin/perl -w
# This file was preprocessed, do not edit!


package Debconf::Element::Kde::ElementWidget;
use QtCore4;
use QtCore4::isa @ISA = qw(Qt::Widget);
use QtGui4;


sub NEW {
	shift->SUPER::NEW ($_[0]);
	this->{mytop} = undef;
}


sub settop {
    this->{mytop} = shift;
}


sub init {
	this->{toplayout} =  Qt::VBoxLayout(this);
	this->{mytop} = Qt::Widget(this);
	this->{toplayout}->addWidget (this->{mytop});
	this->{layout} = Qt::VBoxLayout();
	this->{mytop}->setLayout(this->{layout});
}


sub destroy {
	this->{toplayout} -> removeWidget (this->{mytop});
	undef this->{mytop};
}


sub top {
    return this->{mytop};
}


sub addwidget {
    this->{layout}->addWidget(@_);
}


sub addlayout {
    this->{layout}->addLayout (@_);
}






package Debconf::Element::Kde;
use strict;
use QtCore4;
use QtGui4;
use Debconf::Gettext;
use base qw(Debconf::Element);
use Debconf::Element::Kde::ElementWidget;
use Debconf::Encoding qw(to_Unicode);


sub create {
	my $this=shift;
	$this->parent(shift);
	$this->top(Debconf::Element::Kde::ElementWidget($this->parent, undef,
	                                                undef, undef));
	$this->top->init;
	$this->top->show;
}


sub destroy {
	my $this=shift;
	$this->top(undef);
}


sub addwidget {
	my $this=shift;
	my $widget=shift;
	$this->cur->addwidget($widget);
}


sub description {
	my $this=shift;
	my $label=Qt::Label($this->cur->top);
	$label->setText("<b>".to_Unicode($this->question->description."</b>"));
	$label->show;
	return $label;
}


sub startsect {
	my $this = shift;
	my $ew = Debconf::Element::Kde::ElementWidget($this->top);
	$ew->init;
	$this->cur($ew);
	$this->top->addwidget($ew);
	$ew->show;
}


sub endsect {
	my $this = shift;
	$this->cur($this->top);
}


sub adddescription {
	my $this=shift;
	my $label=$this->description;
	$this->addwidget($label);
}


sub addhelp {
	my $this=shift;
    
	my $help=to_Unicode($this->question->extended_description);
	return unless length $help;
	my $label=Qt::Label($this->cur->top);
	$label->setText($help);
	$label->setWordWrap(1);
	$this->addwidget($label); # line1
	$label->setMargin(5);
	$label->show;
}


sub value {
	my $this=shift;
	return '';
}


1
