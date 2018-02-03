
#!c:/Perl/bin/perl 

use Win32::OLE;
use Win32::OLE::Variant;

use strict;

# 032X0013.1013.1.mdb 
# 098x0145.1712_1-4.1.mdb 
# 098x0145.1712_5-8.1.mdb 

my $myShortJobNumber = "032x0013";
my $myMDBFile = "032X0013.1013.1.mdb";

if ($myMDBFile =~ /$myShortJobNumber/i) {
	print ("sie zawiera. \n");
}

my $myPRGFile = substr( $myMDBFile, 0, 13 );
print ($myPRGFile  . "\n");

$myPRGFile =~ s/X/x/;
print ($myPRGFile  . "\n");


print ("Koniec. \n");

#	if ( $mySubMDBFile ne $myShortJobNumber ) {
##			delete $liste[$i];    # delete does not shift array
##		}
#		
#		if ( $mySubMDBFile !~ m/$myShortJobNumber/ ) {
#			delete $liste[$i];    # delete does not shift array
#		}
#		
#if ( $shares !~ m/inspecta/ ) {
#	
	
	
#################################

my $line;

#while (<>) {
#	print $_;    # or simply "print;"
#}

#my $buf;
#while ( sysread( STDIN, $buf, 1 ) ) {
#	if ( $buf =~ /\n|\r|\r\n/o ) {
#		print "$line\n";
#		$line = "";
#		last;
#	}
#	else {
#		$line .= $buf;
#		print ("els\n");
#	}
#}


my $myPerlFile = $0;
print $myPerlFile . "\n";

# split the perl filename by slash (shift + 7)	
my @myArrSplittedLine = split /[\/]/, $0;    
$myPerlFile = $myArrSplittedLine[$#myArrSplittedLine];
print ($myPerlFile . "\n"); 

print "\n\nkuniec2 \n";
exit(0);
	