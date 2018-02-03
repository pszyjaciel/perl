#!/Perl/bin/perl -w 

# 206/332

# ->measure

use Genesis;
$genesis = new Genesis;

my @rs = $genesis->COM(
	'measure',
	'x1'   => 40.4,        # 35 / 25.4 = 1.378
	'y1'   => 45.7,        # 55 / 25.4 = 2.165"
	'x2'   => 40.9,
	'y2'   => 45.7,
	'mode' => 'midpoint'   # Values: point, net, contour, midpoint, annular ring
);

@rs = $genesis->{READANS};
print @rs;

print( "--> rs: " . $rs . "\n" );
print( "--> rs: " . $rs[0] . "\n" );
print( "--> rs: " . $rs[1] . "\n" );

@rs = $genesis->{COMANS};
print @rs;

print( "--> rs: " . $rs . "\n" );

$rs = $genesis->{COMANS}[0];
print( "--> rs: " . $rs . "\n" );

$rs = $genesis->{COMANS}[1];
print( "--> rs: " . $rs . "\n" );

#my $rs = $genesis->{READANS}[1];
#print( "--> rs: " . $rs . "\n" );

my $gDX = $genesis->{gDX};
print( "--> gDX: " . $gDX . "\n" );

$gDX = $genesis->{gDX};
print( "--> gDX: " . $gDX . "\n" );

$gDY = $genesis->{gDY};
print( "--> gDY: " . $gDY . "\n" );

$gD = $genesis->{gD};
print( "--> gD: " . $gD . "\n" );

my $gDX2 = $genesis->{COMANS}{gDX};
print( "--> gDX2: " . $gDX2 . "\n" );

$gDX2 = $genesis->{COMANS}{DX};
print( "--> gDX2: " . $gDX2 . "\n" );

$gDX = $genesis->{COMANS}{DX}[0];
print( "--> gDX: " . $gDX . "\n" );

$gDX = $genesis->{COMANS}{DX}[1];
print( "--> gDX: " . $gDX . "\n" );

$gDX = $genesis->{DX}[0];
print( "--> gDX: " . $gDX . "\n" );

$gDX = $genesis->{DX}[1];
print( "--> gDX: " . $gDX . "\n" );



# pan_feat,layer=top,index=2455,auto_zoom=yes (0)

# sel_layer_feat

# COM sel_layer_feat,operation=select,layer=rout_features,index=$count

#$genesis->COM(
#	'sel_layer_feat',
#	operation => 'select',
#	layer     => 'top',
#	index     => 2456
#);

# wyswietla drill-tool-managera 
#$genesis->COM(
#	'tools_show',
#	layer     => 'drill'
#);


#$gDX = $genesis->{gDX}[1];
#print( "--> gDX: " . $gDX . "\n" );

#my $gDX = $genesis->{gDX};
#print( "--> gDX: " . $gDX . "\n" );

#my $gDX = $genesis->{gDX};
#print( "--> gDX: " . $gDX . "\n" );

#my $status = $genesis->{STATUS};
#print( "--> status: " . $status . "\n" );
#
#$rs = $genesis->{COMANS};
#print( "--> rs: " . $rs . "\n" );

###########
#$genesis->COM('get_user_name');
#my $USER = uc $genesis->{COMANS};    # uc to uppercase
#print( "--> USER: " . $USER . "\n" );
#
#my $myGroup;
#$myGroup = $genesis->COM('get_user_group');
#print( "--> myGroup: " . $myGroup . "\n" );
#$myWorkLayer = $genesis->COM('get_work_layer');
#print( "--> myWorkLayer: " . $myWorkLayer . "\n" );

# reread_layer
