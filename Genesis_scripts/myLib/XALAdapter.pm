#!/usr/bin/perl -w

# errors should be returned as ORA-xxxxx instead of description
# because spaces in returned strings destroy arrays
# a new function added for testing purposes: prepare_GUIResp2
# the function prepare_GUIResp() gives two values in return for galvanic gold (No-Both)
# thickness of pcb taken now from field #15 RXPLADETYKKELSE 

use warnings;
use strict;

use Tk;
use DBI;
require Tk::Dialog;

my $XALsid  = 'xalora';
my $XALhost = 'oracledb.pridana.local';
my $XALport = 1521;
my $XALuser = 'pkr';
my $XALpass = 'pkramarz';
my $connXAL = "dbi:Oracle:HOST = $XALhost; SID = $XALsid; port = $XALport";

my $XALOrderNr;    # global
my $myFilename = 'v:/sys/dokumenter/kundeliste.txt';

#message box (https://www.tutorialspoint.com/ruby/ruby_tk_messagebox.htm)
#http://perl.mines-albi.fr/perl5.8.5/site_perl/5.8.5/sun4-solaris/Tk/Dialog.html

sub showMessageBox {
	my $myTitle = shift;
	my $myText  = shift;
	my $mw      = new MainWindow;
	$mw->withdraw();

	my $reponse_messageBox = $mw->messageBox(
		-title   => $myTitle,
		-message => $myText,
		-type    => 'Ok',
		-icon    => 'info'
	);
}

# function returns a name of customer by its 3-digits-number;
# if nothing found then the value will be a 'not_found' string
sub getPFACustomer {
	my $myFilename   = shift;
	my $myCustNumber = shift;

	my $mySubCustNumber = substr( $myCustNumber, 0, 3 );

	#showMessageBox('getPFACustomer()', $mySubCustNumber);

	open( my $myINPUTFILE, "$myFilename" ) or return 'IO_error';
	my @data = <$myINPUTFILE>;
	close $myINPUTFILE;

	# create a hash table from the txt file
	my %pridanaCust;
	my @myKeyValue, my $myKey, my $myValue, my $myLine;
	foreach $myLine (@data) {
		$myKey = $myLine;
		$myKey =~ s/[^.{0-9}]//g;    # extract leading digits
		$myValue = $myLine;
		$myValue =~ s/([0-9]_*)//g;    # remove leading digits
		$pridanaCust{$myKey} = $myValue;
	}

	my @custKeys   = keys %pridanaCust;
	my @custValues = values %pridanaCust;
	$myValue = 'not_found';
	my $i;
	for ( $i = 0 ; $i <= $#custKeys ; $i++ ) {
		if ( $mySubCustNumber =~ m/$custKeys[$i]/ ) {
			$myValue = $custValues[$i];

			# showMessageBox('getPFACustomer()', $myValue);
			return $myValue;
		}
	}

	#showMessageBox('getPFACustomer()', $myValue);
	return $myValue;
}

# internal function called from readXAL_getRaapladeName()
# the parameter is a string as varenavn from lagerkart
# if material not found then the result is empty
sub getMaterialName {

	my $myType = shift;

	#showMessageBox( "1. prepare_GUIResp()", $myType );

	# definition of a hash-table of material (the key must be unique)
	my %XALmaterial = (
		'AT01'      => 'FR4',
		'AT97'      => 'FR4',
		'PI2'       => 'FR4',
		'FR4'       => 'FR4',
		'IS410'     => 'HighTG',
		'IS420'     => 'HighTG',
		'PCL370'    => 'HighTG',
		'PCL 370'   => 'HighTG',
		'4450'      => 'Rogers',
		'Rogers'    => 'Rogers',
		'DE104'     => '104i',
		'Arlon85N'  => '85n',
		'Arlon85NT' => '85nt',
		'IS400'     => 'IS400',
		'PTFE'      => 'Teflon',
		'Teflon'    => 'Teflon'
	);

	my @myKeys   = keys %XALmaterial;
	my @myValues = values %XALmaterial;

	my $i;
	my $myMaterialName = '';

   # find the name for the used material, when not found then name will be a FR4
	for ( $i = 0 ; $i <= $#myKeys ; $i++ ) {
		if ( $myType =~ m/$myKeys[$i]/ ) {
			$myMaterialName = $myValues[$i];
		}
	}

	#showMessageBox( "getMaterialName()", $myMaterialName );
	return $myMaterialName;
}

# returns index number for kind of core-material used for specified build-up
# the parameter is the buildup number
sub readXAL_getRaapladeName {

	my $myBuildUp = shift;

	my $dbhXAL = DBI->connect(
		$connXAL, $XALuser, $XALpass,
		{
			AutoCommit => 1,    # 0 = false
			RaiseError => 0,
			PrintError => 1
		}
	);
	if ( !$dbhXAL ) {
		showMessageBox( 'readXAL_getRaapladeName()', $DBI::errstr );
		return '';
	}

	my $sth;

	# check for double-sided board: myBuildUp starts with 'P'
	if ( $myBuildUp =~ /^[P]/ ) {
		$sth = $dbhXAL->prepare(
			qq(
			SELECT varenummer, varenavn FROM XAL_SUPERVISOR.LAGERKART
				WHERE VARENUMMER = '$myBuildUp'
		)
		);
	}
	else {
		$sth = $dbhXAL->prepare(
			qq(
			SELECT DISTINCT lk.varenummer, lk.varenavn 
				FROM XAL_SUPERVISOR.LAGERKART lk, XAL_SUPERVISOR.DD_RXPLADEVALG rpv
  				WHERE rpv.printtype = '$myBuildUp'
  				AND lk.VARENUMMER = rpv.RXPLADE
  				AND SUBSTR(lk.varenummer, 1, 2) IN ('PI')
		)
		);
	}

	$sth->execute() or return $DBI::errstr;
	my @ref = $sth->fetchrow_array;

	$sth->finish();
	$dbhXAL->disconnect;

	my $lk_varenummer = $ref[0];
	my $lk_varenavn   = $ref[1];

	# get type of material by its varenummer
	my $myMatName = getMaterialName($lk_varenummer);
	if ( $myMatName ne '' ) {
		return $myMatName;
	}

	# if previous not found then get type of material by its varenavn
	$myMatName = getMaterialName($lk_varenavn);
	if ( $myMatName ne '' ) {
		return $myMatName;
	}
	else {
		# if nothing found then return a standard name
		return 'FR4';
	}

	# moze ten material nalezaloby sprawdzac wg nazwy i wedlug numeru.
	# gdy oba zgodne to ok a jak nie to standdard FR4
}

sub readXAL_getThickness {

	my $myPrintType = shift;

	my $dbhXAL = DBI->connect(
		$connXAL, $XALuser, $XALpass,
		{
			AutoCommit => 1,    # 0 = false
			RaiseError => 0,
			PrintError => 1
		}
	);
	if ( !$dbhXAL ) {
		showMessageBox( 'readXAL_getThickness()', $DBI::errstr );
		return 0;
	}

	my $sth = $dbhXAL->prepare(
		qq(
			SELECT SUM (COUNT) 
				FROM (SELECT PladeTykkelse AS COUNT FROM 
					xal_supervisor.DD_RXPLADEVALG WHERE printtype = '$myPrintType')
		)
	);
	$sth->execute() or return $DBI::errstr;
	my @ref = $sth->fetchrow_array;

	$sth->finish();
	$dbhXAL->disconnect;

	return $ref[0];
}

sub readXAL_getKundeByVareNr {

	my $XALVareNummer = shift;
	if ( $XALVareNummer =~ /\./ ) {
		$XALVareNummer =~ s/\.//g;  # removes a dot from varenummer if necessary
	}
	$XALVareNummer =~ s/x/X/g;      # replaces 'x' with 'X'
	    #showMessageBox( "readXAL_getKundeByVareNr()", $XALVareNummer );

	my $dbhXAL = DBI->connect(
		$connXAL, $XALuser, $XALpass,
		{
			AutoCommit => 1,    # 0 = false
			RaiseError => 0,
			PrintError => 1
		}
	);
	if ( !$dbhXAL ) {
		showMessageBox( 'readXAL_getKundeByVareNr()', $DBI::errstr );
		return 'not_found';
	}

	my $sth = $dbhXAL->prepare(
		qq(
		SELECT DISTINCT ordrenavn FROM xal_supervisor.ordrekart ok
			WHERE ok.ordrenummer IN 
			(SELECT ordrenummer FROM xal_supervisor.ordrepost WHERE varenummer = '$XALVareNummer')
		)
	);

	$sth->execute() or return $DBI::errstr;
	my @ref = $sth->fetchrow_array;

	$sth->finish();
	$dbhXAL->disconnect;

	# if length is -1 then nothing found
	if ( $#ref < 0 ) {
		$ref[0] = 'not_found';
	}
	return $ref[0];
}

# the function returns the name of customer from the DB by the order number
sub readXAL_getKundeByOrderNr {

	$XALOrderNr = shift;
	my $dbhXAL = DBI->connect(
		$connXAL, $XALuser, $XALpass,
		{
			AutoCommit => 1,    # 0 = false
			RaiseError => 0,
			PrintError => 1
		}
	);
	if ( !$dbhXAL ) {
		showMessageBox( 'readXAL_getKundeByOrderNr()', $DBI::errstr );
		return 'kucha';
	}

	my $sth = $dbhXAL->prepare(
		qq(
			SELECT ordrenavn FROM xal_supervisor.ordrekart WHERE ordrenummer = $XALOrderNr
		)
	);
	$sth->execute() or return $DBI::errstr;
	my @ref = $sth->fetchrow_array;

	$sth->finish();
	$dbhXAL->disconnect;

	return $ref[0];
}

# function returns 0 if varenummer does not exist in XALDB; otherwise is returns 1
# however if the user wants to create a job anyway, then it returns also 1 (see the dialog box)
sub readXAL_checkVareNummer {

	my $XALVareNummer = shift;

	if ( $XALVareNummer =~ /\./ ) {
		$XALVareNummer =~ s/\.//g;  # removes a dot from varenummer if necessary
	}
	$XALVareNummer =~ s/x/X/g;      # replaces 'x' with 'X'

	my $dbhXAL = DBI->connect(
		$connXAL, $XALuser, $XALpass,
		{
			AutoCommit => 1,        # 0 = false
			RaiseError => 0,
			PrintError => 1
		}
	);
	if ( !$dbhXAL ) {
		showMessageBox( 'readXAL_checkVareNummer()', $DBI::errstr );
		return 'kucha';
	}

	# $XALVareNummer have to be without a dot!
	my $sth = $dbhXAL->prepare(
		qq(
			SELECT Count(*) from XAL_SUPERVISOR.DD_printkart WHERE varenummer = '$XALVareNummer'
		)
	);
	$sth->execute() or return $DBI::errstr;
	my @ref = $sth->fetchrow_array;

	$sth->finish();
	$dbhXAL->disconnect;

	return $ref[0];
}

# function returns a varenummer (string) selected from XALDB by ordrenummer
# when nothing selected, then empty string is returned
sub readXAL_getVareNummer {

	$XALOrderNr = shift;

	if ( $XALOrderNr !~ /^[0-9,.E]+$/ ) {
		return "";
	}

	my $dbhXAL = DBI->connect(
		$connXAL, $XALuser, $XALpass,
		{
			AutoCommit => 1,    # 0 = false
			RaiseError => 0,
			PrintError => 1
		}
	);
	if ( !$dbhXAL ) {
		showMessageBox( 'readXAL_getVareNummer()', $DBI::errstr );
		return '';
	}

	# linienr should always be 1
	# no colon in the end of statement!
	my $sth = $dbhXAL->prepare(
		qq(
			SELECT varenummer FROM xal_supervisor.ordrepost WHERE ordrenummer = $XALOrderNr AND linienr = 1
		)
	);
	$sth->execute() or return $DBI::errstr;
	my @ref = $sth->fetchrow_array;

	$sth->finish();
	$dbhXAL->disconnect;

	if ( $#ref < 0 ) {
		return "";    # returns empty string if nothing has been read
	}
	else {
		# inserts dot into varenummer
		my $varenummer =
		  substr( $ref[0], 0, -4 ) . "\." . substr( $ref[0], -4 );
		$varenummer =~ s/X/x/g;    # replaces 'X' with 'x'
		return $varenummer;
	}
}

#function returns a row of values as a table of strings from XALDB selected by varenummer
sub readXAL_getPrintKart {

	my $XALVareNummer = shift;

	#showMessageBox ('readXAL_getPrintKart()', $XALVareNummer);

	# removes a dot from the $XALVareNummer
	if ( $XALVareNummer =~ /\./ ) {
		$XALVareNummer =~ s/\.//g;
	}
	$XALVareNummer =~ s/x/X/g;    # replaces 'x' with 'X'

	my $dbhXAL = DBI->connect(
		$connXAL, $XALuser, $XALpass,
		{
			AutoCommit => 1,      # 0 = false
			RaiseError => 0,
			PrintError => 1
		}
	);
	if ( !$dbhXAL ) {
		showMessageBox( 'readXAL_getPrintKart()', $DBI::errstr );
		return 0;
	}

	# $XALVareNummer shall be without a dot
	my $sth = $dbhXAL->prepare(
		qq(
			SELECT * FROM xal_supervisor.dd_printkart WHERE varenummer = '$XALVareNummer'
		)
	);
	$sth->execute() or return $DBI::errstr;
	my @ref = $sth->fetchrow_array;

	$sth->finish();
	$dbhXAL->disconnect;

	my $varenummer = $ref[4];

	# inserts dot into the varenummer
	if ( $varenummer !~ m/\./ ) {
		$varenummer = substr( $ref[4], 0, -4 ) . "\." . substr( $ref[4], -4 );
	}
	$ref[4] = $varenummer;
	return @ref;
}

# this function returns a revisions-letter according to the number of existing jobs
sub getRevision {

	my $XALVareNummer = shift;

	# remove a dot from the $XALVareNummer
	if ( $XALVareNummer =~ /\./ ) {
		$XALVareNummer =~ s/\.//g;
	}
	$XALVareNummer =~ s/x/X/g;    # replace a 'x' with 'X'
	$XALVareNummer = substr( $XALVareNummer, 0, 8 );    # cut the yyww

	my @myRevisionTab = (
		'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
		'I', 'J', 'K', 'L', 'M', 'N', 'O'
	);

	my $dbhXAL = DBI->connect(
		$connXAL, $XALuser, $XALpass,
		{
			AutoCommit => 1,                            # 0 = false
			RaiseError => 0,
			PrintError => 1
		}
	);
	if ( !$dbhXAL ) {
		showMessageBox( 'getRevision()', $DBI::errstr );
		return '';
	}

	my $sth = $dbhXAL->prepare(
		qq(
			SELECT Count(*) FROM XAL_SUPERVISOR.DD_printkart WHERE SUBSTR(varenummer, 1, 8) IN ('$XALVareNummer')
		)
	);
	$sth->execute() or return $DBI::errstr;
	my @ref = $sth->fetchrow_array;

	$sth->finish();
	$dbhXAL->disconnect;

	my $myCount    = $ref[0];
	my $myRevision = $myRevisionTab[$myCount];

	#showMessageBox ('getRevision()', 'myRevision: ' . $myRevision);

	return $myRevisionTab[ $myCount - 1 ];
}

# the function returns an index number according to surface type
# the input is a table of surfaces
# indexes in return maybe have to be adjusted..
sub getSurface {

	my $surface_ref = shift;
	my @surfaceArr  = @{$surface_ref};
	my $i           = "";

	# is surface unique?
	my $mySurfaceSum = 0;
	foreach $i (@surfaceArr) {
		$mySurfaceSum += $i;    # adds values from the passed table
	}

	#showMessageBox( "getSurface()", 'surface: ' . $mySurfaceSum );

	if ( $mySurfaceSum > 1 ) {
		showMessageBox( "getSurface()",
			'surface is not unique: ' . $mySurfaceSum );
		return 'Not_Set';
	}

   #my @mySurParams = ( $myHAL, $myKemNIAU, $myBlyfri_HAL, $myKemSN, $myKemAG );
	if (   ( $surfaceArr[0] == 1 )
		&& ( $surfaceArr[1] == 0 )
		&& ( $surfaceArr[2] == 0 )
		&& ( $surfaceArr[3] == 0 )
		&& ( $surfaceArr[4] == 0 ) )
	{
		return 'HAL';
	}

	elsif (( $surfaceArr[0] == 0 )
		&& ( $surfaceArr[1] == 1 )
		&& ( $surfaceArr[2] == 0 )
		&& ( $surfaceArr[3] == 0 )
		&& ( $surfaceArr[4] == 0 ) )
	{
		return 'Kem.Guld';
	}
	elsif (( $surfaceArr[0] == 0 )
		&& ( $surfaceArr[1] == 0 )
		&& ( $surfaceArr[2] == 1 )
		&& ( $surfaceArr[3] == 0 )
		&& ( $surfaceArr[4] == 0 ) )
	{
		return 'Blyfri_HAL';
	}
	elsif (( $surfaceArr[0] == 0 )
		&& ( $surfaceArr[1] == 0 )
		&& ( $surfaceArr[2] == 0 )
		&& ( $surfaceArr[3] == 1 )
		&& ( $surfaceArr[4] == 0 ) )
	{
		return 'Kem.Tin';
	}
	elsif (( $surfaceArr[0] == 0 )
		&& ( $surfaceArr[1] == 0 )
		&& ( $surfaceArr[2] == 0 )
		&& ( $surfaceArr[3] == 0 )
		&& ( $surfaceArr[4] == 1 ) )
	{
		return 'Kem.Silver';
	}
	else {
		#any other surface
		return 'Not_Set';
	}
}

sub prepare_GUIResp2 {

	showMessageBox( "prepare_GUIResp2()", 'a kuku!' );

	return -1;
}

# the function creates a txt-file with job-data from XALDB
# returns 0 if file created or -1 if something goes wrong
# the input parameter is the order number
sub prepare_GUIResp {

	my $myInputNumber = shift;

	my $myVarenummer = $myInputNumber;
	my $XALOrderNr   = '""';
	my $KUNDE        = '""';

	# check for input value (is it a varenumber?)
	if ( $myInputNumber =~ m/^[0-9]*[xX-][0-9,.]+$/ ) {

		# inserts dot into varenummer
		if ( $myInputNumber !~ /\./ ) {
			$myVarenummer = substr( $myInputNumber, 0, -4 ) . "\."
			  . substr( $myInputNumber, -4 );
		}
		$myVarenummer =~ s/X/x/g;    # replaces 'X' with 'x'

		#$KUNDE        	= readXAL_getKundeByVareNr($myVarenummer);
		#$KUNDE 		=~ s/ /_/g;
		$myVarenummer =~ s/(X.*)//g;    # get the first part of jobnumber
		$KUNDE = getPFACustomer( $myFilename, $myVarenummer );
	}

	# check for input value (is it an ordernumber?)
	elsif ( $myInputNumber =~ m/^[0-9]+$/ ) {
		$XALOrderNr   = $myInputNumber;
		$myVarenummer = readXAL_getVareNummer($XALOrderNr);
		$KUNDE        = readXAL_getKundeByOrderNr($XALOrderNr);
		$KUNDE =~ s/ /_/g;              # replace space by underscore
	}

	# not an ordernumber nor a varenumber
	else {
		showMessageBox( "prepare_GUIResp()",
			'Wrong number inserted: ' . $myInputNumber );
		return -1;
	}

	my @myVNRDetails    = readXAL_getPrintKart($myVarenummer);
	my $kundetegningsnr = $myVNRDetails[5];
	$kundetegningsnr =~ s/ /_/g;        # replace any space by underscore

	my $myHAL        = $myVNRDetails[71];
	my $myKemNIAU    = $myVNRDetails[82];
	my $myBlyfri_HAL = $myVNRDetails[143];
	my $myKemSN      = $myVNRDetails[144];
	my $myKemAG      = $myVNRDetails[145];
	my @mySurParams = ( $myHAL, $myKemNIAU, $myBlyfri_HAL, $myKemSN, $myKemAG );
	my $overflade   = getSurface( \@mySurParams );

	my $scoring = 'No';
	if ( $myVNRDetails[99] != 0 ) {
		$scoring = 'Yes';
	}

	my $rejfning = 'No';
	if ( $myVNRDetails[101] != 0 ) {
		$rejfning = 'Yes';
	}

	my $afrivelig = 'No';
	if (   ( $myVNRDetails[92] != 0 )
		&& ( $myVNRDetails[97] =~ m/^[K]/ ) )
	{
		$afrivelig = 'Top';
	}
	elsif (( $myVNRDetails[92] != 0 )
		&& ( $myVNRDetails[97] =~ m/^[L]/ ) )
	{
		$afrivelig = 'Bottom';
	}
	elsif (
		( $myVNRDetails[92] != 0 )
		&& (   ( $myVNRDetails[97] =~ m/^[L\+K]/ )
			|| ( $myVNRDetails[97] =~ m/^[K\+L]/ ) )
	  )
	{
		$afrivelig = 'Both';
	}

	my $plugged = 'No';
	if (   ( $myVNRDetails[129] != 0 )
		&& ( $myVNRDetails[130] =~ m/^[K]/ ) )
	{
		$plugged = 'Top';
	}
	elsif (( $myVNRDetails[129] != 0 )
		&& ( $myVNRDetails[130] =~ m/^[L]/ ) )
	{
		$plugged = 'Bottom';
	}
	elsif (
		( $myVNRDetails[129] != 0 )
		&& (   ( $myVNRDetails[130] =~ m/^[L\+K]/ )
			|| ( $myVNRDetails[130] =~ m/^[K\+L]/ ) )
	  )
	{
		$plugged = 'Both';
	}

	my $galguld = 'No';
	if ( $myVNRDetails[85] != 0 ) {
		$galguld = 'Both';
	}

	my $kul = 'No';
	if (   ( $myVNRDetails[107] != 0 )
		&& ( $myVNRDetails[108] =~ m/^kul/ )
		&& ( $myVNRDetails[110] =~ m/^[K]/ ) )
	{
		$kul = 'Top';
	}
	elsif (( $myVNRDetails[107] != 0 )
		&& ( $myVNRDetails[108] =~ m/^kul/ )
		&& ( $myVNRDetails[110] =~ m/^[L]/ ) )
	{
		$kul = 'Bottom';
	}
	elsif (
		   ( $myVNRDetails[107] != 0 )
		&& ( $myVNRDetails[108] =~ m/^kul/ )
		&& (   ( $myVNRDetails[110] =~ m/^[L\+K]/ )
			|| ( $myVNRDetails[110] =~ m/^[K\+L]/ ) )
	  )
	{
		$kul = 'Both';
	}

	my $keramisk = 'No';
	if ( ( $myVNRDetails[107] != 0 ) && ( $myVNRDetails[108] =~ m/fill/ ) ) {
		$keramisk = 'Viafill';
	}
	elsif (( $myVNRDetails[107] != 0 )
		&& ( $myVNRDetails[108] =~ m/keramisk/ ) )
	{
		$keramisk = 'Keramisk';
	}
	elsif (
		( $myVNRDetails[107] != 0 )
		&& (   ( $myVNRDetails[108] =~ m/^L\+K/ )
			|| ( $myVNRDetails[108] =~ m/^K\+L/ ) )
	  )
	{
		$keramisk = 'Both';
	}

	# 15	RXPLADETYKKELSE	NUMBER(32,16)
	my $tykkelse = $myVNRDetails[15];
	$tykkelse =~ s/,/\./g;    # replace a comma by a dot
	$tykkelse *= 1000;
		
	# 77	TYPENAVN	VARCHAR2(20)
	my $myBuildUp = $myVNRDetails[77];
	my $materiale = readXAL_getRaapladeName($myBuildUp);

	# both variables to be adjusted
	my $nitte_fix = 'No';          # 2 cases
	my $klasse    = 'Standard';    # 4 cases

	my $revision = getRevision($myVarenummer);

	my @data = ();
	$data[0] =
	  'set Order_Nr = ' . $XALOrderNr . "\n"; # for end-of-line don't use a '\n'

	# add a dot to the varenummer if it does'nt contain any
	my $dotVareNummer;
	if ( $myVarenummer !~ /\.+/ ) {
		$dotVareNummer =
		  substr( $myVarenummer, 0, -4 ) . "\." . substr( $myVarenummer, -4 );
	}
	else {
		$dotVareNummer = $myVarenummer;
	}

	$data[1]  = 'set MANUF = ' . $dotVareNummer . "\n";       # now with a dot
	$data[2]  = 'set REVISION = ' . $revision . "\n";
	$data[3]  = 'set KUNDE = ' . $KUNDE . "\n";
	$data[4]  = 'set Tegn_Nr = ' . $kundetegningsnr . "\n";
	$data[5]  = 'set tykkelse = ' . $tykkelse . "\n";
	$data[6]  = 'set materiale = ' . $materiale . "\n";
	$data[7]  = 'set overflade = ' . $overflade . "\n";
	$data[8]  = 'set scoring = ' . $scoring . "\n";
	$data[9]  = 'set nitte_fix = ' . $nitte_fix . "\n";
	$data[10] = 'set afrivelig = ' . $afrivelig . "\n";
	$data[11] = 'set plugged = ' . $plugged . "\n";
	$data[12] = 'set galguld = ' . $galguld . "\n";
	$data[13] = 'set kul = ' . $kul . "\n";
	$data[14] = 'set keramisk = ' . $keramisk . "\n";
	$data[15] = 'set klasse = ' . $klasse . "\n";

	# check if the length of each row in @data is always the same
	# if it is different then a message box will be shown 
	my @myArrSplittedLine = ();
	foreach my $myRow (@data) {
		@myArrSplittedLine = split /[\s]/, $myRow;    # split by space
		if ( $#myArrSplittedLine != 3 ) {
			showMessageBox( 'prepare_GUIResp()',
				    "Error in GUIResp: \n"
				  . "The length of row is: "
				  . $#myArrSplittedLine . "\n"
				  . $myRow );
			return -1;
		}
	}

	my $myFilename = $ENV{TMP} . '\gui_resp';
	open( my $myOUTPUTFILE, ">", $myFilename )
	  || return -1;    # .txt -> .out
	print $myOUTPUTFILE @data;
	close $myOUTPUTFILE;

	#	showMessageBox( 'prepare_GUIResp',
	#		'file ' . $myFilename . "\n" . 'updated by ' . $#data . ' lines' );
	return @data;
}

sub xrayBeforeDrill {

	my $XALVareNummer = shift;

	# showMessageBox ('xrayBeforeDrill()', $XALVareNummer );

	if ( $XALVareNummer =~ /\./ ) {
		$XALVareNummer =~ s/\.//g;  # removes a dot from varenummer if necessary
	}
	$XALVareNummer =~ s/x/X/g;      # replaces 'x' with 'X'

	my $dbhXAL = DBI->connect(
		$connXAL, $XALuser, $XALpass,
		{
			AutoCommit => 1,        # 0 = false
			RaiseError => 0,
			PrintError => 1
		}
	);
	if ( !$dbhXAL ) {
		showMessageBox( 'readXAL_checkVareNummer()', $DBI::errstr );
		return -1;
	}

	my $sth = $dbhXAL->prepare(
		qq(
			SELECT Count(*) FROM (SELECT * FROM xal_supervisor.MPSRUTE 
				WHERE vareprodnr = '$XALVareNummer' AND operation = 'BOR OPSTIL')
		)
	);
	$sth->execute() or return $DBI::errstr;
	my @ref = $sth->fetchrow_array;

	$sth->finish();
	$dbhXAL->disconnect;

	return $ref[0];
}

return 1;
