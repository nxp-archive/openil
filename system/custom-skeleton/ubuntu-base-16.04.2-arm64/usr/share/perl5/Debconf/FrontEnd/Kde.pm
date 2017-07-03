#!/usr/bin/perl -w
# This file was preprocessed, do not edit!


package Debconf::FrontEnd::Kde;
use strict;
use utf8;
use Debconf::Gettext;
use Debconf::Config;
BEGIN {
	eval { require QtCore4 };
	die "Unable to load QtCore -- is libqtcore4-perl installed?\n" if $@;
	eval { require QtGui4 };
	die "Unable to load QtGui -- is libqtgui4-perl installed?\n" if $@;
}
use Debconf::FrontEnd::Kde::Wizard;
use Debconf::Log ':all';
use base qw{Debconf::FrontEnd};
use Debconf::Encoding qw(to_Unicode);



our @ARGV_KDE=();

sub init {
	my $this=shift;
    
	$this->SUPER::init(@_);
	$this->interactive(1);
	$this->cancelled(0);
	$this->createdelements([]);
	$this->dupelements([]);
	$this->capb('backup');
	$this->need_tty(0);

	if (fork) {
		wait(); # for child
		if ($? != 0) {
			die "DISPLAY problem?\n";
		}
	}
	else {
		$this->qtapp(Qt::Application(\@ARGV_KDE));
		exit(0); # success
	}
	
	$this->window_initted(0);
	$this->kde_initted(0);
}

sub init_kde {
	my $this=shift;

	return if $this->kde_initted;

	debug frontend => "QTF: initializing app";
	$this->qtapp(Qt::Application(\@ARGV_KDE));
	$this->kde_initted(1);
}

sub init_window {
	my $this=shift;
	$this->init_kde();
	return if $this->window_initted;
	$this->{vbox} = Qt::VBoxLayout;

	debug frontend => "QTF: initializing wizard";
	$this->win(Debconf::FrontEnd::Kde::Wizard(undef,undef, $this));
	debug frontend => "QTF: setting size";
	$this->win->resize(620, 430);
	my $hostname = `hostname`;
	chomp $hostname;
	$this->hostname($hostname);
	debug frontend => "QTF: setting title";
	$this->win->setTitle(to_Unicode(sprintf(gettext("Debconf on %s"), $this->hostname)));
	debug frontend => "QTF: initializing main widget";
	$this->{toplayout} = Qt::HBoxLayout();
	$this->win->setMainFrameLayout($this->toplayout);
	$this->win->setTitle(to_Unicode(sprintf(gettext("Debconf on %s"), $this->hostname)));
	$this->window_initted(1);
}


sub go {
	my $this=shift;
	my @elements=@{$this->elements};
	

	$this->init_window;


	my $interactive='';
	debug frontend => "QTF: -- START ------------------";
	foreach my $element (@elements) {
		next unless $element->can("create");
		
		$element->create($this->frame);
		$interactive=1;
		debug frontend => "QTF: ADD: " . $element->question->description;
		$this->{vbox}->addWidget($element->top);
	}

	if ($interactive) {
		foreach my $element (@elements) {
			next unless $element->top;
			debug frontend => "QTF: SHOW: " . $element->question->description;
			$element->top->show;
		}
		my $scroll = Qt::ScrollArea($this->win);
		my $widget = Qt::Widget($scroll);
		$widget->setLayout($this->{vbox});
		$scroll->setWidget($widget);
		$this->toplayout->addWidget($scroll);
	
	
		if ($this->capb_backup) {
			$this->win->setBackEnabled(1);
		}
		else {
			$this->win->setBackEnabled(0);
		}
		$this->win->setNextEnabled(1);
	
		$this->win->show;
		debug frontend => "QTF: -- ENTER EVENTLOOP --------";
		$this->qtapp->exec;
		$this->qtapp->exit;
		debug frontend => "QTF: -- LEFT EVENTLOOP --------";
			
		$this->win->destroy();
		$this->window_initted(0);
		
		
	} else {
		foreach my $element (@elements) {
			$element->show;
		}
	}

	debug frontend => "QTF: -- END --------------------";
	if ($this->cancelled) {
		exit 1;
	}
	return '' if $this->goback;
	return 1;
}

sub progress_start {
	my $this=shift;
	$this->init_window;
	$this->SUPER::progress_start(@_);

	my $element=$this->progress_bar;
	$this->{vbox}->addWidget($element->top);
	$element->top->show;
	my $scroll = Qt::ScrollArea($this->win);
	my $widget = Qt::Widget($scroll);
	$widget->setLayout($this->{vbox});
	$scroll->setWidget($widget);
	$this->toplayout->addWidget($scroll);
	$this->win->setBackEnabled(0);
	$this->win->setNextEnabled(0);
	$this->win->show;
	$this->qtapp->processEvents;
}

sub progress_set {
	my $this=shift;
	my $ret=$this->SUPER::progress_set(@_);

	$this->qtapp->processEvents;

	return $ret;
}

sub progress_info {
	my $this=shift;
	my $ret=$this->SUPER::progress_info(@_);

	$this->qtapp->processEvents;

	return $ret;
}

sub progress_stop {
	my $this=shift;
	my $element=$this->progress_bar;
	$this->SUPER::progress_stop(@_);

	$this->qtapp->processEvents;

	$this->win->setAttribute(Qt::WA_DeleteOnClose());
	$this->win->close;
	$this->window_initted(0);

	if ($this->cancelled) {
		exit 1;
	}
}


sub shutdown {
	my $this = shift;
	if ($this->kde_initted) {
		if($this->win) {
			$this->win->destroy;
		}
	}
}


1
