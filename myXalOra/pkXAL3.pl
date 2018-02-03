#!/usr/bin/perl -w

use warnings;
use strict;
use XALAdapter;
#path to XALAdapter.pm - v:\sys\perl\XALAdapter.pm 

# only 1 function is allowed when call
my $myKeyword = $ARGV[0];
if ( $myKeyword !~ /-/ ) {    # a called function must begin with '-'
	print("missing function as parameter");
	exit;
}

my @params = ();
my $numberOfParams = $#ARGV;
# if more the 0 parameters then put them into @params array
if ( $numberOfParams < 0 ) {
	print("params not defined: $numberOfParams");
	exit;
}
else {
	for ( my $i = 1 ; $i <= $numberOfParams ; $i++ ) {
		$params[$i] = $ARGV[$i];			# write parameters into a tabel
	}
}

# run the function called in the csh-script
if ( $myKeyword eq "-getVareNummer" ) {
	my $valXAL = readXAL_getVareNummer( $params[1] );
	printf ( $valXAL );
}
elsif ( $myKeyword eq "-checkVareNummer" ) {
	my $valXAL = readXAL_checkVareNummer( $params[1] );
	printf ( $valXAL );
}
elsif ( $myKeyword eq "-readPrintKart" ) {
	my @valXAL = readXAL_getPrintKart( $params[1] );
	if ( $#valXAL <= 0 ) {
		exit;
	}
	for ( my $i = 0 ; $i <= $#valXAL ; $i++ ) {
		printf( "%s ", $valXAL[$i] );    		# values are divided by a space
	}
}
elsif ( $myKeyword eq "-prepare_GUIResp" ) {
	my @valXAL = prepare_GUIResp( $params[1] );		# the parameter can be the $ORDERNR or the $JOBNAME 
	if ( $#valXAL <= 0 ) {
		exit;
	}
	for ( my $i = 0 ; $i <= $#valXAL ; $i++ ) {
		printf( $valXAL[$i] . " " );    		# outputed values are divided by a space
	}
}
elsif ( $myKeyword eq "-prepare_GUIResp2" ) {
	my @valXAL = prepare_GUIResp2( $params[1] );		# the parameter can be the $ORDERNR or the $JOBNAME 
	if ( $#valXAL <= 0 ) {
		exit;
	}
	for ( my $i = 0 ; $i <= $#valXAL ; $i++ ) {
		printf( $valXAL[$i] . " " );    		# outputed values are divided by a space
	}
}
elsif ( $myKeyword eq "-xrayBeforeDrill" ) {
	my $valXAL = xrayBeforeDrill( $params[1] );		# the parameter is the $JOBNAME 
	printf ( $valXAL );
}

else {
	showMessageBox ('pkXAL3.pl', "The requested function cannot be found." );
	print("Error:_function_not_found.\n");
}

exit;

