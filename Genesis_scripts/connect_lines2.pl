#!c:/Perl/bin/perl -w

#warstwy wewnetrzne:
#\\192.168.100.10\archive
#user: CRPT_44045\aoi
#pass: aoi
#
#warstwy zewnetrzne:
#\\192.168.100.10\foto_archive
#user: CRPT_44045\aoi
#pass: aoi
#

# uruchamiac w edytorze stepu
use strict;
use Tk;
use Genesis;
use Math::Trig;

my $genesis = new Genesis;

# a little bit extended version - now with the modulus for a new line definition
sub showArray {
	my $array_ref    = shift;
	my @myLocalArray = @{$array_ref};
	my $myModulus    = shift;

	$myModulus = 1 unless defined $myModulus;    # set default after the fact
	if ( $myModulus == 0 ) {
		$myModulus = 1;
	}

	for ( my $i = 0 ; $i <= $#myLocalArray ; $i++ ) {

		if ( $i % $myModulus == 0 ) {
			print("\n");
		}
		print( "[" . $i . "]: " . $myLocalArray[$i] . "\t" );
	}
	print("\n");
}

sub getSelected {

	# $$ is the process ID (PID)
	my $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";

	my $myLocalEntity = shift;

	$genesis->INFO(
		units       => "mm",
		entity_type => "layer",
		entity_path => $myLocalEntity,
		data_type   => "FEATURES",
		options     => "select"
	);

	my $fh;
	my $myStatus = open( $fh, $csh_file );

	# check read status
	if ( !defined $myStatus ) {
		print( "$!: $csh_file \n", 'errorline' );
		exit(0);
	}

	my @myLocalData = <$fh>;
	close($fh);
	unlink $csh_file;

	my @myLocalRow;
	my %featCoords;
	@myLocalRow = split / /, $myLocalData[1];
	$featCoords{'xs1'} = $myLocalRow[1];
	$featCoords{'ys1'} = $myLocalRow[2];
	$featCoords{'xe1'} = $myLocalRow[3];
	$featCoords{'ye1'} = $myLocalRow[4];

	@myLocalRow = split / /, $myLocalData[2];
	$featCoords{'xs2'} = $myLocalRow[1];
	$featCoords{'ys2'} = $myLocalRow[2];
	$featCoords{'xe2'} = $myLocalRow[3];
	$featCoords{'ye2'} = $myLocalRow[4];

	return %featCoords;
}

sub getProfileCenter {

	my $localEntityPath = shift;

	$genesis->INFO(
		units       => 'mm',
		entity_type => 'step',
		entity_path => $localEntityPath
	);

	my $myXmin = $genesis->{doinfo}{gPROF_LIMITSxmin};
	my $myYmin = $genesis->{doinfo}{gPROF_LIMITSymin};
	my $myXmax = $genesis->{doinfo}{gPROF_LIMITSxmax};
	my $myYmax = $genesis->{doinfo}{gPROF_LIMITSymax};

	my $cx = ( $myXmin + ( ( $myXmax - $myXmin ) / 2 ) );
	my $cy = ( $myYmin + ( ( $myYmax - $myYmin ) / 2 ) );

	my @profCenterXY = ( $cx, $cy );
	return @profCenterXY;

}

# selects arcs on layer and returns the number of selected features
sub getSelArcs {

	my $localLayer = shift;

	# Un-selects all the features in all the affected layers.
	$genesis->COM('sel_clear_feat');

	# Resets all the filter values to their default values
	$genesis->COM( 'filter_reset', filter_name => 'popup' );

# The command is used for setting the features filter parameters. The filter is used for
# various functions, such as ‘features selection’.
	$genesis->COM(
		'filter_set',
		filter_name  => 'popup',
		update_popup => 'no',
		feat_types   => 'arc'
	);

	# Command for starting an area selection (it resets the points list).
	$genesis->COM('filter_area_strt');
	$genesis->COM(
		'filter_area_end',
		layer          => $localLayer,
		filter_name    => 'popup',
		operation      => 'select',
		area_type      => 'none',
		inside_area    => 'no',
		intersect_area => 'no'
	);

	return $genesis->COM('get_select_count');
}

print("\n\n\n");
print(
" --------------------------------------------------------------------------------"
	  . "\n" );
print(
" ################################ program starts ################################"
	  . "\n" );
print(
" --------------------------------------------------------------------------------"
	  . "\n" );

my $file_dir = "$ENV{GENESIS_DATA}/jobs";

my $job_name = $ENV{JOB};
if ( !defined $job_name ) {
	print("Error: First open a job. \n");
	exit(0);
}

my $isOpen = $genesis->COM( 'is_job_open', job => $job_name );
print "Is job $job_name open? " . $isOpen . "\n";

if ( $isOpen eq "no" ) {
	$genesis->COM( 'open_job', job => $job_name );
	print "STATUS: $genesis->{STATUS} \n";
	if ( $genesis->{STATUS} != 0 ) {
		print("kucha. program exits.");
		exit(0);
	}
}
else {
	print("job $job_name opened already. \n");
}

# najsamfpjerf otworzyc editora
# $genesis->COM('get_message_bar');
# print $genesis->{COMANS} . "\n";

# The routine is used for automatically re-arranging the rows according to the layer
# naming convention, as it is defined in the lyr_rule file.
# $genesis->COM( 'matrix_auto_rows', job => $job_name, matrix => 'matrix' );

$genesis->INFO(
	entity_type => 'matrix',
	entity_path => "$job_name/matrix",
	data_type   => 'ROW'
);

my $total_rows = @{ $genesis->{doinfo}{gROWrow} };
if ( $total_rows == -1 ) {
	print "matrix cannot be empty.\n";
	exit(0);
}

print( 'total_rows: ' . $total_rows . "\n" );

# kasowanie warstwy aoi_profile (o ile istnieje)
my $myLayer = 'aoi_profile';
my $mLayerName;
my $mRow;
for ( my $count = 0 ; $count <= $total_rows ; $count++ ) {
	$mLayerName = ${ $genesis->{doinfo}{gROWname} }[$count];
	$mRow       = ${ $genesis->{doinfo}{gROWrow} }[$count];
	if ( $mLayerName eq $myLayer ) {
		$genesis->COM(
			'matrix_delete_row',
			job    => $job_name,
			matrix => 'matrix',
			row    => $mRow
		);
	}
}

# The command adds a new layer to the job matrix. The layer is created in all of the job steps.
$genesis->COM(
	'matrix_add_layer',
	job      => $job_name,
	matrix   => 'matrix',
	layer    => $myLayer,
	row      => $total_rows + 1,
	context  => 'board',
	type     => 'document',
	polarity => 'positive'
);

my $myStep = 'pcb';

# czasami trza najpierw otworzyc edytora zanim wolam display_layer
$genesis->COM(
	'display_layer',
	name    => $myLayer,
	display => 'yes',
	number  => 1
);
$genesis->COM( 'work_layer', name => $myLayer );

$genesis->COM( 'profile_to_rout', layer => $myLayer, width => 101 );

##############
# teras szukamy duzych arkow i expandujemy na linie		- zly filtr!

# Un-selects all the features in all the affected layers.
$genesis->COM('sel_clear_feat');

# Resets all the filter values to their default values
$genesis->COM( 'filter_reset', filter_name => 'popup' );

# filtr globalny tylko na same arki
$genesis->COM(
	'filter_set',
	filter_name  => 'popup',
	update_popup => 'no',
	feat_types   => 'arc'
);

# select arcs with 5mm > diameter < 20mm
$genesis->COM(
	'adv_filter_set',
	filter_name     => 'popup',
	update_popup    => 'yes',
	selected        => 'no',
	arc_values      => 'yes',
	min_sweep_angle => 0,
	max_sweep_angle => 0,
	min_diameter    => 5,
	max_diameter    => 20
);

$genesis->COM('filter_area_strt');

$genesis->COM(
	'filter_area_end',
	layer          => $myLayer,
	filter_name    => 'popup',
	operation      => 'select',
	area_type      => 'none',
	inside_area    => 'no',
	intersect_area => 'no'
);

# Breaks an arc to lines according to a tolerance value specified by the user.
my $mySelected = $genesis->COM('get_select_count');
if ( $mySelected > 0 ) {
	$genesis->COM( 'arc2lines', arc_line_tol => 906 );
}
else {
	print( "-> Not any arcs with radius >5mm" . "\n" );
}

##############
# teraz male arki

# Un-selects all the features in all the affected layers.
$genesis->COM('sel_clear_feat');

# Resets all the filter values to their default values
$genesis->COM( 'filter_reset', filter_name => 'popup' );

# filtr globalny tylko na same arki
$genesis->COM(
	'filter_set',
	filter_name  => 'popup',
	update_popup => 'no',
	feat_types   => 'arc'
);

# select arcs with diameter < 5mm
$genesis->COM(
	'adv_filter_set',
	filter_name     => 'popup',
	update_popup    => 'yes',
	selected        => 'no',
	arc_values      => 'yes',
	min_sweep_angle => 0,
	max_sweep_angle => 0,
	min_diameter    => 0,
	max_diameter    => 5
);

$genesis->COM('filter_area_strt');

$genesis->COM(
	'filter_area_end',
	layer          => $myLayer,
	filter_name    => 'popup',
	operation      => 'select',
	area_type      => 'none',
	inside_area    => 'no',
	intersect_area => 'no'
);

$mySelected = $genesis->COM('get_select_count');
if ( $mySelected == 0 ) {
	print("There are no arcs < 5.0mm in the profile. Exit.\n");
	exit(0);
}

my $myEntity = "$job_name/$myStep/aoi_profile";

# daj info o zaznaczonych elementach
$genesis->INFO(
	units       => "mm",
	entity_type => "layer",
	entity_path => $myEntity,
	data_type   => "FEATURES",
	options     => "select"
);

my $fh;

# $$ is the process ID (PID)
my $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";
my $myStatus = open( $fh, $csh_file );

# check read status
if ( !defined $myStatus ) {
	print( "$!: $csh_file \n", 'errorline' );
	exit(0);
}

my @smallArcs = <$fh>;
close($fh);
unlink $csh_file;

if ( $#smallArcs == 0 ) {
	print( "#smallArcs: " . $#smallArcs . "\n" );
	exit(0);
}

#showArray( \@smallArcs );

# a teraz mozna je usunac o ile przynajmniej jeden arc jest zaznaczony
$mySelected = $genesis->COM('get_select_count');

print( "mySelected: " . $mySelected . "\n" );

if ( $mySelected > 0 ) {
	$genesis->COM('sel_delete');
}

#################################

# get the center of the board
my @profCenter = getProfileCenter("$job_name/pcb");
my $cx         = $profCenter[0];
my $cy         = $profCenter[1];

print( "cx: " . $cx . "\n" );
print( "cy: " . $cy . "\n" );

my $xs, my $ys, my $xe, my $ye;
my $myLengthX1, my $myLengthX2;
my $myLengthY1, my $myLengthY2;

my $xs1, my $ys1, my $xe1, my $ye1;
my $xs2, my $ys2, my $xe2, my $ye2;

$genesis->VOF;
my @myRow;
my @myPreviousRow;
for ( my $j = 1 ; $j <= $#smallArcs ; $j++ ) {
	@myRow = split / /, $smallArcs[$j];

	# zapamietaj koordynaty poprzedniej linii
	@myPreviousRow = @myRow;

	# wybierz linie z jednego konca zaokraglenia
	$genesis->COM(
		'sel_single_feat',
		operation => 'select',
		x         => $myRow[1],
		y         => $myRow[2],
		tol       => 10,
		cyclic    => 'yes'
	);

	# znajdz gdzie sie laczy z poprzedniom liniom
	# $genesis->COM('get_message_bar');
	# print $genesis->{COMANS} . "\n";

	# wybierz linie z drugiego konca zaokraglenia
	$genesis->COM(
		'sel_single_feat',
		operation => 'select',
		x         => $myRow[3],
		y         => $myRow[4],
		tol       => 10,
		cyclic    => 'yes'
	);

	# daj koordynaty wybranych linii (xs1, xe1, ys1, ye1, xs2, xe2, ys2, ye2)
	my %mySelection = getSelected($myEntity);

	my $mySelFeatures = $genesis->COM('get_select_count');
	print( "--> mySelFeatures: " . $mySelFeatures . "\n" );

	# 1. linia (el)
	my $xs1 = $mySelection{'xs1'};
	my $ys1 = $mySelection{'ys1'};
	my $xe1 = $mySelection{'xe1'};
	my $ye1 = $mySelection{'ye1'};

	# 2. linia (er)
	my $xs2 = $mySelection{'xs2'};
	my $ys2 = $mySelection{'ys2'};
	my $xe2 = $mySelection{'xe2'};
	my $ye2 = $mySelection{'ye2'};

	my $slopeL;
	my $slopeR;

	my $myDivisor1 = abs( $xe1 - $xs1 );
	my $myDivisor2 = abs( $xe2 - $xs2 );

	# wyliczyc nachylenie (slope)
	# uwaga na (X2 - X1) bo nie moze byc == 0
	if ( $myDivisor1 != 0 ) {
		$slopeL = abs( $ye1 - $ys1 ) / $myDivisor1;
		print( "slopeL: " . $slopeL . "\n" );
	}
	else {
		print( "xe1 - xs1 = 0" . "\n" );
	}

	if ( $myDivisor2 != 0 ) {
		$slopeR = abs( $ye2 - $ys2 ) / $myDivisor2;
		print( "slopeR: " . $slopeR . "\n" );
	}
	else {
		print( "xe2 - xs2 = 0" . "\n" );
	}

	if ( !defined $slopeL ) {
		print( "slopL niezdefinowany!" . "\n" );
	}

	if ( !defined $slopeR ) {
		print( "slopR niezdefinowany!" . "\n" );
	}

	# jesli linie sa krotkie (< 2.0mm) to nalezy je usunac i polaczyc
	$myLengthX1 = abs( $mySelection{'xs1'} - $mySelection{'xe1'} );
	$myLengthY1 = abs( $mySelection{'ys1'} - $mySelection{'ye1'} );
	$myLengthX2 = abs( $mySelection{'xs2'} - $mySelection{'xe2'} );
	$myLengthY2 = abs( $mySelection{'ys2'} - $mySelection{'ye2'} );

	if (
		(
			   ( ( $myLengthX1 > 0 ) && ( $myLengthX1 < 0.2 ) )
			&& ( ( $myLengthX2 > 0 ) && ( $myLengthX2 < 0.2 ) )
		)
		|| (   ( ( $myLengthY1 > 0 ) && ( $myLengthY1 < 0.2 ) )
			&& ( ( $myLengthY2 > 0 ) && ( $myLengthY2 < 0.2 ) ) )
	  )
	{
		print( "linie sa krotkie w X i/lub Y" . "\n" );
		$slopeL = 0;
		$slopeR = 0;
	}

# lines are parallel if slope difference is 0 or close to 0 or if both slopes are 0
	my $diffSlope;
	if ( ( defined $slopeL ) && ( defined $slopeR ) ) {
		$diffSlope = abs( $slopeL - $slopeR );
		print( "diffSlope: " . $diffSlope . "\n" );
	}

# NIE laczyc gdy ostry kat
#	if ((defined $slopeL) && (defined $slopeR)) {
#		if ((($slopeL > 5) && ($myDivisor2 == 0)) || (($slopeR > 5) && ($myDivisor1 == 0))) {
#			print( "ostry kont1" . "\n" );
#			$slopeL = 0;
#			$slopeR = 0;
#		}
#	}

	# to samo gdy jeden slop jest > 1 a drugi 0 to tez kat ostry
	if ( ( defined $slopeL ) && ( defined $slopeR ) ) {
		if (   ( ( $slopeL > 1 ) && ( $slopeR == 0 ) )
			|| ( ( $slopeL == 0 ) && ( $slopeR > 1 ) ) )
		{
			print( "ostry kont2" . "\n" );
			$slopeL = 0;
			$slopeR = 0;
		}
	}

	if ( ( defined $slopeL ) && ( defined $slopeR ) ) {
		if ( $diffSlope < 0.2 ) {
			print( "ostry kont3" . "\n" );
			$slopeL = 0;
			$slopeR = 0;
		}
	}

	if (   ( ( !defined $slopeL ) && ( $myDivisor1 == 0 ) )
		|| ( ( !defined $slopeR ) && ( $myDivisor2 == 0 ) ) )
	{
		print( "ostry kont4" . "\n" );
		$slopeL = 0;
		$slopeR = 0;
	}

	if (   ( ( !defined $slopeL ) && ( $slopeR > 3 ) )
		|| ( ( !defined $slopeR ) && ( $slopeL > 3 ) ) )
	{
		if ( ( $myDivisor1 == 0 ) || ( $myDivisor2 == 0 ) ) {
			print( "ostry kont5" . "\n" );
			$slopeL = 0;
			$slopeR = 0;
		}
	}

	if ( $j == 2 ) {
		#exit(0);
	}

	# connect lines if they are parallel
	if (   ( ( $diffSlope > 0 ) && ( $diffSlope < 0.005 ) )
		|| ( ( $slopeL == 0 ) && ( $slopeR == 0 ) )
		|| ( ( $xe1 - $xs1 == 0 ) && ( $xe2 - $xs2 == 0 ) ) )
	{
		print( "--> linie rownolegle" . "\n" );

		# znajdz najblizszy koniec
		my $diffXs1Xs2 = abs( $xs1 - $xs2 );
		my $diffXs1Xe2 = abs( $xs1 - $xe2 );
		my $diffXe1Xs2 = abs( $xe1 - $xs2 );
		my $diffXe1Xe2 = abs( $xe1 - $xe2 );

		my $diffYs1Ys2 = abs( $ys1 - $ys2 );
		my $diffYs1Ye2 = abs( $ys1 - $ye2 );
		my $diffYe1Ys2 = abs( $ye1 - $ys2 );
		my $diffYe1Ye2 = abs( $ye1 - $ye2 );

		# 4 diagonale
		# a = $diffXs1Xs2
		# b = $diffYs1Ys2
		my $diag =
		  sqrt( ( $diffXs1Xs2 * $diffXs1Xs2 ) + ( $diffYs1Ys2 * $diffYs1Ys2 ) );
		$xs = $xs1;
		$ys = $ys1;
		$xe = $xs2;
		$ye = $ys2;

		# $diffXs1Xe2 $diffYs1Ye2
		my $temp =
		  sqrt( ( $diffXs1Xe2 * $diffXs1Xe2 ) + ( $diffYs1Ye2 * $diffYs1Ye2 ) );
		if ( $temp < $diag ) {
			$diag = $temp;
			$xs   = $xs1;
			$ys   = $ys1;
			$xe   = $xe2;
			$ye   = $ye2;
		}

		# $diffXe1Xs2 $diffYe1Ys2
		$temp =
		  sqrt( ( $diffXe1Xs2 * $diffXe1Xs2 ) + ( $diffYe1Ys2 * $diffYe1Ys2 ) );
		if ( $temp < $diag ) {
			$diag = $temp;
			$xs   = $xe1;
			$ys   = $ye1;
			$xe   = $xs2;
			$ye   = $ys2;
		}

		# $diffXe1Xe2 $diffYe1Ye2
		$temp =
		  sqrt( ( $diffXe1Xe2 * $diffXe1Xe2 ) + ( $diffYe1Ye2 * $diffYe1Ye2 ) );
		if ( $temp < $diag ) {
			$diag = $temp;
			$xs   = $xe1;
			$ys   = $ye1;
			$xe   = $xe2;
			$ye   = $ye2;
		}

		print( "diag: " . $diag . "\n" );

		# usunac zanaczone linie
		# $genesis->COM('sel_delete');

		# teraz wstawic linie laczaca
		$genesis->COM(
			'add_line',
			attributes    => 'no',
			xs            => $xs,
			ys            => $ys,
			xe            => $xe,
			ye            => $ye,
			symbol        => 'r151',
			polarity      => 'positive',
			bus_num_lines => 1,
			bus_dist_by   => 'pitch',
			bus_distance  => 0,
			bus_reference => 'left'
		);

		# Un-selects all the features in all the affected layers.
		$genesis->COM('sel_clear_feat');
		next;
	}

	# connect lines if they are perpendicular or slope cannot be calculated
	elsif (( $diffSlope != 0 )
		|| ( ( $xe1 - $xs1 ) == 0 )
		|| ( ( $xe2 - $xs2 ) == 0 ) )
	{
		print( "--> linie prostopadle" . "\n" );

		$genesis->COM(
			'sel_intersect_best',
			function        => 'find_connect',
			mode            => 'corner',
			radius          => 0,
			length_x        => 0,
			length_y        => 0,
			type_x          => 'length',
			type_y          => 'length',
			show_all        => 'no',
			keep_remainder1 => 'no',
			keep_remainder2 => 'no',
			ang_x           => 0,
			ang_y           => 0
		);
		if ( $genesis->{STATUS} != 0 ) {
			print("Error in 'sel_intersect_best' - Script exits.");
			exit(0);
		}

		next;
	}

	# jak polonczylem, to nastepna para a nie czasem intersect
	$genesis->COM('sel_clear_feat');
	next;

}    # end of for-loop

$genesis->VON;

print(" ---------- Koniec programa ------------ \n");

## policz wybrane luki (arcs)
#$genesis->INFO(
#	entity_type => 'layer',
#	entity_path => "$job_name/$myStep/$myLayer",
#	data_type   => 'FEAT_HIST',
#	parameters  => "total",
#	options     => "select"
#);
#
#my $mySelFeatures = $genesis->{doinfo}{gFEAT_HISTtotal};
#

# nie ma zadnych duplikatow po uzyciu 'profile_to_rout'!
# $genesis->COM('sel_clear_feat');
#my $rs = checkDuplicate( \@data );
#print( "rs: " . $rs . "\n" );
#exit(0);

# otworz stepa pcb
#$genesis->COM(
#	'open_entity',
#	job    => $job_name,
#	type   => "step",
#	name   => $myStep,
#	iconic => "no"
#);

# teraz sprawdzic czy rownolegle dla X i dla Y
# gdy xs2 - xs1 == xe2 - xe1

#	if (
#		(
#			$mySelection{'xs2'} - $mySelection{'xs1'} ==
#			$mySelection{'xe2'} - $mySelection{'xe1'}
#		)
#		|| ( $mySelection{'xs1'} - $mySelection{'xs2'} ==
#			$mySelection{'xe2'} - $mySelection{'xe1'} )
#		|| ( $mySelection{'ys2'} - $mySelection{'ys1'} ==
#			$mySelection{'ye2'} - $mySelection{'ye1'} )
#		|| ( $mySelection{'ys1'} - $mySelection{'ys2'} ==
#			$mySelection{'ye2'} - $mySelection{'ye1'} )
#	  )
#	{

#		print( 'xe1: ' . $mySelection{'xe1'} . "\t" );
#		print( 'ye1: ' . $mySelection{'ye1'} . "\t" );
#		print( 'xs1: ' . $mySelection{'xs1'} . "\t" );
#		print( 'ys1: ' . $mySelection{'ys1'} . "\n" );
#
#		print( 'xe2: ' . $mySelection{'xe2'} . "\t" );
#		print( 'ye2: ' . $mySelection{'ye2'} . "\t" );
#		print( 'xs2: ' . $mySelection{'xs2'} . "\t" );
#		print( 'ys2: ' . $mySelection{'ys2'} . "\n" );

# na razie widze ze sie wykonujom tylko kejsy 3 i 7

# exit(0);

#print("lines are parallel!  \n");

#exit(0);

# }    # koniec if (sprawdzenie czy rownolegle)

# jak nic nie wybrano to next
#	$mySelFeatures = $genesis->COM ('get_select_count');
#	if ($mySelFeatures == 0) {
#		next;
#	}

#exit(0);

#####################
# teraz sprawdzic czy rownolegle dla X i dla Y - drugie podejscie
# slope = (Y2 - Y1)/(X2 - X1)

# 1. linia (el)
#	my $xs1 = $mySelection{'xs1'};
#	my $ys1 = $mySelection{'ys1'};
#
#	my $xe1 = $mySelection{'xe1'};
#	my $ye1 = $mySelection{'ye1'};
#
#	print( 'lx1: ' . $xs1 . "\t" );
#	print( 'ly1: ' . $ys1 . "\t" );
#	print( 'lx2: ' . $xe1 . "\t" );
#	print( 'ly2: ' . $ye1 . "\n" );

# y-intercept: punkt przeciecia z osia
# slope: nachylenie, spadek

# 2. linia (er)
#	my $xs2 = $mySelection{'xs2'};
#	my $ys2 = $mySelection{'ys2'};
#
#	my $xe2 = $mySelection{'xe2'};
#	my $ye2 = $mySelection{'ye2'};
#
#	print( 'rx1: ' . $xs2 . "\t" );
#	print( 'ry1: ' . $ys2 . "\t" );
#	print( 'rx2: ' . $xe2 . "\t" );
#	print( 'ry2: ' . $ye2 . "\n" );

#	my $slopeL = ( $ye1 - $ys1 ) / ( $xe1 - $xs1 );
#	print( "slopeL: " . $slopeL . "\n" );
#
#	my $slopeR = ( $ye2 - $ys2 ) / ( $xe2 - $xs2 );
#	print( "slopeR: " . $slopeR . "\n" );

#com->get_message_bar
####################

#	print( $mySelection{'xs1'} . "\t" );
#	print( $mySelection{'ys1'} . "\t" );
#	print( $mySelection{'xe1'} . "\t" );
#	print( $mySelection{'ye1'} . "\n" );

# clear selection
# $genesis->COM('sel_clear_feat');

# gdy radius > 2mm to split arc to lines
# a gdy mniejszy to usunac

# [1]: #A 125.5503975 0 120.049565 0 122.8 0 r101 P 0 N
# (x)122.8  (y)0 to ark center

#my @myRow;
#my $myDiameter;
#for ( my $j = 1 ; $j <= $#smallArcs ; $j++ ) {
#	@myRow = split / /, $smallArcs[$j];
#
#	# check X
#	$myDiameter = abs( $myRow[3] - $myRow[1] );
#
#	# or check Y
#	if ( $myDiameter == 0 ) {
#		$myDiameter = abs( $myRow[4] - $myRow[2] );
#	}
#
#	print $myDiameter . "\n";
#
#	# usuwa zaznaczone arki
#	if ( $myDiameter < 2 ) {
#		$genesis->COM('sel_delete');
#	}
#	else {
#  # Breaks an arc to lines according to a tolerance value specified by the user.
#		$genesis->COM( 'arc2lines', arc_line_tol => 906 );
#	}
#}

## $$ is the process ID (PID)
#my $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";
#
#my $myEntity = "$job_name/$myStep/aoi_profile";
#
## daj info o zaznaczonych elementach
#$genesis->INFO(
#	units       => "mm",
#	entity_type => "layer",
#	entity_path => $myEntity,
#	data_type   => "FEATURES",
#	options     => "select"
#);
#
#my $fh;
#my $myStatus = open( $fh, $csh_file );
#
## check read status
#if ( !defined $myStatus ) {
#	print( "$!: $csh_file \n", 'errorline' );
#	exit(0);
#}
#
#my @smallArcs = <$fh>;
#close($fh);
#unlink $csh_file;
#
## print ("#data: " . $#smallArcs  . "\n");
#showArray( \@smallArcs );

# display_text
# display_text_file

# znalezc skrajne punkty
# $xs1 $xe1 $xs2 $xe2
# $ys1 $ye1 $ys2 $ye2

#	# gorny prawy rog
#	my $xmax = $xs1;
#	if ( $xe1 > $xmax ) {
#		$xmax = $xe1;
#	}
#	elsif ( $xs2 > $xmax ) {
#		$xmax = $xs2;
#	}
#	elsif ( $xe2 > $xmax ) {
#		$xmax = $xe2;
#	}
#
#	my $ymax = $ys1;
#	if ( $ye1 > $ymax ) {
#		$ymax = $ye1;
#	}
#	elsif ( $ys2 > $ymax ) {
#		$ymax = $ys2;
#	}
#	elsif ( $ye2 > $ymax ) {
#		$ymax = $ye2;
#	}
#
#	print( "xmax: " . $xmax . "\t" );
#	print( "ymax: " . $ymax . "\n" );
#
#	# dolny lewy rog
#	my $xmin = $xs1;
#	if ( $xs1 < $xmin ) {
#		$xmin = $xs1;
#	}
#	elsif ( $xe1 < $xmin ) {
#		$xmin = $xe1;
#	}
#	elsif ( $xs2 < $xmin ) {
#		$xmin = $xs2;
#	}
#	elsif ( $xe2 < $xmin ) {
#		$xmin = $xe2;
#	}
#
#	my $ymin = $ys1;
#	if ( $ys1 < $ymin ) {
#		$ymin = $ys1;
#	}
#	elsif ( $ye1 < $ymin ) {
#		$ymin = $ye1;
#	}
#	elsif ( $ys2 < $ymin ) {
#		$ymin = $ys2;
#	}
#	elsif ( $ye2 < $ymin ) {
#		$ymin = $ye2;
#	}
#
#	print( "xmin: " . $xmin . "\t" );
#	print( "ymin: " . $ymin . "\n" );

#COM sel_reverse
#COM sel_delete

#		print( $xs1 . " \/ " );
#		print( $ys1 . "\t" );
#		print( $xe1 . " \/ " );
#		print( $ye1 . "\t" );
#
#		print( $xs2 . " \/ " );
#		print( $ys2 . "\t" );
#		print( $xe2 . " \/ " );
#		print( $ye2 . "\n" );

#		my $xNear = $diffLx1Rx1;
#		if ( $diffLx1Rx2 < $xNear ) {
#			$xNear = $diffLx1Rx2;
#		}
#		elsif ( $diffLx2Rx1 < $xNear ) {
#			$xNear = $diffLx2Rx1;
#		}
#		elsif ( $diffLx2Rx2 < $xNear ) {
#			$xNear = $diffLx2Rx2;
#		}
#		print( 'xNear: ' . $xNear . "\n" );

#		my $yNear = $diffLy1Ry1;
#		if ( $diffLy1Ry2 < $yNear ) {
#			$yNear = $diffLy1Ry2;
#		}
#		elsif ( $diffLy2Ry1 < $yNear ) {
#			$yNear = $diffLy2Ry1;
#		}
#		elsif ( $diffLy2Ry2 < $yNear ) {
#			$yNear = $diffLy2Ry2;
#		}
#		print( 'yNear: ' . $yNear . "\n" );

#		#$genesis->COM('enhcont_chamfer_sel_corner');
#
#		if ( $mySelection{'xs1'} < $cx ) {
#
#			# laczyc z prawej
#		}
#		else {
#			# laczyc z lewej
#		}
#
#		print " ---> Program exits. \n";
#		exit(0);

#		if ( $mySelection{'xs1'} > $mySelection{'xs2'} ) {
#			$xs = $mySelection{'xs1'};
#			$ys = $mySelection{'ys1'};
#			$xe = $mySelection{'xe2'};    #zle
#			$ye = $mySelection{'ye2'};
#
#		}
#		else {
#			$xs = $mySelection{'xs2'};
#			$ys = $mySelection{'ys2'};
#			$xe = $mySelection{'xe1'};
#			$ye = $mySelection{'ye1'};

#		}

#		print( "xs: " . $xs . "\t" );
#		print( "ys: " . $ys . "\t" );
#		print( "xe: " . $xe . "\t" );
#		print( "ye: " . $ye . "\n" );

#		$genesis->COM(
#			'add_line',
#			attributes    => 'no',
#			xs            => $xs,
#			ys            => $ys,
#			xe            => $xe,
#			ye            => $ye,
#			symbol        => 'r151',
#			polarity      => 'positive',
#			bus_num_lines => 1,
#			bus_dist_by   => 'pitch',
#			bus_distance  => 0,
#			bus_reference => 'left'
#		);

#	# linie rownlegle
#	if ( $myLengthX1 == 0 && $myLengthX2 == 0 ) {
#		print("oba X sa 0 - linie pionowe \n");
#
#		if ( $mySelection{'ys1'} == $mySelection{'ys2'} ) {
#			print("case v1  \n");
#		}
#
#		elsif ( $mySelection{'ys1'} == $mySelection{'ye2'} ) {
#			print("case v2  \n");
#		}
#
#		elsif ( $mySelection{'ye1'} == $mySelection{'ys2'} ) {
#			print("case v3  \n");
#
#			$xs = $mySelection{'xe1'};
#			$ys = $mySelection{'ye1'};
#
#			$xe = $mySelection{'xs2'};
#			$ye = $mySelection{'ys2'};
#		}
#
#		elsif ( $mySelection{'ye1'} == $mySelection{'ye2'} ) {
#			print("case v4  \n");
#		}
#	}
#
#	# linie poziome
#	elsif ( $myLengthY1 == 0 && $myLengthY2 == 0 ) {
#
#		# ktory koniec mozna polaczyc?
#		if ( $mySelection{'xs1'} == $mySelection{'xs2'} ) {
#			print("case h1  \n");
#		}
#
#		elsif ( $mySelection{'xs1'} == $mySelection{'xe2'} ) {
#			print("case h2  \n");
#
#			$xs = $mySelection{'xe2'};
#			$ys = $mySelection{'ye2'};
#
#			$xe = $mySelection{'xs1'};
#			$ye = $mySelection{'ys1'};
#		}
#
#		elsif ( $mySelection{'xe1'} == $mySelection{'xs2'} ) {
#			print("case h3  \n");
#
#			$xs = $mySelection{'xs2'};
#			$ys = $mySelection{'ys2'};
#
#			$xe = $mySelection{'xe1'};
#			$ye = $mySelection{'ye1'};
#
#		}
#
#		elsif ( $mySelection{'xe1'} == $mySelection{'xe2'} ) {
#			print("case h4  \n");
#
#			$xs = $mySelection{'xe2'};
#			$ys = $mySelection{'ye2'};
#
#			$xe = $mySelection{'xs2'};
#			$ye = $mySelection{'ys2'};
#
#		}
#
#		$genesis->COM(
#			'add_line',
#			attributes    => 'no',
#			xs            => $xs,
#			ys            => $ys,
#			xe            => $xe,
#			ye            => $ye,
#			symbol        => 'r151',
#			polarity      => 'positive',
#			bus_num_lines => 1,
#			bus_dist_by   => 'pitch',
#			bus_distance  => 0,
#			bus_reference => 'left'
#		);
#	}
#
#	# linie pod skosem
#	else {
#		$genesis->COM(
#			'sel_intersect_best',
#			function        => 'find_connect',
#			mode            => 'corner',
#			radius          => 0,
#			length_x        => 0,
#			length_y        => 0,
#			type_x          => 'length',
#			type_y          => 'length',
#			show_all        => 'no',
#			keep_remainder1 => 'no',
#			keep_remainder2 => 'no',
#			ang_x           => 0,
#			ang_y           => 0
#		);
#		if ( $genesis->{STATUS} != 0 ) {
#			print("Error in 'sel_intersect_best' - Script exits.");
#			exit(0);
#		}
#
#		# exit(0);
#	}

################
#		# dla X:
#		if (   ( $diffLx1Rx1 < $diffLx1Rx2 )
#			&& ( $diffLx1Rx1 < $diffLx2Rx1 )
#			&& ( $diffLx1Rx1 < $diffLx2Rx2 ) )
#		{
#			$xs = $xs1;
#			$xe = $xs2;
#		}
#		elsif (( $diffLx1Rx2 < $diffLx1Rx1 )
#			&& ( $diffLx1Rx2 < $diffLx2Rx1 )
#			&& ( $diffLx1Rx2 < $diffLx2Rx2 ) )
#		{
#			$xs = $xs1;
#			$xe = $xe2;
#		}
#		elsif (( $diffLx2Rx1 < $diffLx1Rx1 )
#			&& ( $diffLx2Rx1 < $diffLx1Rx2 )
#			&& ( $diffLx2Rx1 < $diffLx2Rx2 ) )
#		{
#			$xs = $xe1;
#			$xe = $xs2;
#		}
#		elsif (( $diffLx2Rx2 < $diffLx1Rx1 )
#			&& ( $diffLx2Rx2 < $diffLx1Rx2 )
#			&& ( $diffLx2Rx2 < $diffLx2Rx1 ) )
#		{
#			$xs = $xe1;
#			$xe = $xe2;
#		}
#
#		# i dla Y:
#		if (   ( $diffLy1Ry1 < $diffLy1Ry2 )
#			&& ( $diffLy1Ry1 < $diffLy2Ry1 )
#			&& ( $diffLy1Ry1 < $diffLy2Ry2 ) )
#		{
#			$ys = $ys1;
#			$ye = $ys2;
#		}
#		elsif (( $diffLy1Ry2 < $diffLy1Ry1 )
#			&& ( $diffLy1Ry2 < $diffLy2Ry1 )
#			&& ( $diffLy1Ry2 < $diffLy2Ry2 ) )
#		{
#			$ys = $ys1;
#			$ye = $ye2;
#		}
#		elsif (( $diffLy2Ry1 < $diffLy1Ry1 )
#			&& ( $diffLy2Ry1 < $diffLy1Ry2 )
#			&& ( $diffLy2Ry1 < $diffLy2Ry2 ) )
#		{
#			$ys = $ye1;
#			$ye = $ys2;
#
#		}
#		elsif (( $diffLy2Ry2 < $diffLy1Ry1 )
#			&& ( $diffLy2Ry2 < $diffLy1Ry2 )
#			&& ( $diffLy2Ry2 < $diffLy2Ry1 ) )
#		{
#			$ys = $ye1;
#			$ye = $ye2;
#		}

##############

#			$temp = sqrt(($diffLx1Rx1 * $diffLx1Rx1) + ($diffLy1Ry2 * $diffLy1Ry2));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xs1;
#			$ys = $ys1;
#			$xe = $xs2;
#			$ye = $ye2;
#			print ("case5\n");
#		}
#
#		$temp = sqrt(($diffLx1Rx2 * $diffLx1Rx2) + ($diffLy1Ry2 * $diffLy1Ry2));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xs1;
#			$ys = $ys1;
#			$xe = $xe2;
#			$ye = $ye2;
#			print ("case6\n");
#		}
#
#		$temp = sqrt(($diffLx2Rx1 * $diffLx2Rx1) + ($diffLy1Ry2 * $diffLy1Ry2));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xe1;
#			$ys = $ys1;
#			$xe = $xs2;
#			$ye = $ye2;
#			print ("case7\n");
#		}
#
#		$temp = sqrt(($diffLx2Rx2 * $diffLx2Rx2) + ($diffLy1Ry2 * $diffLy1Ry2));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xe1;
#			$ys = $ys1;
#			$xe = $xe2;
#			$ye = $ye2;
#			print ("case8\n");
#		}
#
#		$temp = sqrt(($diffLx1Rx1 * $diffLx1Rx1) + ($diffLy2Ry1 * $diffLy2Ry1));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xs1;
#			$ys = $ye1;
#			$xe = $xs2;
#			$ye = $ys2;
#			print ("case9\n");
#		}
#
#		$temp = sqrt(($diffLx1Rx2 * $diffLx1Rx2) + ($diffLy2Ry1 * $diffLy2Ry1));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xs1;
#			$ys = $ye1;
#			$xe = $xe2;
#			$ye = $ys2;
#			print ("case10\n");
#		}
#
#		$temp = sqrt(($diffLx2Rx1 * $diffLx2Rx1) + ($diffLy2Ry1 * $diffLy2Ry1));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xe1;
#			$ys = $ye1;
#			$xe = $xs2;
#			$ye = $ys2;
#			print ("case11\n");
#		}
#
#		$temp = sqrt(($diffLx2Rx2 * $diffLx2Rx2) + ($diffLy2Ry1 * $diffLy2Ry1));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xe1;
#			$ys = $ye1;
#			$xe = $xe2;
#			$ye = $ys2;
#			print ("case12\n");
#		}
#
#		$temp = sqrt(($diffLx1Rx1 * $diffLx1Rx1) + ($diffLy2Ry2 * $diffLy2Ry2));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xs1;
#			$ys = $ye1;
#			$xe = $xs2;
#			$ye = $ye2;
#			print ("case13\n");
#		}
#
#		$temp = sqrt(($diffLx1Rx2 * $diffLx1Rx2) + ($diffLy2Ry2 * $diffLy2Ry2));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xs1;
#			$ys = $ye1;
#			$xe = $xe2;
#			$ye = $ye2;
#			print ("case14\n");
#		}
#
#		$temp = sqrt(($diffLx2Rx1 * $diffLx2Rx1) + ($diffLy2Ry2 * $diffLy2Ry2));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xe1;
#			$ys = $ye1;
#			$xe = $xs2;
#			$ye = $ye2;
#			print ("case15\n");
#		}
#
#		$temp = sqrt(($diffLx2Rx2 * $diffLx2Rx2) + ($diffLy2Ry2 * $diffLy2Ry2));
#		if ($temp < $diag) {
#			$diag = $temp;
#			$xs = $xe1;
#			$ys = $ye1;
#			$xe = $xe2;
#			$ye = $ye2;
#			print ("case16\n");
#		}
#

#a=1.091
#b=1.3
#c=1.697

# aoi_profile,#23,Line,XS=8.7690575,YS=102.569135,XE=8.87368,YE=103.7648025,r101,POS,Ang=-85
# aoi_profile,#25,Line,XS=7.7828,YS=105.0646825,XE=9.52692,YE=125,r101,POS,Ang=-85

# diag: 1.45478882041347	- kucha!
# add_line: 	xs: 8.87368 / ys: 103.7648025	xe: 9.52692 / ye: 105.0646825

# obliczac przekontnom pomiedzy liniami
# (a * a) + (b * b) = (c * c)
# c = sqrt ((a * a) + (b * b))

####################

#		print("add_line: \t");
#		print( "xs: " . $xs . " \/ " );
#		print( "ys: " . $ys . "\t" );
#		print( "xe: " . $xe . " \/ " );
#		print( "ye: " . $ye . "\n" );

# taki myk zeby program zatrzymal sie gdzie chcem
#		if ($j == 8) {
#			#exit(0);
#		}
#
