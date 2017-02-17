#!/bin/env perl -w
use Cwd;

my $myString = "442x008-b1-701";
my $mySubstring1 = substr($myString, -4);
print($mySubstring1, "\n");		# -701

my $mySubstring2 = substr($myString, 0, -4);
print($mySubstring2, "\n");		# 442x008-b1 (odrzuca ostatnie 4 znaki)

$myString ="c:/Users/pkr.PRIDANA/git/mygit/myPerlProject/442x011-b-703";
print(substr($myString, 0, -4), ".\n");

# sprawdzic rozszerzenie


$myString2 =  $myString . "_out";
print($myString2);



#my $myCWD = cwd();
#print $myCWD;


my $myChoice = 1;

