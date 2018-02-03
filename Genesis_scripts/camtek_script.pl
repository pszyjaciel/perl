#!/usr/bin/perl -w

# docs:
# 206/65
# 705/22

# INSPECTION_HEIGHT_MAXIMUM = 22000 (558.8mm)
# INSPECTION_WIDTH_MAXIMUM  = 26000 (660.4mm)

# camtek_scan_area(mode, margin, x1, y1, x2, y2, step);

# Parameter Value
# mode Auto - take the bounding limits of the step & repeat
# Manual - specify coordinates
# margin In mils/microns - for ‘auto’
# x1,y1,x2,y
# 2
# Rectangle corners
# step Existing step name or ‘*’

#---------------
#camtek_exclusion, oper => 'set', mode => 'manual', margin => 0,

use Genesis;

$genesis = new Genesis;

# $genesis->COM( 'stk_select', all => 'yes' );
$genesis->COM('camtek_open');

#$genesis->COM('camtek_units', units => 'inch');
#$genesis->COM(
#	'camtek_scan_area',
#	mode   => 'manual',
#	margin => 0,
#	x1     => 35,		# 35 / 25.4 = 1.378
#	y1     => 55,		# 55 / 25.4 = 2.165"
#	x2     => 157,
#	y2     => 110,
#	step   => '*'
#);

# $genesis->COM('camtek_units', units => 'mm');
# $genesis->COM(
#	'camtek_scan_area',
#	mode   => 'manual',
#	margin => 0,
#	x1     => 35,		# 35 / 25.4 = 1.378mm
#	y1     => 55,		# 55 / 25.4 = 2.165mm
#	x2     => 157,
#	y2     => 110,
#	step   => '*'
#);

# 35/27mm

# 35 * 25.4 = 889
# 27 * 25.4 = 686

# 439 * 25.4 = 11151
# 599 * 25.4 = 15215

#$genesis->COM('camtek_units', units => 'mm');
#$genesis->COM(
#	'camtek_scan_area',
#	'mode'   => 'manual',
#	'margin' => 0,
#	'x1'     => 889,
#	'y1'     => 686,
#	'x2'     => 11115,
#	'y2'     => 14879,		# maximum
#	'step'   => 'ark'
#);

# 17.27 * 25.4 = 439
# 23.6 * 25.4 = 600

# doc: 204/28
print( "status: " . $genesis->{STATUS} . "\n" );
print( "job: " . $genesis->{JOB} . "\n" );
print( "step: " . $genesis->{STEP} . "\n" );

#$genesis->VOF;
#$genesis->COM( 'camtek_delete', name => 'myset1' );
#$rs = $genesis->{STATUS};
#if ( $rs != 0 ) {
#	print( "2. kucha: " . $genesis->{STATUS} . "\n" );
#}
#$genesis->VON;

$genesis->COM(
	'camtek_set_cur',
	job   => '777x0488.1701',
	step  => 'panel',
	layer => 'top',
	name  => 'myset1'
);

#$genesis->COM( 'camtek_create', name => 'myset1' );
#my $rs = $genesis->{STATUS};
#if ( $rs != 0 ) {
#	print( "0. kucha: " . $genesis->{STATUS} . "\n" );
#}

$genesis->COM(
	'camtek_params',
	'angle'     => 90,
	'mirror'    => 'no',
	'polarity'  => 'positive',
	'x_scale'   => 1,
	'y_scale'   => 1,
	'drills'    => 'yes',
	'etch'      => 0,
	'calib'     => 'H0',
	'res'       => 0.25,
	'thickness' => 1618,
	'lam_type'  => 'Foil',
	'machine'   => 'Panel'
);

#$genesis->COM(
#	'set_attribute',
#	type      => 'camtek-aoiset',
##	job       => 'bknaoi',
##	name1     => 'panel',
##	name2     => 'bknaoi.1',
##	name3     => 'up',
#	attribute => 'design',
#	value     => 'signal'
#);

$genesis->COM( 'camtek_units', units => 'mm' );

#$genesis->COM(
#	'camtek_scan_area',
#	'mode'   => 'automatic',
#	'margin' => 0,
#	'x1'     => 0,
#	'y1'     => 0,
#	'x2'     => 0,
#	'y2'     => 0,
#	'step'   => 'panel'
#);

# INSPECTION_HEIGHT_MAXIMUM = 22000 (558.8mm)
# INSPECTION_WIDTH_MAXIMUM  = 26000 (660.4mm)

$genesis->COM(
	'camtek_scan_area',
	'mode'   => 'manual',
	'margin' => 0,
	'x1'     => 26,
	'y1'     => 32,
	'x2'     => 598,
	'y2'     => 438,
	'step'   => 'panel'
);

$genesis->COM( camtek_exclusion,
	oper   => 'set',
	mode   => 'manual',
	margin => 0,
	x1     => 26,
	y1     => 141,
	x2     => 600,
	y2     => 155
);
$genesis->COM( camtek_exclusion,
	oper   => 'set',
	mode   => 'manual',
	margin => 0,
	x1     => 457,
	y1     => 243,
	x2     => 600,
	y2     => 454
);

#$genesis->COM('camtek_exclusion_poly_start');
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 50, 'y' => 75 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 57, 'y' => 72 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 65, 'y' => 70 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 70, 'y' => 70 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 80, 'y' => 65 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 85, 'y' => 60 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 85, 'y' => 55 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 80, 'y' => 55 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 80, 'y' => 50 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 75, 'y' => 55 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 75, 'y' => 45 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 70, 'y' => 55 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 65, 'y' => 50 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 65, 'y' => 55 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 60, 'y' => 50 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 55, 'y' => 50 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 50, 'y' => 55 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 45, 'y' => 55 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 50, 'y' => 65 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 55, 'y' => 60 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 60, 'y' => 60 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 60, 'y' => 65 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 57, 'y' => 65 );
#$genesis->COM(
#	'camtek_exclusion_poly_close',
#	oper   => 'set',
#	mode   => 'semi_automatic',
#	margin => 0
#);

#$genesis->COM('camtek_exclusion_poly_start');
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 65, 'y' => 61 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 70, 'y' => 65 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 75, 'y' => 61 );
#$genesis->COM( 'camtek_exclusion_poly_add_vertex', 'x' => 70, 'y' => 58 );
#$genesis->COM(
#	'camtek_exclusion_poly_close',
#	oper   => 'set',
#	mode   => 'semi_automatic',
#	margin => 0
#);

#122/100

my $xc = 120;
my $yc = 140;

for ( my $i = 1 ; $i < 20 ; $i++ ) {
	$genesis->COM(
		'camtek_exclusion_circle',
		oper   => 'set',
		mode   => 'semi_automatic',
		margin => 100,
		xc     => $xc + ($i * 5),
		yc     => $yc + ($i * 5),
		rad    => 3
	);
}

$yc = 30;
for ( my $i = 1 ; $i < 80 ; $i++ ) {
	$genesis->COM(
		'camtek_exclusion_circle',
		oper   => 'set',
		mode   => 'semi_automatic',
		margin => 100,
		xc     => 115,
		yc     => $yc + ($i * 3),
		rad    => 2
	);
}


#oper    set - defined zone delete - delete a zone clear - delete all zones
#mode    auto - sets areas between the the s&r and the scan area semi_automatic - rectangle corners are duplicated to all S&R manual - specify coordinates
#margin   mils/microns   from the s&r
#xc,yc,rad      circle center & rad

