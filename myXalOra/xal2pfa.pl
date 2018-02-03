#!/usr/bin/perl -w

# https://www.tutorialspoint.com/perl/perl_qq.htm
use Tk;
#use UI::Dialog;
use DBI;
use strict;
require Tk::Dialog;

require "readXALDB.pl";
require "updatePFADB.pl";

############# begin of program ##############
print( "Step 1. Read from XAL_DB.", "\n" );

#my @valXAL = readXALDB('292X05141717');
#my @valXAL = readXALDB('292X05161723');
#my @valXAL = readXALDB('292X05151723');
#my @valXAL = readXALDB('292X05111715');
#my @valXAL = readXALDB('292X05101715');
#my @valXAL = readXALDB('292X05131717');
my @valXAL = readXALDB('292X05121716');
#my @valXAL = readXALDB('292X05181724');

if ( $#valXAL < 0 ) {
	print("Result is empty\n");
	exit;
}
print "$#valXAL columns has been read.\n";

# najpierw update, a jak sie nie powiedzie to insert
# sie trza zastanowic..

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
if ( $result == 0 ) {
	print("Message box: Yes/No -- The row exists. Update it?\n");
	my $myQuestion = 1;    # 0: exit or 1: update
	if ( $myQuestion == 0 ) {
		exit;
	}
}

my $mw     = new MainWindow;
$mw-> withdraw();
my $answer = $mw->Dialog(
	-title          => 'Update row',
	-text           => 'The row exists. Update it?',
	-default_button => 'Yes',
	-buttons        => [ 'Yes', 'No' ],
	-bitmap         => 'question'
)->Show();
if ( $answer eq 'No' ) {
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
exit;

print( "Step 3. Insert table pfa_layer.", "\n" );
my $rs = insertPFAlayer( $valXAL[4] );
print $rs;

print( "Step 4. Update table pfa_pcb.", "\n" );

#my $result = updatePFApcb(
#	{
#		varenummer => $valXAL[4],
#		kundetegningsnr => $valXAL[5],
#		antallppxpp => $valXAL[27],
#		antalprintpxpp => $valXAL[28],
#		hal => $valXAL[71],
#		blyfrihal => $valXAL[143],
#		kemsn => $valXAL[144],
#		kemag => $valXAL[145],
#		kemiskniau => $valXAL[82]
#	}
#);
#
#if ($result ne "") {
#	print $result;
#}

########################

#print( "Step 2. Update table pfa_job.", "\n" );
#
#
#print( "Step 3. Read from PFA_DB:", "\n" );
#my $refPFA = readPFADB('442X00171706');

#foreach my $namePFA ( keys %$refPFA ) {
#
#	# print( "$name\t$ref->{$name}", "\n" );
#	if (   ( $namePFA eq 'VARENUMMER' )
#		|| ( $namePFA eq 'KUNDETEGNINGSNR' )
#		|| ( $namePFA eq 'ANTALLPPXPP' )
#		|| ( $namePFA eq 'ANTALPRINTPXPP' )
#		|| ( $namePFA eq 'HAL' )
#		|| ( $namePFA eq 'KEMISKNIAU' ) )
#	{
#		#print( "$namePFA\t$refPFA->{$namePFA}", "\n" );
#	}
#}

print("\n\nend of program.. \n");

################## end of program ################

########################## smietnisko #########################
#sub readXALDB {
#	my $XALVareNummer = shift;
#	print("readXALDB(): $XALVareNummer \n");
#
#	my $XALdbase = 'pridana.xalora';
#	my $XALuser  = 'pkr';
#	my $XALpass  = 'pkramarz';
#
#	# my $XALVareNummer = '114X00271722';
#
#	# Connect to database
#	my $dbhXAL =
#	  DBI->connect( "dbi:Oracle:$XALdbase", $XALuser, $XALpass,
#		{ AutoCommit => 1, RaiseError => 1, PrintError => 0 } )
#	  or die $DBI::errstr;
#
#	# prepare and execute SQL-statement
#	my $sth = $dbhXAL->prepare(
#		qq(
#	SELECT * FROM xal_supervisor.dd_printkart WHERE varenummer = '$XALVareNummer'
#	)
#	);
#	$sth->execute();
#	# or die $DBI::errstr;
#
#
#	#print( "NUM_OF_FIELDS: ", $sth->{NUM_OF_FIELDS}, "\n" );
#
#	#my $ref = $sth->fetchrow_hashref;
##	my $ref;
##	while ( $ref = $sth->fetchrow_hashref ) {
##		print( keys %$ref );
##		print join( ", ", values %$ref ), "\n";
##	}
#
#	my @ref = $sth->fetchrow_array;
#	print( "columns: $#ref \n" );
#
#	$sth->finish();
#	$dbhXAL->disconnect;
#
#	return @ref;
#}

#sub writePFADB {
#
#	my ($args) = @_;
#	my $myVal1 = $args->{val1};
#	my $myVal2 = $args->{val2};
#	my $myVal3 = $args->{val3};
#	my $myVal4 = $args->{val4};
#	my $myVal5 = $args->{val5};
#
#	 printf("mySub1(): $myVal1 $myVal2 $myVal3 $myVal4 $myVal5 \n");
#
#	my $varenummer_local = shift;
#	print("writePFADB(): $varenummer_local \n");
#
#
#	my $myStr = qq(INSERT INTO pfa_job VALUES (
#      $varenummer_local, $myKUNDETEGNINGSNR,
#      '$myANTALLPPXPP', '$myANTALPRINTPXPP',
#      0, 0, 0, 1, 0, CURRENT_TIMESTAMP)
#      );
#	printf $myStr;
#
#	my $PFAdbase      = 'pridana.xe';
#	my $PFAuser       = 'pfa';
#	my $PFApass       = 'pfa_passwd';
#	my $PFAVareNummer = '442X00171706';
#
#	# Connect to database
#	my $dbhPFA =
#	  DBI->connect( "dbi:Oracle:$PFAdbase", $PFAuser, $PFApass,
#		{ AutoCommit => 1, RaiseError => 1, PrintError => 0 } )
#	  or die $DBI::errstr;
#
#	# prepare and execute SQL-statement
#	my $sthPFA = $dbhPFA->prepare(
#		qq(
#      INSERT INTO pfa_job VALUES (
#      '$myVARENUMMER', '$myKUNDETEGNINGSNR',
#      '$myANTALLPPXPP', '$myANTALPRINTPXPP',
#      0, 0, 0, 1, 0, CURRENT_TIMESTAMP)
#      )
#	);
#
#	$sthPFA->execute();
#	print $DBI::err;
#	print( $sthPFA->{NUM_OF_FIELDS}, "\n" );
#
#	my $ref = $sthPFA->fetchrow_hashref;
#
#	$sthPFA->finish();
#	$dbhPFA->disconnect();
#
#	return $ref;
#}

#my @wartosci2  = values $valXAL;
#print( $wartosci2 {'KUNDETEGNINGSNR'}, "\n" );

#foreach my $name ( keys %$valXAL ) {
#
#	# print( "$name\t$valXAL->{$name}", "\n" );
#	if ( $name eq 'KUNDETEGNINGSNR' ) {
#		my $myKUNDETEGNINGSNR = $valXAL->{$name};
#		printf( "1a: ", $myKUNDETEGNINGSNR, "\n" );
#	}
#	elsif ( $name eq 'VARENUMMER' ) {
#		my $myVARENUMMER = $valXAL->{$name};
#		printf( "2a: ", $myVARENUMMER, "\n" );
#	}
#	elsif ( $name eq 'ANTALLPPXPP' ) {
#		my $myANTALLPPXPP = $valXAL->{$name};
#	}
#	elsif ( $name eq 'ANTALPRINTPXPP' ) {
#		my $myANTALPRINTPXPP = $valXAL->{$name};
#	}
#	elsif ( $name eq 'SIDSTRETTET' ) {
#		my $mySIDSTRETTET = $valXAL->{$name};
#	}
#	elsif ( $name eq 'TEKGODORIG' ) {
#		my $myTEKGODORIG = $valXAL->{$name};
#	}
#	else {
#		print( "jeszcze cus innego..", "\n" );
#
#		#print( "$name\t$ref->{$name}", "\n" );
#	}
#}

#writePFADB('VARENUMMER');
#writePFADB(
#	{
#		val1 => $layerAtt[0][0],
#		val2 => $layerAtt[0][1],
#		val3 => $layerAtt[0][2],
#		val4 => $layerAtt[0][3],
#		val5 => $layerAtt[0][4]
#	}
#);

#my @data_sources;
#my @driver_names = DBI->available_drivers;
#for ( my $i = 0 ; $i < $#driver_names ; $i++ ) {
#
#	# print( $driver_names[$i], "\n" );
#}

#print( "VARENUMMER: $valXAL[4] \n" );
#print( "KUNDETEGNINGSNR: $valXAL[5] \n" );
#print( "SENESTEREVISION: $valXAL[9] \n" );
#print( "antallppxpp: $valXAL[27] \n" );
#print( "antalprintpxpp: $valXAL[28] \n" );
#print( "hal: $valXAL[71] \n" );
#print( "blyfrihal: $valXAL[143] \n" );
#print( "kemsn: $valXAL[144] \n" );
#print( "kemag: $valXAL[145] \n" );
#print( "kemiskniau: $valXAL[82] \n" );

#sub readPFADB {
#	my $PFAVareNummer = shift;
#	print("readPFADB(): $PFAVareNummer \n");
#
#	my $PFAdbase = 'pridana.xe';
#	my $PFAuser  = 'pfa';
#	my $PFApass  = 'pfa_passwd';
#
#	# Connect to database
#	my $dbhPFA =
#	  DBI->connect( "dbi:Oracle:$PFAdbase", $PFAuser, $PFApass,
#		{ AutoCommit => 1, RaiseError => 1, PrintError => 0 } )
#	  or die $DBI::errstr;
#
#	# prepare and execute SQL-statement
#	my $sthPFA = $dbhPFA->prepare(
#		qq(SELECT * FROM pfa_job WHERE varenummer = '$PFAVareNummer'));
#	$sthPFA->execute();
#
#	#print $DBI::err;
#	#print( $sthPFA->{NUM_OF_FIELDS}, "\n" );
#
#	my $ref = $sthPFA->fetchrow_hashref;
#
#	$sthPFA->finish();
#	$dbhPFA->disconnect();
#
#	return $ref;
#}
