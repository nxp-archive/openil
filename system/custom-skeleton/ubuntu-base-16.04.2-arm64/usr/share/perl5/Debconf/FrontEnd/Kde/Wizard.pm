#!/usr/bin/perl -w
# This file was preprocessed, do not edit!


package Debconf::FrontEnd::Kde::Wizard;
use strict;
use utf8;
use Debconf::Log ':all';
use QtCore4;
use QtGui4;
use QtCore4::isa qw(Qt::Widget Debconf::FrontEnd::Kde::Ui_DebconfWizard);
use QtCore4::slots 'goNext' => [], 'goBack' => [], 'goBye' => [];
use Debconf::FrontEnd::Kde::Ui_DebconfWizard;

use Data::Dumper;
sub NEW {
	
	my ( $class, $parent ) = @_;
	$class->SUPER::NEW($parent );
	this->{frontend} = $_[3];
	
	my $ui = this->{ui} = $class->setupUi(this);

	my $bNext = $ui->{bNext};
	my $bBack = $ui->{bBack};
	my $bCancel = $ui->{bCancel};
	this->setObjectName("Wizard");
	this->connect($bNext, SIGNAL 'clicked ()', SLOT 'goNext ()');
	this->connect($bBack, SIGNAL 'clicked ()', SLOT 'goBack ()');
	this->connect($bCancel, SIGNAL 'clicked ()', SLOT 'goBye ()');

	this->{ui}->mainFrame->setObjectName("mainFrame");;
}


sub setTitle {
	this->{ui}->{title}->setText($_[0]);
}


sub setNextEnabled {
	this->{ui}->{bNext}->setEnabled(shift);
}


sub setBackEnabled {
	this->{ui}->{bBack}->setEnabled(shift);
}


sub goNext {
	debug frontend => "QTF: -- LEAVE EVENTLOOP --------";
	this->{frontend}->goback(0);
	this->{frontend}->win->close;
}


sub goBack {
	debug frontend => "QTF: -- LEAVE EVENTLOOP --------";
	this->{frontend}->goback(1);
	this->{frontend}->win->close;
}

sub setMainFrameLayout {
	debug frontend => "QTF: -- SET MAIN LAYOUT --------";
   if(this->{ui}->mainFrame->layout) {
      this->{ui}->mainFrame->layout->DESTROY;
    }
   this->{ui}->mainFrame->setLayout(shift);
}


sub goBye {
	debug developer => "QTF: -- LEAVE EVENTLOOP --------";
	this->{frontend}->cancelled(1);
	this->{frontend}->win->close;
}


1;
