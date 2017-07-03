#!/usr/bin/perl -w
# This file was preprocessed, do not edit!


package Debconf::Element::Dialog::Select;
use strict;
use base qw(Debconf::Element::Select);
use Debconf::Encoding qw(width);


sub show {
	my $this=shift;

	my ($text, $lines, $columns)=
		$this->frontend->makeprompt($this->question, -2);

	my $screen_lines=$this->frontend->screenheight - $this->frontend->spacer;
	my $default=$this->translate_default;
	my @params=();
	my @choices=$this->question->choices_split;
	
	my $menu_height=$#choices + 1;
	if ($lines + $#choices + 2 >= $screen_lines) {
		$menu_height = $screen_lines - $lines - 4;
	}
	
	$lines=$lines + $menu_height + $this->frontend->spacer;
	my $c=1;
	my $selectspacer = $this->frontend->selectspacer;
	foreach (@choices) {
		push @params, $_, '';
		
		if ($columns < width($_) + $selectspacer) {
			$columns = width($_) + $selectspacer;
		}
	}
	
	if ($this->frontend->dashsep) {
		unshift @params, $this->frontend->dashsep;
	}
	
	@params=('--default-item', $default, '--menu', 
		  $text, $lines, $columns, $menu_height, @params);

	my $value=$this->frontend->showdialog($this->question, @params);
	if (defined $value) {
		$this->value($this->translate_to_C($value)) if defined $value;
	}
	else {
		my $default='';
		$default=$this->question->value
			if defined $this->question->value;
		$this->value($default);
	}
}

1
