#!/usr/bin/perl -w
use Tk;
use DBI;
use strict;
require Tk::Dialog;

require "readXALDB.pl";
require "updateDB.pl";

############# begin of program ##############
print( "Step 1. Read from XAL_DB.", "\n" );

#my @valXAL = readXALDB('292X05141717');
my @valXAL = readXALDB('292X05161723');
#my @valXAL = readXALDB('292X05151723');
#my @valXAL = readXALDB('292X05111715');
#my @valXAL = readXALDB('292X05101715');
#my @valXAL = readXALDB('292X05131717');
#my @valXAL = readXALDB('292X05121716');
#my @valXAL = readXALDB('292X05181724');

if ( $#valXAL <= 0 ) {
	print("Result is empty\n");
	exit;
}
print "$#valXAL columns has been read.\n";

print( "Step 2a. Insert table pfa_job.", "\n" );
my $result = insertPFAjob(
	{
		varenummer      => $valXAL[4],
		kundetegningsnr => $valXAL[5],
		antallppxpp     => $valXAL[27],
		antalprintpxpp  => $valXAL[28],
		hal             => $valXAL[71],
		blyfrihal       => $valXAL[143],
		kemsn           => $valXAL[144],
		kemag           => $valXAL[145],
		kemiskniau      => $valXAL[82]
	}
);
printf("Inserted rows: $result\n");
if ( $result > 0 ) {
	print("End of program.");
	exit;
}

# message box:
my $mw = new MainWindow;
$mw->withdraw();
my $answer = $mw->Dialog(
	-title          => 'Update row',
	-text           => 'The row exists. Update it?',
	-default_button => 'Yes',
	-buttons        => [ 'Yes', 'No' ],
	-bitmap         => 'question'
)->Show();
if ( $answer eq 'No' ) {
	print("End of program.");
	exit;
}

print( "Step 2b. Update table pfa_job.", "\n" );
$result = updatePFAjob(
	{
		varenummer      => $valXAL[4],
		kundetegningsnr => $valXAL[5],
		antallppxpp     => $valXAL[27],
		antalprintpxpp  => $valXAL[28],
		hal             => $valXAL[71],
		blyfrihal       => $valXAL[143],
		kemsn           => $valXAL[144],
		kemag           => $valXAL[145],
		kemiskniau      => $valXAL[82]
	}
);
printf("Updated rows: $result\n");
print("End of program.");
exit;
