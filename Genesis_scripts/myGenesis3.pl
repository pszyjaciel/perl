#!c:/Perl/bin/perl -w

use Genesis;

sub getCopperLayers {

	$job_name = shift;
	if ( $job_name eq '' ) {
		print "Empty parameter job_name \n";
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
	my @cuLayers = ();

	# pacz tesz c:\Users\pkr.PRIDANA\.genesis\scripts\info_matrix.png
	for ( $count = 0 ; $count <= $total_rows ; $count++ ) {
		$mRow          = ${ $f->{doinfo}{gROWrow} }[$count];
		$mLayerName    = ${ $f->{doinfo}{gROWname} }[$count];
		$mLayerContext = ${ $f->{doinfo}{gROWcontext} }[$count];
		$mLayerType    = ${ $f->{doinfo}{gROWlayer_type} }[$count];
		if (
			( $mLayerContext eq 'board' )
			&& (   ( $mLayerType eq 'signal' )
				|| ( $mLayerType eq 'mixed' )
				|| ( $mLayerType eq 'power_ground' ) )
		  )
		{
			push @cuLayers, $mLayerName;		# add name of layer to array
		}
	}
	return @cuLayers;
}

print "---------- script starts here --------- \n\n";
$f = new Genesis;

$job_name = "777x0488.1701";
$isOpen = $f->COM( 'is_job_open', job => $job_name );
print $isOpen . "\n";
if ( $isOpen eq "no" ) {
	$f->COM( open_job, job => $job_name );
	print "STATUS: $f->{STATUS} \n";
	if ( $f->{STATUS} != 0 ) {
		print("kucha. program exits.");
		exit(0);
	}
}
else {
	print("job $job_name opened already. \n");
}

###############

my @cuLays = getCopperLayers($job_name);
print @cuLays;

print "\n\nEnd of program. \n"

