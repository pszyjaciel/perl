#!c:/Perl/bin/perl 

use Win32::OLE;
use Win32::OLE::Variant;

use strict;

my $inspectaPath     = '\\\\192.168.100.10\\inspecta';
my $inspectaUser     = 'pfa';
my $inspectaPassword = 'pfa';

# get list of local shares
my $shares = `net use`;

# search for inspecta share and attach if share not found
if ( $shares !~ m/inspecta/ ) {
	my $myStatus = my $network = Win32::OLE->new('WScript.Network');
	if ( !defined $myStatus ) {
		print("$! \n");
		print("Error creating network object' \n");
		exit(0);
	}



	$myStatus = $network->MapNetworkDrive( 'W:', $inspectaPath, 0, $inspectaUser,
		$inspectaPassword );

	if ( !defined $myStatus ) {
		print "Program exits. \n";
		exit(0);
	}

}

print "Koniec programa... \n";
