#!c:/Perl/bin/perl -w

#use lib './myLib';
#use myLib::myGenesis;

use Tk;
use warnings;
use strict;
use Genesis;

# globals:
my $myOrgProfLayer = 'org_profile';
my $myAOIProfLayer = 'aoi_profile';
my $genesis        = new Genesis;

sub showMessageBox {
	my $myTitle   = shift;
	my $myMessage = shift;
	my $myIcon    = shift;

	my $mw = new MainWindow;
	$mw->withdraw();

	my $reponse_messageBox = $mw->messageBox(
		-icon    => $myIcon,
		-title   => $myTitle,
		-type    => 'OK',
		-message => $myMessage,
	);
}

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

# sprawdzenie czy rzad istnieje
# jak nie to zwraca -1, inaczej zwraca jego numer w matriksie
sub doesRowExist {
	return -1;
}

# sprawdzenie czy step istnieje
# jak nie znalazl to zwraca -1,
# inaczej zwraca numer kolumny
sub doesStepExist {

	my $localJobName  = shift;
	my $localStepName = shift;

	$genesis->INFO(
		entity_type => 'matrix',
		entity_path => "$localJobName/matrix",
		data_type   => 'COL'
	);

	my $total_cols = @{ $genesis->{doinfo}{gCOLcol} };
	if ( $total_cols <= 0 ) {
		return -1;
	}

	my $mStepName = '';
	my $mCol;
	for ( my $count = 0 ; $count < $total_cols ; $count++ ) {
		$mStepName = ${ $genesis->{doinfo}{gCOLstep_name} }[$count];
		$mCol      = ${ $genesis->{doinfo}{gCOLcol} }[$count];
		if ( $mStepName eq $localStepName ) {
			return $mCol;
		}
	}

	return -1;
}

sub prepareProfile {

	$genesis->VON;
	my $job_name = shift;

	if ( !defined $job_name ) {
		showMessageBox( "Error", "First open a job. \nProgram exits.",
			'error' );
		return -1;
	}

	my $isOpen = $genesis->COM( 'is_job_open', 'job' => $job_name );
	if ( $isOpen eq "no" ) {
		$genesis->COM( 'open_job', job => $job_name );
		if ( $genesis->{STATUS} != 0 ) {
			showMessageBox( "Error",
				"Error caused by COM->open_job. \nProgram exits.", 'error' );
			return -2;
		}
	}

	# sprawdzenie czy step istnieje
	my $myStep = "pcb";
	my $myStepFound = doesStepExist( $job_name, $myStep );

	if ( $myStepFound < 0 ) {
		showMessageBox(
			"Error",
			"Step '"
			  . $myStep
			  . "' does not exist in the matrix. \nProgram exits.",
			'error'
		);
		return -4;
	}

	$genesis->INFO(
		entity_type => 'matrix',
		entity_path => "$job_name/matrix",
		data_type   => 'ROW'
	);

	my $total_rows = @{ $genesis->{doinfo}{gROWrow} };
	if ( $total_rows <= 0 ) {
		showMessageBox( "Error", "Matrix cannot be empty. \nProgram exits.",
			'error' );
		return -5;
	}

	# kasowanie warstwy aoi_profile (o ile istnieje)
	my $mLayerName;
	my $mRow;
	for ( my $count = 0 ; $count < $total_rows ; $count++ ) {
		$mLayerName = ${ $genesis->{doinfo}{gROWname} }[$count];
		$mRow       = ${ $genesis->{doinfo}{gROWrow} }[$count];
		if ( $mLayerName eq $myAOIProfLayer ) {
			$genesis->COM(
				'matrix_delete_row',
				job    => $job_name,
				matrix => 'matrix',
				row    => $mRow
			);
		}
	}
	
	#odswierz matrixa

	# The command adds a new layer to the job matrix. The layer is created in all of the job steps.
	$genesis->COM(
		'matrix_add_layer',
		job      => $job_name,
		matrix   => 'matrix',
		layer    => $myAOIProfLayer,
		row      => $total_rows + 1,
		context  => 'board',
		type     => 'document',
		polarity => 'positive'
	);

	# otworz editora ze stepem pcb
	$genesis->COM(
		'open_entity',
		job    => $job_name,
		type   => "step",
		name   => $myStep,
		iconic => "yes"
	);

	# to jest jakis myk z uaktywnianiem warstw w edytorze
	print ("comans: " . $genesis->{COMANS} . "\n");
	$genesis->AUX( 'set_group', group => $genesis->{COMANS} );

	# czasami trza najpierw otworzyc edytora zanim wolam display_layer
	$genesis->COM(
		'display_layer',
		name    => $myAOIProfLayer,
		display => 'yes',
		number  => 1
	);

	$genesis->COM( 'work_layer', name => $myAOIProfLayer );
	$genesis->COM( 'profile_to_rout', layer => $myAOIProfLayer, width => 101 );

	$genesis->COM(
		'sel_copy_other',
		'dest'         => 'layer_name',
		'target_layer' => $myOrgProfLayer,
		'invert'       => 'no',
		'dx'           => 0,
		'dy'           => 0,
		'size'         => 0,
		'x_anchor'     => 0,
		'y_anchor'     => 0,
		'rotation'     => 0,
		'mirror'       => 'none'
	);

	# Un-selects all the features in all the affected layers.
	$genesis->COM('sel_clear_feat');

	# Resets all the filter values to their default values
	$genesis->COM( 'filter_reset', filter_name => 'popup' );

	$genesis->COM( 'adv_filter_set',   active      => 'no' );
	$genesis->COM( 'adv_filter_reset', filter_name => 'popup' );

	# filtr globalny tylko na same arki
	$genesis->COM(
		'filter_set',
		filter_name  => 'popup',
		update_popup => 'no',
		feat_types   => 'arc'
	);

	$genesis->COM('filter_area_strt');

	$genesis->COM(
		'filter_area_end',
		layer          => $myAOIProfLayer,
		filter_name    => 'popup',
		operation      => 'select',
		area_type      => 'none',
		inside_area    => 'no',
		intersect_area => 'no'
	);

	# check if there are any arcs on the profile at all
	my $mySelected = $genesis->COM('get_select_count');
	if ( $mySelected > 0 ) {

		# clear selection
		$genesis->COM('sel_clear_feat');

		# select arcs with 5mm > diameter < 20mm
		$genesis->COM(
			'adv_filter_set',
			filter_name     => 'popup',
			update_popup    => 'no',
			selected        => 'no',
			arc_values      => 'yes',
			min_sweep_angle => 0,
			max_sweep_angle => 0,
			min_diameter    => 5,
			max_diameter    => 20,
			active          => 'yes'
		);

		$genesis->COM('filter_area_strt');

		$genesis->COM(
			'filter_area_end',
			layer          => $myAOIProfLayer,
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
			layer          => $myAOIProfLayer,
			filter_name    => 'popup',
			operation      => 'select',
			area_type      => 'none',
			inside_area    => 'no',
			intersect_area => 'no'
		);

		$mySelected = $genesis->COM('get_select_count');
		if ( $mySelected == 0 ) {
			showMessageBox(
				"Done", "There are no arcs in the profile anymore. 
			\nNothing to do thus program exits.", 'info'
			);
			return -7;
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

		if ( $genesis->{STATUS} != 0 ) {
			showMessageBox(
				"Error", "Program exits with status $genesis->{STATUS}. \nProgram exits.",
				'error'
			);
			return -8;
		}

		my $fh;

		# $$ is the process ID (PID)
		my $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";
		my $myStatus = open( $fh, $csh_file );

		# check read status
		if ( !defined $myStatus ) {
			showMessageBox( "Error", "$!: $csh_file. \nProgram exits.",
				'error' );
			return -9;
		}

		my @smallArcs = <$fh>;
		close($fh);
		unlink $csh_file;

		if ( $#smallArcs == 0 ) {
			showMessageBox( "Error",
				"The number of arcs is 0. \nProgram exits.", 'error' );
			return -10;
		}

		# a teraz mozna je usunac o ile przynajmniej jeden arc jest zaznaczony
		$mySelected = $genesis->COM('get_select_count');

		if ( $mySelected > 0 ) {
			$genesis->COM('sel_delete');
		}

		my $xs, my $ys, my $xe, my $ye;
		my $myLengthX1, my $myLengthX2;
		my $myLengthY1, my $myLengthY2;

		my $xs1, my $ys1, my $xe1, my $ye1;
		my $xs2, my $ys2, my $xe2, my $ye2;

		my @myRow;
		my @myPreviousRow;
		for ( my $j = 1 ; $j <= $#smallArcs ; $j++ ) {

			@myRow = split / /, $smallArcs[$j];

			# wybierz linie z jednego konca zaokraglenia
			$genesis->COM(
				'sel_single_feat',
				operation => 'select',
				x         => $myRow[1],
				y         => $myRow[2],
				tol       => 10,
				cyclic    => 'yes'
			);

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

			#my $mySelFeatures = $genesis->COM('get_select_count');

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
			}

			if ( $myDivisor2 != 0 ) {
				$slopeR = abs( $ye2 - $ys2 ) / $myDivisor2;
			}

			# lines are parallel if slope difference is 0 or close to 0 or if both slopes are 0
			my $diffSlope;
			if ( ( defined $slopeL ) && ( defined $slopeR ) ) {
				$diffSlope = abs( $slopeL - $slopeR );
			}

			my $diffDivisor;
			if ( ( defined $myDivisor1 ) && ( defined $myDivisor2 ) ) {
				$diffDivisor = abs( $myDivisor1 - $myDivisor2 );
			}

			# jesli linie sa krotkie (< 2.0mm) to nalezy je usunac i polaczyc
			$myLengthX1 = abs( $mySelection{'xs1'} - $mySelection{'xe1'} );
			$myLengthY1 = abs( $mySelection{'ys1'} - $mySelection{'ye1'} );
			$myLengthX2 = abs( $mySelection{'xs2'} - $mySelection{'xe2'} );
			$myLengthY2 = abs( $mySelection{'ys2'} - $mySelection{'ye2'} );

			if (
				(
					( defined $diffSlope )
					&& (
						(
							( ( $diffDivisor < 0.2 ) || ( $diffSlope < 0.2 ) )
							|| ( $slopeL == 0 ) && ( $slopeR == 0 )
						)
					)
				)

				|| (
					( !defined $diffSlope )
					&& (   ( ( $myDivisor1 == 0 ) && ( $myDivisor2 == 0 ) )
						|| ( ( $myDivisor1 < 2 )  && ( $myDivisor2 == 0 ) )
						|| ( ( $myDivisor1 == 0 ) && ( $myDivisor2 < 0 ) ) )
				)
			  )

			{
				$xs = $myRow[1];
				$ys = $myRow[2];
				$xe = $myRow[3];
				$ye = $myRow[4];

				# teraz wstawic linie laczaca
				$genesis->COM(
					'add_line',
					attributes    => 'no',
					xs            => $xs,
					ys            => $ys,
					xe            => $xe,
					ye            => $ye,
					symbol        => 'r102',
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
			else {
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
					showMessageBox( "Error",
						"Error in 'sel_intersect_best' \nProgram exits.",
						'error' );
					return -11;
				}

				next;
			}

			$genesis->COM('sel_clear_feat');
			next;

		}    # end of for-loop

		# Command for starting an area selection (it resets the points list).
		$genesis->COM('filter_area_strt');
		$genesis->COM(
			'filter_area_end',
			layer          => $myAOIProfLayer,
			filter_name    => 'popup',
			operation      => 'select',
			area_type      => 'none',
			inside_area    => 'no',
			intersect_area => 'no'
		);

		# zrob profile z wybranych poligonuf
		$genesis->COM('sel_create_profile');

	}    # koniec if

#########################

	# zamknij editora stepa pcb
	$genesis->COM('editor_page_close');

	my $myPanelStep  = 'panel';
	my $orgPanelStep = 'panel_org';
	my $myAOIStep    = 'aoi';

	# sprawdzenie czy istnieje step 'aoi' i usuniecie stepa
	$myStepFound = doesStepExist( $job_name, $myAOIStep );
	if ( $myStepFound >= 0 ) {

		# kasowanie stepa aoi
		$genesis->COM(
			'matrix_delete_col',
			job    => $job_name,
			matrix => 'matrix',
			col    => $myStepFound
		);
	}

	# copy step 'panel' to the 'aoi'
	$genesis->COM(
		'copy_entity',
		type          => 'step',
		source_job    => $job_name,
		source_name   => $myPanelStep,
		dest_job      => $job_name,
		dest_name     => $myAOIStep,
		dest_database => ''
	);

	# zmienia nazwe panel -> panel_org
	$genesis->COM(
		'matrix_rename_step',
		job      => $job_name,
		matrix   => 'matrix',
		step     => $myPanelStep,
		new_name => $orgPanelStep
	);

	# teraz mozna sie pobawic z tabelom stepuf

	# otworz stepa aoi
	$genesis->COM(
		'open_entity',
		job    => $job_name,
		type   => "step",
		name   => $myAOIStep,
		iconic => "yes"
	);

	# reduce nesting TYLKO gdy istnieje uzytek!!
	my $mStepArk = 'ark';
	$myStepFound = doesStepExist( $job_name, $mStepArk );
	if ( $myStepFound >= 0 ) {

		# Command to define whether or not to keep the S&R pattern
		$genesis->COM( 'sredit_keep_sr_pattern', keep_sr_entry => 'no' );

		# Command to define whether or not to keep the S&R gap.
		$genesis->COM( 'sredit_keep_gap', keep_gap => 'no' );

		# Command to define whether or not to keep the S&R margin.
		$genesis->COM( 'sredit_keep_margin', keep_margin => 'no' );

		# Flatten the selected steps' S&R info - remove one sub panel level.
		$genesis->COM( 'sredit_reduce_nesting', mode => 'one_highest' );
	}

	# zmienia nazwe stepa aoi -> panel
	$genesis->COM(
		'matrix_rename_step',
		job      => $job_name,
		matrix   => 'matrix',
		step     => $myAOIStep,
		new_name => $myPanelStep
	);

	# zamknij editora stepa aoi
	$genesis->COM('editor_page_close');
	$genesis->AUX( 'set_group', group => 0 );

	# zamknij matrixa
	$genesis->COM( 'matrix_page_close', job => $job_name, matrix => 'matrix' );

	showMessageBox( "Done", "A new step 'AOI' has been created.", 'info' );

	# if error then return value is < 0, otherwise is 0
	return 0;
}

# uwaga na script cshell bo zapisuje zmiany, co oznacza ze moj skrypt tesz musi zapisac zmiany!
sub readOrgProfile {

	$genesis->VON;

	my $job_name = shift;

	# otworz stepa pcb
	my $myStep = "pcb";
	$genesis->COM(
		'open_entity',
		job    => $job_name,
		type   => "step",
		name   => $myStep,
		iconic => "no"
	);

	$genesis->COM( 'display_profile', display => 'no' );

	$genesis->COM('clear_layers');
	$genesis->COM('zoom_refresh');

	# first display a layer
	$genesis->COM(
		'display_layer',
		name    => $myOrgProfLayer,
		display => 'yes',
		number  => 1
	);

	# then make it working layer
	$genesis->COM( 'work_layer', name => $myOrgProfLayer );

	# Resets all the filter values to their default values
	$genesis->COM( 'filter_reset', filter_name => 'popup' );

	$genesis->COM( 'adv_filter_set',   active      => 'no' );
	$genesis->COM( 'adv_filter_reset', filter_name => 'popup' );

	# Command for starting an area selection (it resets the points list).
	$genesis->COM('filter_area_strt');
	$genesis->COM(
		'filter_area_end',
		layer          => $myOrgProfLayer,
		filter_name    => 'popup',
		operation      => 'select',
		area_type      => 'none',
		inside_area    => 'no',
		intersect_area => 'no'
	);

	my $mySelFeatures = $genesis->COM('get_select_count');
	print( "wybrano: " . $mySelFeatures . "\n" );

# The command is used for creating a step profile from the selected features. The
# skeleton shapes of all the line/arc features are taken as a closed polygon. Gaps are
# closed by connecting segments.
	$genesis->COM('sel_create_profile');
	$genesis->COM( 'display_profile', display => 'no' );

 # kasowanie pustych warstw oraz warstwy aoi_profile (o ile istnieje) - od konca
	$genesis->INFO(
		entity_type => 'matrix',
		entity_path => "$job_name/matrix",
		data_type   => 'ROW'
	);

	my $total_rows = @{ $genesis->{doinfo}{gROWrow} };
	if ( $total_rows > 0 ) {
		my $mLayerName;
		my $mRow;
		for ( my $count = $total_rows - 1 ; $count >= 0 ; $count-- ) {
			$mLayerName = ${ $genesis->{doinfo}{gROWname} }[$count];
			$mRow       = ${ $genesis->{doinfo}{gROWrow} }[$count];
			if (   ( $mLayerName eq '' )
				|| ( $mLayerName eq $myAOIProfLayer )
				|| ( $mLayerName eq $myOrgProfLayer ) )
			{
				$genesis->COM(
					'matrix_delete_row',
					job    => $job_name,
					matrix => 'matrix',
					row    => $mRow
				);
			}
		}
	}

	$genesis->COM( 'display_profile', display => 'yes' );

	# zamknij editora stepa aoi
	$genesis->COM('editor_page_close');
	$genesis->AUX( 'set_group', group => 0 );

	# odswierz matrixa
	$genesis->COM(
		'matrix_refresh',
		job    => $job_name,
		matrix => 'matrix',
	);

	# otworz matrixa
	$genesis->COM(
		'open_entity',
		job    => $job_name,
		type   => 'matrix',
		name   => 'matrix',
		iconic => "no"
	);

	# taka mala uwaga:
	# gdy usuwam tego stepa to maski camteka idom sie jebac
	# ino ze po exporcie do camteka maski som tutaj:
	# mask01.dat (pacz c:\camtek\jobs\)

	# znajdz step panel i go skasuj (expandowany step aoi)
	my $myStepFound = doesStepExist( $job_name, 'panel' );
	if ( $myStepFound >= 0 ) {
		$genesis->COM(
			'matrix_delete_col',
			job    => $job_name,
			matrix => 'matrix',
			col    => $myStepFound
		);
	}

	# przywroc oryginalny panel: panel_org -> panel
	$genesis->COM(
		'matrix_rename_step',
		job      => $job_name,
		matrix   => 'matrix',
		step     => 'panel_org',
		new_name => 'panel'
	);

	# odswierz matrixa
	$genesis->COM(
		'matrix_refresh',
		job    => $job_name,
		matrix => 'matrix',
	);

	# zapisz zmiany
	$genesis->COM(
		'save_job',
		job      => $job_name,
		override => 'no',
	);

	my $myLocalResult = 0;
	return $myLocalResult;
}

#print "------------- startujemy --------------- \n";

# $genesis->VON;

my @params         = ();
my $numberOfParams = $#ARGV;

my $myKeyword = $ARGV[0];
if ( $myKeyword !~ /-/ ) {    # a called function must begin with '-'
	showMessageBox( "Error",
		"Missing function as parameter. \nProgram exits.", 'error' );
	exit;
}

# if more the 0 parameters then put them into @params array
if ( $numberOfParams < 0 ) {
	showMessageBox( "Error",
		"Parameters not defined: $numberOfParams \nProgram exits.", 'error' );
	exit;
}

else {
	foreach my $myParameter (@ARGV) {
		push @params, $myParameter;
	}
}

# split the perl filename by slash (shift + 7)
my @myArrSplittedLine = split /[\/]/, $0;
my $myPerlFile = $myArrSplittedLine[$#myArrSplittedLine];

my $myResult = 0;
if ( $myKeyword eq "-prepareProfile" ) {
	$myResult = prepareProfile( $params[1] );
	if ( $myResult < 0 ) {

		#showMessageBox( $myPerlFile, "myResult: " . $myResult, 'error' );
	}
}

elsif ( $myKeyword eq "-readOrgProfile" ) {
	$myResult = readOrgProfile( $params[1] );
	if ( $myResult < 0 ) {

		#showMessageBox( $myPerlFile, "myResult: " . $myResult, 'error' );
	}
}

else {
	showMessageBox( $myPerlFile, "The requested function cannot be found.",
		'error' );
	exit;
}

print( "myResult: " . $myResult . "\n" );

# zapisz status do pliku
my $result_file = "$ENV{GENESIS_TMP}/result_csh.txt";
open( my $rf_handle, "+>", $result_file )
  || warn "Cannot open $result_file because: $!";
print $rf_handle $myResult;
close($rf_handle);

#print(" ---------- Koniec programa ------------ \n");
exit;

# environment variables in perl are stored in a hash called %ENV.
# You are free to modify this hash as you see fit.
# $ENV{PEOPLE}=5034;

