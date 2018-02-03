#!c:/Perl/bin/perl 

use Genesis;

sub TOLERANCE () { 1e-13 }    # ??

sub are_equal {
	my ( $a, $b ) = @_;
	return ( abs( $a - $b ) < TOLERANCE );
}

sub round {
	my ( $nr, $decimals ) = @_;
	return (-1) *
	  ( int( abs($nr) * ( 10**$decimals ) + .5 ) / ( 10**$decimals ) )
	  if $nr < 0;
	return int( $nr * ( 10**$decimals ) + .5 ) / ( 10**$decimals );
}

sub isStep {
	$job_name  = shift;
	$step_name = shift;
	if ( ( $job_name eq '' ) || ( $step_name eq '' ) ) {
		print "isStep(): Wrong parameters. \n";
		exit(0);
	}

	$f->INFO(
		'entity_type' => 'job',
		'entity_path' => "$job_name",
		'data_type'   => 'steps_list'
	);
	@step_list = @{ $f->{doinfo}{gSTEPS_LIST} };
	for ( $i = 0 ; $i <= $#step_list ; $i++ ) {
		if ( $step_list[$i] eq $step_name ) {
			return 1;
		}
	}
	return 0;
}

sub getCopperInnerLayers {

	$job_name = shift;
	if ( $job_name eq '' ) {
		print "getCopperInnerLayers(): Wrong parameters. \n";
		exit(0);
	}

	$f->INFO(
		entity_type => 'matrix',
		entity_path => "$job_name/matrix",
		data_type   => 'ROW'
	);

	my $total_rows = @{ $f->{doinfo}{gROWrow} };
	if ( $total_rows == -1 ) {
		return "there aren't any copper layers in this job. \n";
	}

	my $mRow;
	my $mLayerName;
	my $mLayerContext;
	my $mLayerType;
	my $mLayerSide;
	my @cuLayers = ();

	# pacz tesz c:\Users\pkr.PRIDANA\.genesis\scripts\info_matrix.png
	for ( $count = 0 ; $count <= $total_rows ; $count++ ) {
		$mRow          = ${ $f->{doinfo}{gROWrow} }[$count];
		$mLayerName    = ${ $f->{doinfo}{gROWname} }[$count];
		$mLayerContext = ${ $f->{doinfo}{gROWcontext} }[$count];
		$mLayerType    = ${ $f->{doinfo}{gROWlayer_type} }[$count];
		$mLayerSide    = ${ $f->{doinfo}{gROWside} }[$count];
		if (
			( $mLayerContext eq 'board' )
			&& (   ( $mLayerType eq 'signal' )
				|| ( $mLayerType eq 'mixed' )
				|| ( $mLayerType eq 'power_ground' ) )

			&& ( $mLayerSide eq 'inner' )
		  )
		{
			push @cuLayers, $mLayerName;    # add name of layer to array
		}
	}
	return @cuLayers;
}

# this functions returns a hash-array of coordinates for specified item on given layer
# if item not found then the array is empty (length -1)
sub getXY {
	my $myItem       = shift;
	my $myEntityPath = shift;
	#my $myAttributes = shift;			# not implemented yet

	local $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";

	#local ($attribute) = 'fiducial_name';
	my @myFeatures     = ();
	my @mySplittedLine = ();

	$f->INFO(
		'units'         => 'mm',
		'entity_type' => 'layer',
		'entity_path' => $myEntityPath,
		'data_type'   => 'FEATURES',
		'parse' => 'no'
	);
	my $k = 0;
	my $x = 'x';
	my $y = 'y';
	open( CSHFILE, $csh_file )
	  or die " ---> 1. can not open file $csh_file: $!\n";
	while ( $line = <CSHFILE> ) {

		#next unless ( $line =~ /$attribute/ );
		@mySplittedLine = split /\s/, $line;
		$mySplittedLine[3] =~ s/^r//g;
		if ( are_equal( $myItem, $mySplittedLine[3] ) == 1 ) {
			$x = $x . $k;
			$y = $y . $k;
			push( @myFeatures, { $x => $mySplittedLine[1] } );
			push( @myFeatures, { $y => $mySplittedLine[2] } );
			$k++;
			$x = 'x';
			$y = 'y';
		}
	}
	close(CSHFILE);
	unlink $csh_file;
	return @myFeatures;
}

######################### MAIN #######################

print "\n\n---------- script starts here --------- \n\n";

$f = new Genesis;

#$job_name = "777x0488.1701";
$job_name = "098x0145.1712";

$isOpen = $f->COM( 'is_job_open', job => $job_name );
if ( $isOpen eq "no" ) {
	$f->COM( open_job, job => $job_name );
	if ( $f->{STATUS} != 0 ) {
		print("Error while open_job. Program exits.");
		exit(0);
	}
}

$step_name = "xray";
my $rs = isStep($job_name, $step_name);
if ($rs == 0) {
	print "Step does not exist. Program exits. \n";
	exit (0);
} 

my @cuLays = getCopperInnerLayers($job_name);

my $myItemMM = 1015;    # <= change the size of item for searching
my $my_entity_path;
my @myCoords = ();
foreach my $myCULayer (@cuLays) {
	$my_entity_path = "$job_name/$step_name/$myCULayer";
	@myCoords = getXY( $myItemMM, $my_entity_path );

	# display coordinates
	if ( $#myCoords == -1 ) {
		print "\nNot such item found on layer $myCULayer\n";
	}

	print("\ncoordinates for item $myItemMM [microns] on layer $myCULayer:\n");
	foreach $record (@myCoords) {
		for $key ( sort keys %$record ) {
			print "$key: $record->{$key}\n";
		}
	}
}

print "\n\nScript end.\n\n";
