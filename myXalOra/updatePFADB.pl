#!/usr/bin/perl -w

use DBI;
use strict;
require "readJobAnalyze.pl";

my $PFAdbase = 'xe';
my $PFAuser  = 'pfa';
my $PFApass  = 'pfa_passwd';

# mialo byc update a nie insert..
# function inserts a new row into table pfa_job
 
# zawsze po DELETE FROM pfa_job WHERE hal = 0;
# wywala ORA-03113: end-of-file on communication channel
# jak zamieszam w trigerze to rusza..
sub insertPFAjob {
	my ($args)            = @_;
	my $myVARENUMMER      = $args->{varenummer};
	my $myKUNDETEGNINGSNR = $args->{kundetegningsnr};
	my $myANTALLPPXPP     = $args->{antallppxpp};
	my $myANTALPRINTPXPP  = $args->{antalprintpxpp};
	my $myHAL             = $args->{hal};
	my $myBLYFRIHAL       = $args->{blyfrihal};
	my $myKEMSN           = $args->{kemsn};
	my $myKEMAG           = $args->{kemag};
	my $myKEMISKNIAU      = $args->{kemiskniau};

	# Connect to database
	my $dbhPFA =
	  DBI->connect( "dbi:Oracle:$PFAdbase", $PFAuser, $PFApass,
		{ AutoCommit => 1, RaiseError => 0, PrintError => 0 } )
	  or return $DBI::errstr;

	my $sql =
	    "INSERT INTO pfa_job VALUES ("
	  . "'$myVARENUMMER', '$myKUNDETEGNINGSNR', "
	  . "$myANTALLPPXPP, $myANTALPRINTPXPP, "
	  . "$myHAL, $myBLYFRIHAL, $myKEMSN, $myKEMAG, $myKEMISKNIAU, "
	  . "CURRENT_TIMESTAMP )";
	  
	my $sthPFA = $dbhPFA->prepare($sql, { ora_check_sql => 0 });

	$sthPFA->execute();
	my $rows = $sthPFA->rows;
	if ( $rows == 0 ) {
		print(DBI::errstr() . "\n");
	}

	$sthPFA->finish();
	$dbhPFA->disconnect() or return $DBI::errstr;

	return $rows;
}


sub updatePFAjob {
	my ($args)            = @_;

	# Connect to database
	my $dbhPFA =
	  DBI->connect( "dbi:Oracle:$PFAdbase", $PFAuser, $PFApass,
		{ AutoCommit => 1, RaiseError => 0, PrintError => 0 } )
	  or return $DBI::errstr;
	  
	  my $sql = "UPDATE pfa_job SET " 
	  . "KUNDETEGNINGSNR = $args->{kundetegningsnr}, "
	  . "ANTALLPPXPP = $args->{antallppxpp}, ANTALPRINTPXPP = $args->{antalprintpxpp}, "
	  . "HAL = $args->{hal}, BLYFRIHAL = $args->{blyfrihal}, KEMSN = $args->{kemsn}, " 
	  . "KEMAG = $args->{kemag}, KEMISKNIAU = $args->{kemiskniau}, "
	  . "DONEAT = CURRENT_TIMESTAMP "
	  . "WHERE VARENUMMER = '$args->{varenummer}'";
	  
	my $sthPFA = $dbhPFA->prepare($sql, { ora_check_sql => 0 });

	$sthPFA->execute();
	my $rows = $sthPFA->rows;
	if ( $rows == 0 ) {
		print(DBI::errstr() . "\n");
	}

	$sthPFA->finish();
	$dbhPFA->disconnect() or return $DBI::errstr;

	return $rows;
}

sub updatePFAjob2 {
	my ($args)            = @_;
	my $myVARENUMMER      = $args->{varenummer};
	my $myKUNDETEGNINGSNR = $args->{kundetegningsnr};
	my $myANTALLPPXPP     = $args->{antallppxpp};
	my $myANTALPRINTPXPP  = $args->{antalprintpxpp};
	my $myHAL             = $args->{hal};
	my $myBLYFRIHAL       = $args->{blyfrihal};
	my $myKEMSN           = $args->{kemsn};
	my $myKEMAG           = $args->{kemag};
	my $myKEMISKNIAU      = $args->{kemiskniau};

	# Connect to database
	my $dbhPFA =
	  DBI->connect( "dbi:Oracle:$PFAdbase", $PFAuser, $PFApass,
		{ AutoCommit => 1, RaiseError => 0, PrintError => 0 } )
	  or return $DBI::errstr;
	  
	  my $sql = "UPDATE pfa_job SET " 
	  . "KUNDETEGNINGSNR = $myKUNDETEGNINGSNR, "
	  . "ANTALLPPXPP = $myANTALLPPXPP, ANTALPRINTPXPP = $myANTALPRINTPXPP, "
	  . "HAL = $myHAL, BLYFRIHAL = $myBLYFRIHAL, KEMSN = $myKEMSN, " 
	  . "KEMAG = $myKEMAG, KEMISKNIAU = $myKEMISKNIAU, "
	  . "DONEAT = CURRENT_TIMESTAMP "
	  . "WHERE VARENUMMER = '$myVARENUMMER'";
	  
	my $sthPFA = $dbhPFA->prepare($sql, { ora_check_sql => 0 });

	$sthPFA->execute();
	my $rows = $sthPFA->rows;
	if ( $rows == 0 ) {
		print(DBI::errstr() . "\n");
	}

	$sthPFA->finish();
	$dbhPFA->disconnect() or return $DBI::errstr;

	return $rows;
}


#function inserts a new row into table pfa_layer
# varenummer must exist in pfa_job before inserting into pfa_layer
sub insertPFAlayer {

	my $myVARENUMMER  = shift;
	my %myLayerParams = getLayerParams($myVARENUMMER);

	$myVARENUMMER =~ s/\.//g;    # removes a dot from varenummer

	my @myKeySize = keys %myLayerParams;
	if ( $#myKeySize == 0 ) {
		exit;                    # exit if nothing returned
	}

	# Connect to database
	my $dbhPFA =
	  DBI->connect( "dbi:Oracle:$PFAdbase", $PFAuser, $PFApass,
		{ AutoCommit => 1, RaiseError => 0, PrintError => 1 } )
	  or return $DBI::errstr;

	my $sthPFA      = "";
	my $myLAYERNAME = "";
	my $myLAYERTYPE = "";
	my $myLINES     = "";
	my $mySPACE     = "";
	my $myVIA2CU    = "";
	my $myANNRING   = "";
	my $myCUPERCENT = "";

	for ( my $i = 0 ; $i <= $#myKeySize ; $i++ ) {
		my @keyArr = @{ $myLayerParams{ $myKeySize[$i] } };
		for ( my $i = 0 ; $i <= $#keyArr ; $i++ ) {

			#print "$keyArr[$i] ";
			$myLAYERNAME = $keyArr[0];
			$myLAYERTYPE = $keyArr[1];
			$myLINES     = $keyArr[2];
			$mySPACE     = $keyArr[3];
			$myVIA2CU    = $keyArr[4];
			$myANNRING   = $keyArr[5];
			$myCUPERCENT = $keyArr[6];
		}

		print ("$myVARENUMMER $myLAYERNAME $myLAYERTYPE ");
		print ("$myLINES $mySPACE $myVIA2CU $myANNRING $myCUPERCENT \n");

		# prepare and execute SQL-statement
		$sthPFA =
		  $dbhPFA->prepare( "INSERT INTO pfa_layer VALUES ("
			  . "'$myVARENUMMER', '$myLAYERNAME', '$myLAYERTYPE', "
			  . "$myLINES, $mySPACE, $myVIA2CU, $myANNRING, $myCUPERCENT, "
			  . "CURRENT_TIMESTAMP)" );

		$sthPFA->execute();
	}

	$sthPFA->finish();
	$dbhPFA->disconnect();

	return "\nend of updatePFAlayer()\n";

	#display only the top layer:
	my @top = @{ $myLayerParams{'top'} };

	#	for ( my $i = 0 ; $i <= $#top ; $i++ ) {
	#		print "$top[$i] ";
	#	}

	#print("\n");

	#display only bottom layer:
	#	my @bottom = @{ $myLayerParams{'bottom'} };
	#	for ( my $i = 0 ; $i <= $#bottom ; $i++ ) {
	#		print "$bottom[$i] ";
	#	}

	#	# Connect to database
	#	my $dbhPFA =
	#	  DBI->connect( "dbi:Oracle:$PFAdbase", $PFAuser, $PFApass,
	#		{ AutoCommit => 1, RaiseError => 0, PrintError => 0 } )
	#	  or return $DBI::errstr;
	#
	#	# prepare and execute SQL-statement
	#	my $sthPFA = $dbhPFA->prepare(
	#		qq(
	#		INSERT INTO pfa_layer VALUES (
	#    	'$myVARENUMMER', '$myLAYERNAME', '$myLAYERTYPE',
	#    	$myLINES, $mySPACE, $myVIA2CU, $myANNRING, $myCUPERCENT,
	#      	CURRENT_TIMESTAMP))
	#	);
	#
	#	$sthPFA->execute() or return $DBI::errstr;
	#
	#	$sthPFA->finish();
	#	$dbhPFA->disconnect();
	#	return "";
}

return 1;

######################
# display all hash table:
#	foreach my $k ( keys %myLayerParams ) {
#		foreach ( @{ $myLayerParams{$k} } ) {
#
#			#		print ": $_";
#		}
#
#		#	print "\n";
#	}

#	if (
#		(
#			   $myHAL == 0
#			&& $myBLYFRIHAL == 0
#			&& $myKEMSN == 0
#			&& $myKEMAG == 0
#			&& $myKEMISKNIAU == 0
#		)
#		|| (   $myHAL < 0
#			|| $myBLYFRIHAL < 0
#			|| $myKEMSN < 0
#			|| $myKEMAG < 0
#			|| $myKEMISKNIAU < 0 )
#		|| ( $myHAL + $myBLYFRIHAL + $myKEMSN + $myKEMAG + $myKEMISKNIAU != 1 )
#	  )
#	{
#		return "Only one surface allowed.";
#	}