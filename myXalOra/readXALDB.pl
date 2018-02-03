#!/usr/bin/perl -w

use DBI;
use strict;

sub readXALDB {
	my $XALVareNummer = shift;

	my $XALsid  = 'xalora';
	my $XALhost = 'oracledb.pridana.local';
	my $XALuser = 'pkr';
	my $XALpass = 'pkramarz';


	my $connXAL = "dbi:Oracle:HOST=$XALhost; SID=$XALsid; port=1521";
	my $dbhXAL  = DBI->connect(
		$connXAL, $XALuser, $XALpass,
		{
			AutoCommit => 1,    # 0 = false
			RaiseError => 0,
			PrintError => 0
		}
	) or return $DBI::errstr;

	# prepare and execute SQL-statement
	my $sth = $dbhXAL->prepare(
		qq(
	SELECT * FROM xal_supervisor.dd_printkart WHERE varenummer = '$XALVareNummer'
	)
	);
	$sth->execute() or die $DBI::errstr;
	my @ref = $sth->fetchrow_array;

	$sth->finish();
	$dbhXAL->disconnect;

	return @ref;
}

return 1;
