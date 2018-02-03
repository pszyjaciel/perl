
#$f->VOF;
#$STATUS = $f->COM( open_job, job => $job_name );
#if ( $STATUS != 0 ) {
#	#$f->PAUSE('Job does not exist.');
#	print ("1. status: $STATUS \n");
#	exit(0);
#}
#else {
#	#print ('Job already opened. The status is $STATUS');
#	$test = 10;
#	#$f->PAUSE("??? Job already opened. The status is $test");
#	print ("2. status: $test \n");
#}


############################# smietnik ########################
#$f->COM(
#	'open_entity',
#	job    => "$job_name",
#	type   => "step",
#	name   => "$step_name",
#	iconic => "no"
#);

#$f->INFO(
#	'units'       => "mm",
#	'entity_type' => 'layer',
#	'entity_path' => "$job_name/panel/$layer_name",
#	'data_type'   => 'TOOL',
#	'parameters'  => 'type2',
#	'options'     => 'break_sr'
#);
#
#my $press_count = grep /press_fit/, @{ $f->{doinfo}{gTOOLtype2} };
#print $press_count . "\n";

#my @result = $f->INFO(
#	units       => 'mm',
#	entity_type => 'layer',
#
#	#entity_path => "777x0488.1701/xray/il2p",
#	entity_path => $my_entity_path,
#	data_type   => 'FEATURES'
#);
#
#print( $f->{STATUS} . "\n" );

# tworzy plik pomocy dla komendy info:
#COM info, out_file=/tmp/info , write_mode=replace, args= -help
#$f->COM(
#	'info',
#	out_file => 'c:/help_fajl.txt',
#	args => '-help'
#);

# pacz tu: c:\genesis\help\pdf\0204\0204.pdf  str. 50
#COM info,out_file=/tmp/example,args= -t job -e e.demo.z01 -d symbols_list
#$f->COM(
#	'info',
#	out_file => 'c:/symbols_list.txt',
#	args => '-t job -e 777x0488.1701/xray/il2p -d symbols_list'
#);

# zapisuje plika ze wszystkimi jobami w bazie genesisa:
#COM info,out_file=/tmp/example,args= -t root
#$f->COM(
#	'info',
#	out_file => 'c:/genesis_database.txt',
#	args => '-t root'
#);

#$layer_name = 'top';

#DO_INFO_MM -t layer -e $JOB/panel/top -d ATTR
#$f->INFO(
#	units       => 'mm',
#	entity_type => 'layer',
#	entity_path => "$job_name/$step_name/$layer_name",
#	data_type   => 'ATTR'
#);

#my @gATTRname = @{ $f->{doinfo}{gATTRname} };
#my @gATTRval  = @{ $f->{doinfo}{gATTRval} };
#for ( my $i = 0 ; $i < $#gATTRname ; $i++ ) {
#
#	#print( $gATTRname[$i] . "\t" . $gATTRval[$i] . "\n" );
#}

############

#DO_INFO_MM -t layer -e $JOB/panel/$LAYER

#$memUsage = $f->COM('memory_usage');
#print "memory_usage: $memUsage \n";

#$f->INFO(units => 'mm', entity_type => 'step', entity_path => "$job_name/$step_name", data_type => 'EXISTS');
#$f->INFO(
#	'units'         => 'mm',
#	'entity_type'   => 'step',
#	'entity_path'   => "$job_name/$step_name",
#	'output_method' => 'display',
#	'data_type'     => 'PROF_LIMITS'
#);

#my $panel_right  = $f->{doinfo}{gPROF_LIMITSxmax};
#my $panel_left   = $f->{doinfo}{gPROF_LIMITSxmin};
#my $panel_top    = $f->{doinfo}{gPROF_LIMITSymax};
#my $panel_bottom = $f->{doinfo}{gPROF_LIMITSymin};
#
#print( $panel_right . " : " . $panel_left . "\n" );

#$layer_name = 'il2p';

#$f->INFO(
#	units       => 'mm',
#	entity_type => 'layer',
#	entity_path => "$job_name/$step_name/$layer_name",
#	data_type   => 'SYMS_HIST'
#);

#set gSYMS_HISTsymbol = ('r300' 'r1015' 'xray_target')
#set gSYMS_HISTline   = ('4'    '0'     '0'          )
#set gSYMS_HISTpad    = ('0'    '2'     '1'          )
#set gSYMS_HISTarc    = ('0'    '0'     '0'          )

#my @gSYMS_HISTsymbol = @{ $f->{doinfo}{gSYMS_HISTsymbol} };
#foreach my $i (@gSYMS_HISTsymbol) {
##	print $i . "\n";
#}

#$step_name = "xray";
#
##DO_INFO_MM -t step -e $JOB/panel -d LAYERS_LIST
#$f->INFO(
#	units       => 'mm',
#	entity_type => 'step',
#	entity_path => "$job_name/$step_name",
#	data_type   => 'LAYERS_LIST'
#);
#
#my @gLAYERS_LIST = @{ $f->{doinfo}{gLAYERS_LIST} };
#my $gCONTEXT;
#my $gTYPE;
#my $gSIDE;
#my @myInnerLayers = ();
#
## lists the inner layers
#foreach my $myLayer (@gLAYERS_LIST) {
#	$f->INFO(
#		units       => 'mm',
#		entity_type => 'layer',
#		entity_path => "$job_name/$step_name/$myLayer"
#	);
#
#	$gCONTEXT = $f->{doinfo}{gCONTEXT};
#	$gSIDE    = $f->{doinfo}{gSIDE};
#	if ( ( $gCONTEXT eq 'board' ) && ( $gSIDE eq 'inner' ) ) {
#		push @myInnerLayers, $myLayer;
#	}
#}
#
#my @gSYMS_HISTsymbol;
#print $#myInnerLayers . " <----- \n";
#my %inspectaPads = ();
#
#for ( my $i = 0 ; $i <= $#myInnerLayers ; $i++ ) {
#	$f->INFO(
#		units       => 'mm',
#		entity_type => 'layer',
#		entity_path => "$job_name/$step_name/$myInnerLayers[$i]",
#		data_type   => 'SYMS_HIST'
#	);
#
#	@gSYMS_HISTsymbol = @{ $f->{doinfo}{gSYMS_HISTsymbol} };
#	foreach my $myFeature (@gSYMS_HISTsymbol) {
#		if ( $myFeature eq 'r1015' ) {
#
#			#print $myFeature . "\n";
#			push( @{ $inspectaPads{ $myInnerLayers[$i] } }, $myFeature );
#		}
#	}
#}
#
##display hash table
#foreach my $group ( keys %inspectaPads ) {
#	print "group: $group: ";
#	foreach my $myKey ( @{ $inspectaPads{$group} } ) {
#		print "myKey: $myKey\t";
#	}
#	print "\n";
#}

## funkcja zwraca tablice koordynatow dla danego elementu (item) na danej warstwie (layer)
## jak element nie wystepuje to tablica jest pusta
#sub getXY {
#	my $myItem = shift;
#	#my $myLayer = shift;
#	my $myEntityPath = shift;
#
#	# a co z ew. atrybutami?
#	#print $myItem . "\n";
#	#print $myEntityPath . "\n";
#
#	local $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";
#	local ($attribute) = 'fiducial_name';
#	my @myFeatures       = ();
#	my @mySplittedLine = ();
#
#	$f->INFO(
#		'entity_type' => 'layer',
#		'entity_path' => $myEntityPath,
#		'data_type'   => 'FEATURES',
#		#'options'     => "select",
#		'parse' => 'no'
#	);
#	my $k = 0;
#	my $x = 'x';
#	my $y = 'y';
#	open( CSHFILE, $csh_file ) or die " ---> 1. can not open file $csh_file: $!\n";
#	while ( $line = <CSHFILE> ) {
#		#next unless ( $line =~ /$attribute/ );
#		@mySplittedLine = split /\s/, $line;
#		#print @mySplittedLine;
#		$mySplittedLine[3] =~ s/^r//g;
#		if ( are_equal( $myItem, $mySplittedLine[3] ) == 1 ) {
#			$x = $x . $k;
#			$y = $y . $k;
#			push( @myFeatures, { $x => $mySplittedLine[1] } );
#			push( @myFeatures, { $y => $mySplittedLine[2] } );
#			$k++;
#			$x = 'x';
#			$y = 'y';
#		}
#	}
#	close(CSHFILE);
#	unlink $csh_file;
#	return @myFeatures;
#}

#sub getXY2 {
#	my $myItem = shift;
#	my $myEntityPath = shift;
#
#	# pacz tu: v:\linux_sys\perl\Genesis.pl
#	$f->INFO(
#		'entity_type' => 'layer',
#		'entity_path' => $myEntityPath,
#		'data_type'   => 'FEATURES',
#		#'options'     => "select",
#		'parse' => 'no'
#	);
#
#	local $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";
#	print("$ENV{GENESIS_TMP}/info_csh.$$");
#
#	local ($attribute) = 'nomenclature';
#
#	#local ($attribute) = 'fiducial_name';
#	my @features       = ();
#	my @mySplittedLine = ();
#
#	print "\n\n";
#
#	open( CSHFILE, $csh_file )
#	  or die " ---> 1. can not open file $csh_file: $!\n";
#	while ( $line = <CSHFILE> ) {
#		next unless ( $line =~ /$attribute/ );
#		@mySplittedLine = split /\s/, $line;
#		push( @features, { 'x' => $mySplittedLine[1] } );
#		push( @features, { 'y' => $mySplittedLine[2] } );
#	}
#	close(CSHFILE);
#
#	foreach $record (@features) {
#		for $key ( sort keys %$record ) {
#			print "$key: $record->{$key}\n";
#		}
#	}
#
#	print "\n\n";
#
###################### smietnik ###################
##COM info,args=-t layer -e dic.001.bini/pcb/olt -d FEATURES
##$f->COM( close_job, job => $job_name );
##my @var2 = $f->COM(
##	'info',
##	out_file => 'c:/FEATURES.txt',
##	args     => '-t layer -e 777x0488.1701/xray/il2p -m DISPLAY -d FEATURES'
##	  #args => '-t layer -e $my_entity_path -m SCRIPT -d FEATURES'		# nie dziala
##);
#
## 6. Data type = FEATURES (Free text output)
##    Options    : break_sr
##                 break_feat
##                 select
##                 feat_index
#
##$group = $f->openStep($job_name, $step_name);
##$f->selectFeatureByAttr($job_name, $step_name, $layer_name, $attribute);
#
##$f->PAUSE('Do you want to select anything?');
##$selCount = $f->COM('get_select_count');
##print "get_select_count: $selCount \n";
#
##$f->AUX( 'set_group', 'group' => 0 );
#
#
##local ($attribute) = 'nomenclature';
##local (@features);
##
##open( CSHFILE, $csh_file  ) or die " ---> 1. can not open file $csh_file: $!\n";
##while ( $line = <CSHFILE> ) {
##	#print $line;
##	next unless ( $line =~ /$attribute/ );
##	( $type, $xstart, $ystart, $xend, $yend, $symbol, $pol, $decode, $attr ) =
##	  ( $line =~
##/(\w+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\w\d.]+)\s+([\w])\s+([\d.]+)\s+;.(.*)$/
##	  );
##
##	#print "--> puszet. \n";
##	push(
##		@features,
##		{
##			'type'       => $type,
##			'xstart'     => $xstart,
##			'ystart'     => $ystart,
##			'xend'       => $xend,
##			'yend'       => $yend,
##			'symbol'     => $symbol,
##			'polarity'   => $pol,
##			'decode'     => $decode,
##			'attributes' => $attribute
##			  #'attributes' => [ split /,/, $attr ]
##		}
##	);
##}
##close(CSHFILE);
##unlink $csh_file;
##print $#features;
#
#}

#########

#my @cuInnerLayers = getCopperInnerLayers($job_name);
#my $myItemMM = 1015;    # <= change the size of item for searching
#
#my $inspectaPads = {};
#for ( my $i = 0 ; $i <= $#cuInnerLayers ; $i++ ) {
#	$f->INFO(
#		units       => 'mm',
#		entity_type => 'layer',
#		entity_path => "$job_name/$step_name/$cuInnerLayers[$i]",
#		data_type   => 'SYMS_HIST'
#	);
#
#	@gSYMS_HISTsymbol = @{ $f->{doinfo}{gSYMS_HISTsymbol} };
#	foreach my $myFeature (@gSYMS_HISTsymbol) {
#		if ( $myFeature eq ('r' . $myItemMM)  ) {
#			push( @{ $inspectaPads{ $cuInnerLayers[$i] } }, $myFeature );
#		}
#	}
#}
#
#my $inspectaPadsSize = keys %inspectaPads;
#if ($inspectaPadsSize == 0 ) {
#	print ("No such feature found on any cu-layer. Program exits.");
#	exit(0);
#}
#
##display hash table
#foreach my $key ( keys %inspectaPads ) {
#	print "key: $key: ";
#	foreach my $value ( @{ $inspectaPads{$key} } ) {
#		print "value: $value\t";
#	}
#	print "\n";
#}
#
#print $inspectaPads{'il2p'}[0] . "\n";
#print $inspectaPads{'il3p'}[0] . "\n";

#display hash table
#foreach my $group ( keys %inspectaSIPads ) {
#	print "$group ";
#	foreach my $myKey ( @{ $inspectaSIPads{$group} } ) {
#		print "$myKey\t";
#	}
#	print "\n";    # ma byc inaczej wywala genesisa
#}

#display keys
#my %layers = getMatrix($job_name);
#foreach $myKey ( keys %layers ) {
#	print "myKey: " . $myKey . "\n";
#}
########

# this functions returns a hash-array of coordinates for specified item on given layer
# if item not found then the array is empty (length -1)
#sub getXY2 {
#	my $myItem       = shift;
#	my $myEntityPath = shift;
#
#	#my $myAttributes = shift;			# not implemented yet
#
#	local $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";		# $$ is the process ID (PID)
#
#	# $myTab[0] : job
#	# $myTab[1] : step
#	# $myTab[2] : layer
#	my @myTab = split /\//, $myEntityPath;
#
#	#local ($attribute) = 'fiducial_name';
#	my $myFeatures     = {};
#	my @mySplittedLine = ();
#
#	@csh_file = $f->INFO(
#		'units'       => 'mm',
#		'entity_type' => 'layer',
#		'entity_path' => $myEntityPath,
#		'data_type'   => 'FEATURES',
#		'parse'       => 'no'
#	);
#	
#	open( CSHFILE, $csh_file )
#	  or die " ---> 1. can not open file $csh_file: $!\n";
#
#	while ( $line = <CSHFILE> ) {
#
#		#next unless ( $line =~ /$attribute/ );
#		@mySplittedLine = split /\s/, $line;
#		$mySplittedLine[3] =~ s/^r//g;
#		if ( are_equal( $myItem, $mySplittedLine[3] ) == 1 ) {
#			my @tempArray = ( $mySplittedLine[1], $mySplittedLine[2] );
#			$myFeatures{ $myTab[2] } =
#			  \@tempArray;    # i wstawiam tablice do hasza
#		}
#	}
#	close(CSHFILE);
#	unlink $csh_file;
#	return %myFeatures;
#}

# The DO_INFO shortcut: c:\genesis\help\pdf\0204\0204.pdf str. 49
#DO_INFO -t job -e $job_name -d STEPS_LIST
#As a result, the variable gSTEPS_LIST will be set automatically.


#sub getXY2 {
#	my $myItem       = shift;
#	my $myEntityPath = shift;
#
#	my $myAttribute = 'fiducial_name=inspecta';
#
#	# $$ is the process ID (PID)
#	local $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";
#
#	# $myTab[0] : job	# $myTab[1] : step	# $myTab[2] : layer
#	my @myTab = split /\//, $myEntityPath;
#
#	my $myFeatures     = {};
#	my @mySplittedLine = ();
#
#	@csh_file = $f->INFO(
#		'units'       => 'mm',
#		'entity_type' => 'layer',
#		'entity_path' => $myEntityPath,
#		'data_type'   => 'FEATURES',
#		'parse'       => 'no'
#	);
#
#	open( CSHFILE, $csh_file )
#	  or die " ---> 1. can not open file $csh_file: $!\n";
#
#	my @data = <CSHFILE>;
#	close(CSHFILE);
#	unlink $csh_file;
#
#	foreach my $line (@data) {
#		@mySplittedLine = split /\s/, $line;
#
#		# we remove the 'r' in the beginning of feature name
#		$mySplittedLine[3] =~ s/^r//g;
#		if ( are_equal( $myItem, $mySplittedLine[3] ) == 1 ) {
#
#			# don't care about the superimposed pad
#			if ( ( $mySplittedLine[1] == 0 ) && ( $mySplittedLine[2] == 0 ) ) {
#				next;
#			}
#			my @tempArray = ( $mySplittedLine[1], $mySplittedLine[2] );
#
#			# $myTab[2] is the layer name
#			$myFeatures{ $myTab[2] } = \@tempArray;
#		}
#	}
#	foreach $myKey ( sort keys %myFeatures ) {
#
#		#		print  $myKey . "\t";
#		#		print  $myFeatures {$myKey}[0] . "\t";
#		#		print  $myFeatures {$myKey}[1] . "\n";
#	}
#	return %myFeatures;
#}


#function returns coordinates of superimposed pads in a hash array
#sub getSIPads2 {
#
#	my $my_entity_path = shift;
#	my @myTab          = split /\//, $my_entity_path;
#	my $rs             = isStep( $myTab[0], $myTab[1] );    # job i step
#	if ( $rs == 0 ) {
#		print "Step $step_name does not exist. Program exits. \n";
#		exit(0);
#	}
#
#	print $my_entity_path . "\n";
#
#	$f->INFO(
#		units       => 'mm',
#		entity_type => 'step',
#		entity_path => "$job_name/$step_name",
#		data_type   => 'SR'
#	);
#
#	my @gSRstep = @{ $f->{doinfo}{gSRstep} };
#	my @gSRxa   = @{ $f->{doinfo}{gSRxa} };
#	my @gSRya   = @{ $f->{doinfo}{gSRya} };
#	my @gSRnx   = @{ $f->{doinfo}{gSRnx} };
#	my @gSRny   = @{ $f->{doinfo}{gSRny} };
#	my @gSRdx   = @{ $f->{doinfo}{gSRdx} };
#	my @gSRdy   = @{ $f->{doinfo}{gSRdy} };
#
#	print(  $#gSRstep . ":"
#		  . $#gSRxa . ":"
#		  . $#gSRya . ":"
#		  . $#gSRnx . ":"
#		  . $#gSRny . ":"
#		  . $#gSRdx . ":"
#		  . $#gSRdy
#		  . "\n" );
#
#	for ( my $i = 0 ; $i < $#gSRstep ; $i++ ) {
#		if ( $gSRstep[$i] eq 'xray' ) {
##			print(  "SRstep: $gSRstep[$i] \t"
##				  . "SRxa: $gSRxa[$i] \t"
##				  . "SRya: $gSRya[$i] \t"
##				  . "SRnx: $gSRnx[$i] \t"
##				  . "SRny: $gSRny[$i] \t" 
##				  . "SRdx: $gSRdx[$i] \t"
##				  . "SRdy: $gSRdy[$i] \n" )
##			  ;
#		}
#	}
#	
#	my $inspectaSIPads = {};                 # deklaracja hasz tabeli
#	my @myXrayKeys = ( 'TL', 'TR', 'BL', 'BR' );	# BL jest stepowany 2x w 'Y'
#	
#	for ( my $i = 0 ; $i < $#gSRstep ; $i++ ) {
#		if ( $gSRstep[$i] eq 'xray' ) {
#			# multi-step
#			if (( $gSRdx[$i] > 1 ) || ( $gSRdy[$i] > 1 )) {
#				
#				# zakladam ze sa TYLKO 4 stepy xray
#				# 1. zapisac jego koordynaty np. xa/ya: 55/66, nx/ny: 1/2, dx/dy: 0/494
#				
#				
#				#55/560 = 55+0/66+494 = 55 + ((1-1)*0) / ((2-1)*494)
#				# 2. nx+dx i ny * dy 
#				print(  "SRstep: $gSRstep[$i] \t"
#				  . "SRxa: $gSRxa[$i] \t"
#				  . "SRya: $gSRya[$i] \t"
#				  . "SRnx: $gSRnx[$i] \t"
#				  . "SRny: $gSRny[$i] \t" 
#				  . "SRdx: $gSRdx[$i] \t"
#				  . "SRdy: $gSRdy[$i] \n" )
#			  ;
#			}
#			#single-step
#			else {
#				
#			}
#		}
#	}
#
#
#	foreach my $myStep (@gSRstep) {
#
#		#print "myStep: $myStep \n";
#	}
#
#	foreach my $mySRxa (@gSRxa) {
#
#		#print "SRxa: $mySRxa \n";
#	}
#
#	foreach my $mySRya (@gSRya) {
#
#		#print "SRya: $mySRya \n";
#	}
#
#	
#	my $j = 0;
#	for ( my $i = 0 ; $i < $#gSRxa ; $i++ ) {
#		if ( $gSRstep[$i] eq 'xray' ) {
#			my @tempArr = ( $gSRxa[$i], $gSRya[$i] );
#			$inspectaSIPads{ $myXrayKeys[$j] } = \@tempArr;
#			$j++;
#		}
#	}
#
#	my @tempArr = ( $inspectaSIPads{'BL'}[0], $inspectaSIPads{'TR'}[1] );
#	$inspectaSIPads{'TL'} = \@tempArr;
#
#	return %inspectaSIPads;
#}

#$f->Label(
#	-anchor => 'e',
#	-text   => "Choose a job number:"
#)->pack( -side => 'top', );

#	foreach my $myKey (keys %inspectaSIPads) {
#		$text->insert( "end", "getXrayCoords() : " . $myKey . "\n" );
#	}
#
#	foreach my $myValue (values %inspectaSIPads) {
#		$text->insert( "end", "getXrayCoords() : " . $myValue . "\n" );
#	}

#		print(  $myCorner . ": "
#			  . $inspectaSIPads{$myCorner}[0] . " / "
#			  . $inspectaSIPads{$myCorner}[1]
#			  . "\n" );

#	foreach $myCorner ( keys %inspectaSIPads ) {
#		$text->insert( "end",
#			    $myCorner . ": "
#			  . $inspectaSIPads{$myCorner}[0] . " / "
#			  . $inspectaSIPads{$myCorner}[1]
#			  . "\n" );
#	}



#	showMessageBox("getMDBList()", $resultList[0] . "\n" . $resultList[1] . "\n" . $resultList[2] . "\n" . $resultList[3] );

#	showMessageBox(
#		"getMDBList()",
#		"mySubMDBFile: " . $mySubMDBFile . "\n"
#		  . "myJobNumber: " . $myJobNumber . "\n"
#		  . "myCustNumber: " . $myCustNumber . "\n"
#		  . "myShortJobNumber: " . $myShortJobNumber . "\n"
#		  . $myInspectaPath . "\n"
#		  . $myPath . "\n"
#		  . $listeLn . "\n"
#		  . $#resultList
#	);

#my @myMDBList = ();

# 098x0145.1712_1-4.1.mdb
# 098x0145.1712_5-8.1.mdb

#return @myMDBList;
# 2. zanim otworze kolejnego joba, nalezalo by sprawdzic,
#    czy jest juz jakis poprzedni job aby go zamknac.
#sub jobBE_chooseJob {
#	$stepListBox->delete( 0, "end" );
#
#	$myJobNumber =~ s/\s//g;    # remove any white space
#	@mySteps = getStepList($myJobNumber);
#
#	# sprawdzenie ilosci krokuf
#	if ( $#mySteps == -1 ) {
#		$text->insert( "end",
#			"The job " . $myJobNumber . " has not any steps. \n" );
#		return;
#	}
#	$text->insert( "end", "The job " . $myJobNumber . " has been read. \n" );
#	$stepListBox->insert( "end", @mySteps );
#}

#	$mySelection = $stepListBox->curselection();
#	if ( $mySelection eq '' ) {
#		$text->insert( "end", "Please select a step." . "\n" );
#		return 0;
#	}
#	$text->delete( "0.0", "end" );    # erase the text area

#	my $myStepName = $stepListBox->get( $stepListBox->curselection );
#	$statusLabel = "Get scale factors for " . $myStepName;
#	$text->insert( "end", $myStepName . " of $myJobNumber \n" );


#############
## Listbox
#my $stepListBox = $myFrame->Scrolled(
#	"Listbox",
#	-font       => "Verdana 9 normal",
#	-height     => 8,
#	-scrollbars => "e",
#	-selectmode => "single"
#  )->pack(
#	-side   => 'top',
#	-padx   => 5,
#	-pady   => 10,
#	-fill   => 'both',
#	-expand => 1
#  );


	
#	
#	if ( $myBuildUp !~ /^[0-9,.-]+$/ ) {
#		
#		#15	RXPLADETYKKELSE	NUMBER(32,16)
#
#		# for double sided boards the printtype must begin with P or PI not PP
#		if ( $myBuildUp =~ /^[PI][^PC]/ ) {
#			showMessageBox( 'prepare_GUIResp()', $myBuildUp);
#			$tykkelse = substr( $myBuildUp, 3, 3 );
#		}
#		else {
#			$tykkelse = 0;    # not PI and wrong build-up number
#		}
#	}
#	else {
#		# for multilayers
#		#$tykkelse = readXAL_getThickness($myBuildUp);
#		$tykkelse = $myVNRDetails[15];
#		$tykkelse =~ s/,/\./g;    # replace a comma by a dot
#		$tykkelse *= 1000;
#	}


#			# rotacja 90 stopni w prawo
#			my $temp = $top;
#			$top    = $left;
#			$left   = $bottom;
#			$bottom = $right;
#			$right  = $temp;
#			$text->insert( "end",
#				    "po rotacji: \n"
#				  . $left . "\t"
#				  . $right . "\t"
#				  . $top . "\t"
#				  . $bottom
#				  . "\n" );
#
#			$ABSposX11 = -$top;
#			$ABSposY11 = $left;
#
#			# top-left = top-right
#			$ABSposX12 = $top;
#			$ABSposY12 = $right;
#
#			$ABSposX21 = -$bottom;
#			$ABSposY21 = -$left;
#
#			$ABSposX22 = $bottom;
#			$ABSposY22 = -$right;

#push @tempArray, 0;
#push @tempArray, keys %inspectaLayerPadOffsets;
#push @tempArray, 0;
#push @tempArray, keys %inspectaSIPads ;
#showArray(\@tempArray);
#my $myLetter = "A";
#my $myDigit = 0;

#	push @tempArray, $myCorner . "_" . $myLetter;
#	$myLetter++;

#push @tempArray, $myLayer . "_" . $myDigit;
#$myDigit++;

#my @tempArray = ();
# jestem blisko prawdy..
#showArray(\@tempArray);

#sub getLayerXrayPads2 {
#
#	my $array_ref      = shift;
#	my %inspectaSIPads = %{$array_ref};
#
#	$array_ref = shift;
#	my %inspectaLayerPadOffsets = %{$array_ref};
#
#	my @myLayerXrayPads = ();
#
#	my $myKey, my $ilCoordsx, my $ilCoordsy, my @tempArr;
#	my $j = 0;
#	foreach $myOffsetKey ( sort keys %inspectaLayerPadOffsets ) {
#		foreach $mySIKey ( sort keys %inspectaSIPads ) {
#			if ( ( $mySIKey eq 'TR' ) || ( $mySIKey eq 'BR' ) ) {
#				$ilCoordsx =
#				  $inspectaSIPads{$mySIKey}[0] -
#				  $inspectaLayerPadOffsets{$myOffsetKey}[0];
#				$ilCoordsy =
#				  $inspectaSIPads{$mySIKey}[1] -
#				  $inspectaLayerPadOffsets{$myOffsetKey}[1];
#			}
#			else {
#				$ilCoordsx =
#				  $inspectaSIPads{$mySIKey}[0] +
#				  $inspectaLayerPadOffsets{$myOffsetKey}[0];
#				$ilCoordsy =
#				  $inspectaSIPads{$mySIKey}[1] +
#				  $inspectaLayerPadOffsets{$myOffsetKey}[1];
#			}
#			@tempArr = ( $myOffsetKey, $mySIKey, $ilCoordsx, $ilCoordsy );
#			push @myLayerXrayPads, @tempArr;
#			$j++;
#		}
#	}
#	return @myLayerXrayPads;
#}

#$text->insert( "end", "myKey: " . $myKey . "\n");
#$myLength = $#{$myLayXrayPads{$myKey}};			# displays the length
#$myLength = keys %myLayXrayPads;
#$text->insert( "end", "myLength: " . $myLength . "\n");
#for ( 0 .. $myLength ) {

#		$text->insert( "end", "BLx: " . $myBLx . " BLy: " . $myBLy . "\n");
#		$text->insert( "end", "BRx: " . $myBRx . " BRy: " . $myBRy . "\n");
#		$text->insert( "end", "TLx: " . $myTLx . " TLy: " . $myTLy . "\n");
#		$text->insert( "end", "TRx: " . $myTRx . " TRy: " . $myTRy . "\n\n");

#		$text->insert( "end", "BLx: " . $myLayXrayPads{$myKey}[2] . " BLy: " . $myLayXrayPads{$myKey}[3] . "\n");
#		$text->insert( "end", "BRx: " . $myLayXrayPads{$myKey}[2] . " BRy: " . $myLayXrayPads{$myKey}[3] . "\n");
#		$text->insert( "end", "TLx: " . $myLayXrayPads{$myKey}[2] . " TLy: " . $myLayXrayPads{$myKey}[3] . "\n");
#		$text->insert( "end", "TRx: " . $myLayXrayPads{$myKey}[2] . " TRy: " . $myLayXrayPads{$myKey}[3] . "\n");

#	# loop starts with 1 because of the 2nd if.
#	my $j = 0;
#	for ( 1 .. $#myLayXrayPads + 1 ) {
#		if ( $_ % 4 == 0 ) {
#			push( @myLayGroup,
#				$myLayXrayPads[ $_ - 2 ],
#				$myLayXrayPads[ $_ - 1 ] );
#
##$text->insert ("end", $myLayXrayPads[$_ - 4] . " " . $myLayXrayPads[$_ - 3] . "\t");
##$text->insert ("end", $myLayXrayPads[$_ - 2] . " " . $myLayXrayPads[$_ - 1] . "\n");
#		}
#
#		# 032x0013.1013
#
#		# each layer has 16 data
#		if ( $_ % 16 == 0 ) {
#			$left   = ( $myLayGroup[5] - $myLayGroup[1] );    # TLy-BLy
#			$right  = ( $myLayGroup[7] - $myLayGroup[3] );    # TRy-BRy
#			$top    = ( $myLayGroup[6] - $myLayGroup[4] );    # TRx-TLx
#			$bottom = ( $myLayGroup[2] - $myLayGroup[0] );    # BRx-BLx
#
#			$ABSposX11 = -$left / 2;
#			$ABSposY11 = $bottom / 2;
#
#			$ABSposX12 = $left / 2;
#			$ABSposY12 = ( $top / 2 ) + 5;
#
#			$ABSposX21 = -$right / 2;
#			$ABSposY21 = -$bottom / 2;
#
#			$ABSposX22 = $right / 2;
#			$ABSposY22 = ( -$top / 2 ) + 5;
#
##			$text->insert ("end", $ABSposX11 . "\t" . $ABSposY11 . "\n" . $ABSposX12 . "\t" . $ABSposY12 . "\n"
##				. $ABSposX21 . "\t" . $ABSposY21 . "\n" . $ABSposX22 . "\t" . $ABSposY22 . "\n\n");
#
#			@myLayGroup = ();
#		}
#	}

#			$text->insert ("end", $myKeyGroup[0] . "\n" . $ABSposX11 . "\t" . $ABSposY11 . "\n" 
#				. $ABSposX12 . "\t" . $ABSposY12 . "\n" . $ABSposX21 . "\t" . $ABSposY21 . "\n"
#				. $ABSposX22 . "\t" . $ABSposY22 . "\n\n");

#			$text->insert( "end", "left:\t" . $left . "\n" );
#			$text->insert( "end", "right:\t" . $right . "\n" );
#			$text->insert( "end", "top:\t" . $top . "\n" );
#			$text->insert( "end", "bottom:\t" . $bottom . "\n\n" );


#	my $my_entity_path = "$myLocalJobNumber/$myLocalStepName";
#	my %drillLays = getDrillLayers( 'normal', $my_entity_path );
#	if ( keys %drillLays == 0 ) {
#		$text->insert( "end", "Error: no drill layers has been found. \n" );
#		$statusLabel = "No drill layers has been found";
#		return @myPPMs;
#	}
#	showHashArray( \%drillLays );

	# get the whole matrix into a hash array
#	my %mLayers = getMatrix($myLocalJobNumber);
#	if ( keys %mLayers == 0 ) {
#		$text->insert( "end", "Error: Couldn't get matrix. \n" );
#		return @myPPMs;
#	}

	# showHashArray(\%mLayers );

	
# this functions returns a hash-array of coordinates for specified item on given layer
# if item not found then the array is empty (length -1)
#sub getXY2 {
#	my $myItem       = shift;
#	my $myEntityPath = shift;
#
#	my $myAttribute = 'fiducial_name=inspecta';
#
#	# $$ is the process ID (PID)
#	local $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";
#
#	# $myTab[0] : job	# $myTab[1] : step	# $myTab[2] : layer
#	my @myTab = split /\//, $myEntityPath;
#
#	my $myFeatures     = {};
#	my @mySplittedLine = ();
#
#	@csh_file = $genesis->INFO(
#		'units'       => 'mm',
#		'entity_type' => 'layer',
#		'entity_path' => $myEntityPath,
#		'data_type'   => 'FEATURES',
#		'parse'       => 'no'
#	);
#
#	open( CSHFILE, $csh_file )
#	  or die " ---> 1. can not open file $csh_file: $!\n";
#
#	my @data = <CSHFILE>;
#	close(CSHFILE);
#	unlink $csh_file;
#
#	my @rs = searchFeature( \@data, $myItem, $myAttribute );
#	if ( $#rs == -1 ) {
#		@rs = searchFeature( \@data, $myItem );   # second try without attribute
#		if ( $#rs == -1 ) {
#			print("getXY(): Nothing found.  \n");
#			return;
#		}
#	}
#	my @tempArray = ();
#	@tempArray = ( $rs[1], $rs[2] );
#
#	# $myTab[2] is the layer name
#	$myFeatures{ $myTab[2] } = \@tempArray;
#
#	return %myFeatures;
#}
#	# get list of innerlayers
#	my @cuLays2 = getCopperInnerLayers($myLocalJobNumber);
#	if ( $#cuLays == -1 ) {
#		$text->insert( "end",
#			"There aren't any copper layers in this job." . "\n" );
#		$statusLabel = "No copper layers found";
#		return @myLayerXrayPads;
#	}

#showArray(\@cuLays);

#showHashArray(\%myCoords);
#		($text->insert( "end", $i . " : " . $myCULays[$i] . " : " . $myLocalCoords{$myCULays[$i]}[0]
#		). " : " . $myLocalCoords{$myCULays[$i]}[1] . "\n" );
#$myCULays[$i]

# $localHashArray{$myKey}[0], $localHashArray{$myKey}[1]

#	foreach my $myKey ( sort keys %localHashArray ) {
#		$text->insert( "end", "{ $myKey }\t" );
#		foreach my $myValue ( @{ $localHashArray{$myKey} } ) {
#



		#$text->insert( "end", $i . " : " . $myXRAYCoords [0] . " : " . $myXRAYCoords[1] . "\n");
		#showHashArray( \@myTempCoords2 );
		#$text->insert( "end", $i . "\n");
		
		#push @tempArray, $myTempCoords{ $myCULays[$i] }[0];
		#push @tempArray, $myTempCoords{ $myCULays[$i] }[1];
		#$myTempCoords = {};
#		$text->insert( "end", $i . " : " 
#			. $myCULays[$i] . " : " 
#			. $myTempCoords{$myCULays[$i]}[0] . " : " 
#			. $myTempCoords{$myCULays[$i]}[1] . "\n" );


#	# we have to allign the layer names
#	showArray(\@myLayerArray);
#
#	my @myAllignedLayerArray = getAllignedLayerNames(\@myLayerArray); 
#	showArray(\@myAllignedLayerArray );


	# bottom goes before top ;-)
	# %mySortedXrayCoords = sortMyHashArray( \%myXrayCoords);
	# showHashArray(\%mySortedXrayCoords);
	
	# fajne regexy: https://perldoc.perl.org/perlrequick.html	
	# zamin zrobie lineara, to trza posortowac!


	# odrzucic dwie warstwy zewnetrzne w tablicy @myLayFromToArr
#	for ( $j = 1 ; $j <= $#myLayFromToArr ; $j++ ) {
#		$myLayFromToArr[$j - 1] = $myLayFromToArr[$j];
#	}
#	$#myLayFromToArr--;		# zmienia wielkosc tabeli o -1
#	
	#showArray(\@myLayFromToArr);
	
	########################################################################
	#$text->insert( "end", "myLayerPair[]: " . "\n" );
	#showArray(\@myLayerPair);

#	# get unique pairs
#	my $charSum           = 0;
#	my $charValue         = 0;
#	my @chars             = ();
#	my @charSumArray      = ();
#	my @myUniqueLayerPair = ();
#	$i = 0;
#	my $rs = 0;
#
#	for ( my $k = 0 ; $k <= $#myLayerPair ; $k++ ) {
#		@chars = $myLayerPair[$k] =~ /./sg;
#		for ( my $j = 0 ; $j <= $#chars ; $j++ ) {
#			$charValue = ord( $chars[$j] );
#			$charSum += $charValue;    # get the ASCII sum of all characters
#		}
#
#		# sprawdzac wystepowanie w momencie dodawania!
#		$rs = doesExist( $charSum, \@charSumArray );
#		if ( $rs == 0 ) {
#			$charSumArray[$i]      = $charSum;
#			$myUniqueLayerPair[$i] = $myLayerPair[$k];    # rewrite
#			$i++;
#		}
#		$charSum = 0;
#	}

	#$text->insert( "end", "myUniqueLayerPair[]: " . "\n" );
	#showArray( \@myUniqueLayerPair );
	
	#	my @mySplittedPair = ();
#	for ( $i = 0 ; $i <= $#myUniqueLayerPair ; $i++ ) {
#		@mySplittedPair = split /_/, $myUniqueLayerPair[$i];
#
#		# showArray(\@mySplittedPair);
#	}
	
	
#######################################################################

# use Net::Ping;
# use Win32::OLE;
# use Win32::OLE::Variant;
	
#	# ping test
#	$text->insert( "end", "Wait for ping reply from $myInspectaHost ... \n" );
#	$myFrame->update;
#
#	#$p = Net::Ping->new('icmp');
#	$p = Net::Ping->new('tcp');
#
#	# the second parameter is the timeout in seconds
#	if ( $p->ping( $myInspectaHost, 3 ) == 0 ) {
#		$text->insert( "end",
#			"$myInspectaHost doesn't reply. Cannot continue.\n" );
#		$p->close();
#		return my @liste;
#	}
#	$text->insert( "end", "The Inspecta on $myInspectaHost is alive. \n" );
#	$p->close();


#		my $myStatus = my $network = Win32::OLE->new('WScript.Network');
#		if ( !defined $myStatus ) {
#			$text->insert( "end", "Error creating network object' \n", 'errorline' );
#			return @liste;
#		}

#		$myStatus = $network->MapNetworkDrive( 'W:', $myInspectaPath, 0, $myInspectaUser, $myInspectaPass );
#		if ( !defined $myStatus ) {
#			$text->insert( "end", " kucha pszet\n" );
#			#$text->insert( "end", "$! \n", 'errorline' );
#			#$text->insert( "end", "$^E \n", 'errorline' );		# nic nie daje
#			# $text->insert( "end", Win32::FormatMessage( Win32::GetLastError) );	# niby ze OK hehe
#			$text->insert( "end", " kucha ipo\n" );
#			return @liste;
#		}
#	}
	