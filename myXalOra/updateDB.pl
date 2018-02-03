#!/usr/bin/perl -w

use DBI;
use strict;
require "readJobAnalyze.pl";

my $PFAdbase = 'xe';
#my $PFAhost  = 'term-pfafilm.pridana.local';	# dodac do hosts albo ORA-12545
my $PFAhost  = '192.168.100.118';
my $PFAsid   = 'xe';
my $PFAuser  = 'pfa';
my $PFApass  = 'pfa_passwd';

# function inserts a new row into table pfa_job
# sometimes ORA-03113: end-of-file on communication channel
sub insertPFAjob {
	my ($args) = @_;

	my $connPFA = "dbi:Oracle:HOST=$PFAhost; SID=$PFAsid; port=1521";
	my $dbhPFA  = DBI->connect(
		$connPFA, $PFAuser, $PFApass,
		{
			AutoCommit => 0,    # 0 = false
			RaiseError => 0,
			PrintError => 0,
			ChopBlanks => 1     # CHAR chopped
		}
	) or return $DBI::errstr;

	my $sql =
	    "INSERT INTO pfa_job VALUES ("
	  . "'$args->{varenummer}', '$args->{kundetegningsnr}', "
	  . "$args->{antallppxpp}, $args->{antalprintpxpp}, "
	  . "$args->{hal}, $args->{blyfrihal}, $args->{kemsn}, $args->{kemag}, $args->{kemiskniau}, "
	  . "CURRENT_TIMESTAMP)";

	my $sthPFA = $dbhPFA->prepare( $sql, { ora_check_sql => 0 } );

	$sthPFA->execute();
	my $rows = $sthPFA->rows;
	if ( $rows == 0 ) {
		print( DBI::errstr() . "\n" );
	}

	$sthPFA->finish();
	$dbhPFA->disconnect() or return $DBI::errstr;

	return $rows;
}

sub updatePFAjob {
	my ($args) = @_;

	my $connPFA = "dbi:Oracle:HOST=$PFAhost; SID=$PFAsid; port=1521";
	my $dbhPFA  = DBI->connect(
		$connPFA, $PFAuser, $PFApass,
		{
			AutoCommit => 0,    # 0 = false
			RaiseError => 0,
			PrintError => 0,
			ChopBlanks => 1     # CHAR chopped
		}
	) or return $DBI::errstr;

	my $sql =
	    "UPDATE pfa_job SET "
	  . "KUNDETEGNINGSNR = $args->{kundetegningsnr}, "
	  . "ANTALLPPXPP = $args->{antallppxpp}, ANTALPRINTPXPP = $args->{antalprintpxpp}, "
	  . "HAL = $args->{hal}, BLYFRIHAL = $args->{blyfrihal}, KEMSN = $args->{kemsn}, "
	  . "KEMAG = $args->{kemag}, KEMISKNIAU = $args->{kemiskniau}, "
	  . "DONEAT = CURRENT_TIMESTAMP "
	  . "WHERE VARENUMMER = '$args->{varenummer}'";

	my $sthPFA = $dbhPFA->prepare( $sql, { ora_check_sql => 0 } );

	$sthPFA->execute();
	my $rows = $sthPFA->rows;
	if ( $rows == 0 ) {
		print( DBI::errstr() . "\n" );
	}

	$sthPFA->finish();
	$dbhPFA->disconnect() or return $DBI::errstr;

	return $rows;
}

return 1;
