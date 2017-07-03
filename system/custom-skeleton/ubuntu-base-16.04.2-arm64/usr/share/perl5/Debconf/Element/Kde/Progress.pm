#!/usr/bin/perl -w
# This file was preprocessed, do not edit!


package Debconf::Element::Kde::Progress;
use strict;
use QtCore4;
use QtGui4;
use base qw(Debconf::Element::Kde);
use Debconf::Encoding qw(to_Unicode);


sub start {
	my $this=shift;
	my $description=to_Unicode($this->question->description);
	my $frontend=$this->frontend;

	$this->SUPER::create($frontend->frame);

	$this->startsect;
	$this->addhelp;
	$this->adddescription;
	my $vbox = Qt::VBoxLayout($this->widget);

	$this->progress_bar(Qt::ProgressBar($this->cur->top));
	$this->progress_bar->setMinimum($this->progress_min());
	$this->progress_bar->setMaximum($this->progress_max());
	$this->progress_bar->show;
	$this->addwidget($this->progress_bar);

	$this->progress_label(Qt::Label($this->cur->top));
	$this->progress_label->show;
	$this->addwidget($this->progress_label);

	$this->endsect;
}

sub set {
	my $this=shift;
	my $value=shift;


	$this->progress_cur($value);
	$this->progress_bar->setValue($this->progress_cur);
	return 1;
}

sub info {
	my $this=shift;
	my $question=shift;

	$this->progress_label->setText(to_Unicode($question->description));
	
	return 1;
}

sub stop {
}

1;
