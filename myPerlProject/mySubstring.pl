#!/bin/env perl -w
use Cwd;

my $myString = "442x008-b1-701";
my $mySubstring1 = substr($myString, -4);
print($mySubstring1, "\n");		# -701

my $mySubstring2 = substr($myString, 0, -4);
print($mySubstring2, "\n");		# 442x008-b1 (odrzuca ostatnie 4 znaki)

my $myCWD = cwd();
print $myCWD;


my $myChoice = 1;

SWITCH: {
	$myChoice 
	
	
}
