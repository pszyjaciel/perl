#!c:/Perl/bin/perl 

# now *.csv (from mdb) will be saved in the windows-temporary folder 

use Tk;
use Tk::StatusBar;
use Tk::BrowseEntry;
require Tk::ROText;

use Genesis;

# global variables
my $myTitle     = 'Xray-calc ';
my $version     = 'v3.16';
my $statusLabel = "";

my $myJobNumber      = '';
my $myStepName       = '';
my $myDrillLayerName = '';
my $myMDBName        = '';

my $myInspectaHost = "192.168.100.10";

# linux slashes don't work on XP
my $myInspectaPath = '\\\\' . $myInspectaHost . '\\inspecta\\Access\\';

my $myFont = 'Consolas 11 normal';

my $genesis;
my $text;

my @myJobs   = ();
my @mySteps  = ();
my @myDrills = ();
my @myMDBs   = ();

my $jobBE;
my $stepBE;
my $drillBE;
my $mdbBE;
my $myButton;

sub myGUIInit {

	my $mw     	 = MainWindow->new();
	my $toplevel = $mw;

	$mw->title( $myTitle . $version );
	# $mw->geometry("400x710+300+250");
	$mw->geometry("800x710+300+250");
	
	$mw->focus();

	$myFrame = $mw->Frame(
		-borderwidth => 10,
		-border      => 1,
		-relief      => 'groove'
	  )    #raised
	  ->pack(
		-side   => "top",
		-fill   => "both",
		-expand => 1,
		-padx   => 5,
		-pady   => 5
	  );

	# add icon to the window
	my $image = 'png/icon3.gif';    # 32x32 GIF or BMP
	if ( -e $image ) {
		my $icon = $mw->Photo( -file => $image );
		$mw->idletasks;             # this line is crucial
		$mw->iconimage($icon);
	}

	$statusLabel = "Please choose a job number.";

	#############
	# Add menu to the main window
	$mw->configure( -menu => my $menubar = $mw->Menu );
	$mw = $menubar->command(
		-label   => "~Quit",
		-command => sub { myExit() }
	);
	$mw = $menubar->command(
		-label   => '~About',
		-command => sub { myAbout() }
	);
	$mw = $menubar->command(
		-label   => '~Settings',
		-command => sub { mySettings() }
	);

	#############
	# Status bar
	$sb = $myFrame->StatusBar();

	$sb->addLabel(
		-relief       => 'flat',
		-padx         => 5,
		-pady         => 5,
		-borderwidth  => 2,
		-font         => $myFont,
		-textvariable => \$statusLabel,
		-command      => sub { mySBCmd() }
	);

	#########
	# ComboBox for the job name
	$jobBE = $myFrame->BrowseEntry(
		-font      => $myFont,
		-state     => 'normal',
		-choices   => \@myJobs,
		-variable  => \$myJobNumber,
		-label     => "Choose a job number:",
		-labelPack => [ -side => 'top' ],

		#-style     => 'MSWin32',
		-browsecmd => sub { chosen_jobBE() }
	  )->pack(
		-side   => 'top',
		-padx   => 15,
		-pady   => 15,
		-fill   => 'both',
		-expand => 1
	  );

	########
	# ComboBox for the step name
	$stepBE = $myFrame->BrowseEntry(
		-font      => $myFont,
		-state     => 'normal',
		-choices   => \@mySteps,
		-variable  => \$myStepName,
		-label     => "Choose a step name:",
		-labelPack => [ -side => 'top' ],

		#-style     => 'MSWin32',
		-browsecmd => sub { chosen_stepBE() }
	  )->pack(
		-side   => 'top',
		-padx   => 15,
		-pady   => 15,
		-fill   => 'both',
		-expand => 1
	  );

	#########
	# ComboBox for the drill layer
	$drillBE = $myFrame->BrowseEntry(
		-font      => $myFont,
		-state     => 'normal',
		-choices   => \@myDrills,
		-variable  => \$myDrillLayerName,
		-label     => "Choose a drill layer:",
		-labelPack => [ -side => 'top' ],
		-browsecmd => sub { chosen_drillBE() }
	  )->pack(
		-side   => 'top',
		-padx   => 15,
		-pady   => 15,
		-fill   => 'both',
		-expand => 1
	  );

	#########
	# ComboBox for the MDB file
	$mdbBE = $myFrame->BrowseEntry(
		-font      => $myFont,
		-state     => 'normal',
		-choices   => \@myMDBs,
		-variable  => \$myMDBName,
		-label     => "Choose a corresponding MDB-file:",
		-labelPack => [ -side => 'top' ],

		#-style     => 'MSWin32',
		-browsecmd => sub { chosen_mdbBE() }
	  )->pack(
		-side   => 'top',
		-padx   => 15,
		-pady   => 15,
		-fill   => 'both',
		-expand => 1
	  );

	###########
	# Button
	$myButton = $myFrame->Button(
		-width => 20,
		-font  => $myFont,
		-text  => 'Calculate',
		-underline => 0,
		-command => sub { myCalcBtnCmd() }
	  )->pack(
		-padx => 5,
		-pady => 5,
		-side => 'bottom'
	  );
	$myButton->bind( $myFrame, '<Alt-c>' => sub {myCalcBtnCmd()} );		# nie dziala i nie wciska w dol batona!
	$myButton->configure( -state => 'disabled' );


	###########
	# Text frame
	$text = $myFrame->Scrolled(
		"ROText",
		-height     => 36,
		-font       => $myFont,
		-scrollbars => "e",
		-state      => "normal",
		-takefocus  => 0
	  )->pack(
		-side   => 'top',
		-padx   => 15,
		-pady   => 15,
		-fill   => 'both',
		-expand => 1
	  );

	# get list of local shares
	my $shares = `net use`;
	
	# search for inspecta share and message if share not found
	if ( $shares !~ m/inspecta/i ) {
		$jobBE->delete( 0, 'end' );
		$text->insert( "end", "You have to map the Inspecta drive before continue. \n", 'errorline' );
		$text->insert( "end", "net use \\\\192.168.100.10\\inspecta (pfa/pfa) \n");
		
		# net use drive letter /delete 
	}

	$text->tagConfigure( 'successline',  -background => 'palegreen' );
	$text->tagConfigure( 'warningline',  -background => 'khaki2' );
	$text->tagConfigure( 'warningline2', -background => 'gold2' );
	$text->tagConfigure( 'warningline3', -background => 'gold3' );
	$text->tagConfigure( 'errorline',    -background => 'tomato' );

	# functions include also TAB-travelsal
	$jobBE->bind( "<Return>", sub { chosen_jobBE() } );
	$stepBE->bind( "<Return>", sub { chosen_stepBE() } );
	$drillBE->bind( "<Return>", sub { chosen_drillBE() } );
	$mdbBE->bind( "<Return>", sub { chosen_mdbBE() } );

	$jobBE->bind( '<Up>',    [ \&wheel_browse, $jobBE, -1 ] );
	$jobBE->bind( '<Down>',  [ \&wheel_browse, $jobBE, 1 ] );
	$jobBE->bind( '<Prior>', [ \&wheel_browse, $jobBE, -20 ] );
	$jobBE->bind( '<Next>',  [ \&wheel_browse, $jobBE, 20 ] );

	$stepBE->bind( '<Up>',   [ \&wheel_browse, $stepBE, -1 ] );
	$stepBE->bind( '<Down>', [ \&wheel_browse, $stepBE, 1 ] );

	$drillBE->bind( '<Up>',   [ \&wheel_browse, $drillBE, -1 ] );
	$drillBE->bind( '<Down>', [ \&wheel_browse, $drillBE, 1 ] );

	$mdbBE->bind( '<Up>',   [ \&wheel_browse, $mdbBE, -1 ] );
	$mdbBE->bind( '<Down>', [ \&wheel_browse, $mdbBE, 1 ] );

	$jobBE->focus();
}

######################### FUNCTIONS ############################

sub showMessageBox {
	my $myTitle = shift;
	my $myText  = shift;
	my $mw      = new MainWindow;
	$mw->withdraw();

	my $reponse_messageBox = $mw->messageBox(
		-title   => $myTitle,
		-message => $myText,
		-type    => 'Ok',
		-icon    => 'info'
	);
}

sub TOLERANCE () { 1e-13 }    # ??

sub are_equal {
	my ( $a, $b ) = @_;
	return ( abs( $a - $b ) < TOLERANCE );
}

# check if $value exists in the @array
# how to call: 	$rs = doesExist($charSum, \@charSumArray);
sub doesExist {
	my $myLocalValue = shift;
	my $array_ref    = shift;
	my @myLocalData  = @{$array_ref};

	if ( $#myLocalData < 0 ) {
		return 0;
	}

	foreach (@myLocalData) {
		if ( $_ == $myLocalValue ) {
			return 1;
		}
	}
	return 0;
}

sub mySBCmd {

	# $statusLabel zmienna globalna
	$statusLabel = 'jakis sztrink: ' . $counter;
	$counter++;
}

sub wheel_browse {
	my ( $main, $mybe, $num ) = @_;
	my $lb = $mybe->Subwidget("slistbox")->Subwidget('listbox');
	$lb->UpDown($num);    # c:\Perl\site\lib\Tk\Listbox.pm
	my $var_ref = $mybe->cget('-textvariable');
	$$var_ref = $lb->getSelected;
	return;
}

# function returns a rounded value to 0.5
sub getRounded {
	my $nr = shift;
	my $rounded;
	if ( $nr > 0 ) {
		$rounded = ( int( ( $nr * 2 ) + .5 ) ) / 2;    # rounding up to 0.5
	}
	else {
		$rounded = ( int( ( $nr * 2 ) - .5 ) ) / 2;    # rounding down to 0.5
	}
	return $rounded;
}

sub round {
	my ( $nr, $decimals ) = @_;
	return (-1) *
	  ( int( abs($nr) * ( 10**$decimals ) + .5 ) / ( 10**$decimals ) )
	  if $nr < 0;
	return int( $nr * ( 10**$decimals ) + .5 ) / ( 10**$decimals );
}

# this function compares two arrays accessed by their keys in a common hasharray
# it returns 1 if both arrays are equal, 0 otherwise
# example: my $result = hashCompare (\%localHashArray, 'majKij', 'majKij2');
sub hashCompare {

	my $array_ref      = shift;
	my %localHashArray = %{$array_ref};

	my $myKey1 = shift;
	my $myKey2 = shift;

	my @myTab1 = @{ $localHashArray{$myKey1} };
	my @myTab2 = @{ $localHashArray{$myKey2} };
	if ( $#myTab1 != $#myTab2 ) {
		return 0;
	}

	for ( my $i = 0 ; $i <= $#myTab1 ; $i++ ) {
		if ( $myTab1[$i] != $myTab2[$i] ) {
			return 0;
		}
	}
	return 1;
}

sub showArray2 {
	my $array_ref    = shift;
	my @myLocalArray = @{$array_ref};
	foreach my $value (@myLocalArray) {
		$text->insert( "end", $_ . " $value \n" );
	}
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
			$text->insert( "end", "\n" );
		}
		$text->insert( "end", "[" . $i . "]: " . $myLocalArray[$i] . "\t" );
	}
	$text->insert( "end", "\n" );
}

sub showKeyValueArray {
	my $array_ref      = shift;
	my %localHashArray = %{$array_ref};

	my $myValue;
	foreach my $myKey ( sort keys %localHashArray ) {
		$text->insert( "end", "{ $myKey }\t" . $localHashArray{$myKey} . "\n" );
	}
}

sub showHashArray {
	my $array_ref      = shift;
	my %localHashArray = %{$array_ref};
	foreach my $myKey ( sort keys %localHashArray ) {
		$text->insert( "end", "{ $myKey }\t" );
		foreach my $myValue ( @{ $localHashArray{$myKey} } ) {
			$text->insert( "end", "$myValue " );
		}
		$text->insert( "end", "\n" );    # ma byc inaczej wywala genesisa
	}
}

# function inserts a missing zero before the 1-digit layer name: il2p -> il02p
# it doesn't touch 2-digit names
# the parameter is a string array of layer names
sub getAllignedLayerNames {

	my $array_ref        = shift;
	my @myLocalLayerKeys = @{$array_ref};

	my @myLocalAllignedLayerKeys = ();

	for ( $j = 0 ; $j <= $#myLocalLayerKeys ; $j++ ) {
		if ( $myLocalLayerKeys[$j] =~ m/([0-9]{2})/ ) {
			$myLocalAllignedLayerKeys[$j] = $myLocalLayerKeys[$j];
		}
		else {
			# pozostaly same elementy 1-cyfrowe
			$myLocalLayerKeys[$j] =~ s/([0-9])/0$1/;    # wstaw brakujace zero
			$myLocalAllignedLayerKeys[$j] = $myLocalLayerKeys[$j];
		}
	}
	return @myLocalAllignedLayerKeys;
}

# function returns a sorted hash-array by its key
# call example: sortMyHashArray( \%myCoord );
sub sortMyHashArray {

	my $array_ref      = shift;
	my %localHashArray = %{$array_ref};

	# obie tablice maja taka samom wielkosc
	my @myNotAllignedLayerKeys = keys %localHashArray;
	my @myLocalLayerValues     = values %localHashArray;
	my @myLocalLayerKeys = getAllignedLayerNames( \@myNotAllignedLayerKeys );

	# teraz posortowac @myLocalLayerKeys wlacznie z zawartosciom
	my $result = 0;
	my $tempKey;
	my @tempArr = ();
	for ( $i = 0 ; $i <= $#myLocalLayerKeys ; $i++ ) {
		for ( $j = $i ; $j <= $#myLocalLayerKeys ; $j++ ) {
			if ( $i == $j ) {
				next;
			}
			$result = $myLocalLayerKeys[$i] cmp $myLocalLayerKeys[$j];
			if ( $result == 1 ) {
				$tempKey              = $myLocalLayerKeys[$i];
				$myLocalLayerKeys[$i] = $myLocalLayerKeys[$j];
				$myLocalLayerKeys[$j] = $tempKey;

				@tempArr = @{ $myLocalLayerValues[$i] };
				@{ $myLocalLayerValues[$i] } = @{ $myLocalLayerValues[$j] };
				@{ $myLocalLayerValues[$j] } = @tempArr;
			}
		}
	}

   # now create a new hash-array with alligned keys which will gonna be returned
	my %myNewHashArray = ();
	my $myKey          = '';
	@tempArr = ();
	for ( $k = 0 ; $k <= $#myLocalLayerValues ; $k++ ) {
		$myKey                  = $myLocalLayerKeys[$k];
		@tempArr                = @{ $myLocalLayerValues[$k] };
		$myNewHashArray{$myKey} = [@tempArr];
	}

	# showHashArray( \%myNewHashArray );
	return %myNewHashArray;
}

# function iterates through the file in @myData searching the feature $myItem
# with/without its attribute and returns an array of elements
sub searchFeature {

	my $foundPattern   = 0;
	my @foundFeature   = ();
	my @foundSIFeature = ();
	my $array_ref      = shift;
	my @myData         = @{$array_ref};

	# the inspecta-pad can be reduced/increased (etch-compensated)
	my $myTolerance = 10;

	my $myItem      = shift;
	my $myAttribute = shift;
	my $mySI        = shift;

	my $myTempValue = $myItem;
	if ( $myTempValue !~ /^[0-9,.E]+$/ ) {
		$text->insert( "end", "The item $myItem must be a digit! \n" );
		return @foundFeature;
	}
	$mySI = 'n' unless defined $mySI;

	$myAttribute = '' unless defined $myAttribute;
	if ( $myAttribute ne '' ) {

		#print "Search features by attribute and by size \n";
		foreach my $line (@myData) {

			@myArrSplittedLine = split /[\s\.]/,
			  $line;    # split by dot or by space

			# don't care about other lines than pad lines
			# nor lines without attributes
			# nor lines with attributes different than $myAttribute
			if (   ( $myArrSplittedLine[0] ne '#P' )
				|| ( $#myArrSplittedLine < 8 )
				|| ( $myArrSplittedLine[8] ne $myAttribute ) )
			{
				next;
			}

			# we remove the 'r' on the beginning of feature name
			$myArrSplittedLine[3] =~ s/^r//g;
			if ( $myArrSplittedLine[3] == $myItem ) {
				for ( my $i = 0 ; $i < $#myArrSplittedLine ; $i++ ) {
					if (   ( $myArrSplittedLine[1] == 0 )
						&& ( $myArrSplittedLine[2] == 0 ) )
					{
						# save the SI pads
						push @foundSIFeature, $myArrSplittedLine[$i];
						next;    # skip the rest
					}
					push @foundFeature, $myArrSplittedLine[$i];
				}
			}
		}
	}
	else {
		#print "Search features only by size of the feature\n";
		foreach my $line (@myData) {
			@myArrSplittedLine = split /[\s\.]/, $line;
			if (   ( $myArrSplittedLine[0] ne '#P' )
				|| ( $#myArrSplittedLine < 7 ) )
			{
				next;
			}
			$myArrSplittedLine[3] =~ s/^r//g;
			if (   ( $myArrSplittedLine[3] > $myItem - $myTolerance )
				|| ( $myArrSplittedLine[3] < $myItem + $myTolerance ) )
			{
				for ( my $i = 0 ; $i < $#myArrSplittedLine ; $i++ ) {
					if (   ( $myArrSplittedLine[1] == 0 )
						&& ( $myArrSplittedLine[2] == 0 ) )
					{
						# save the SI pads
						push @foundSIFeature, $myArrSplittedLine[$i];
						next;    # skip the rest
					}
					push @foundFeature, $myArrSplittedLine[$i];
				}
			}
		}
	}
	if ( $#foundFeature == -1 ) {

		#print "searchFeature(): nothing found. \n";
	}
	if ( $mySI eq 'y' ) {
		return @foundSIFeature;
	}
	else {
		return @foundFeature;
	}
}

# function returns an array of xy-coordinates for specified item on given layer
# if item cannot be find then the array returns empty (length -1)
# todo: function should access the disc only one time, even when called many times (use global array)
sub getXY {
	my $myItem       = shift;
	my $myEntityPath = shift;

	my $myAttribute = 'fiducial_name=inspecta';

	# $$ is the process ID (PID)
	local $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";

	my @myTab = split /\//, $myEntityPath;

	# $myTab[0] : job	# $myTab[1] : step	# $myTab[2] : layer

	my @myFeatures     = ();
	my @mySplittedLine = ();

	my @csh_file = $genesis->INFO(
		'units'       => 'mm',
		'entity_type' => 'layer',
		'entity_path' => $myEntityPath,
		'data_type'   => 'FEATURES',
		'parse'       => 'no'
	);

	my $myStatus = open( CSHFILE, $csh_file );

	# check read status
	if ( !defined $myStatus ) {
		$text->insert( "end", "$!: $csh_file \n", 'errorline' );
		$statusLabel = "Status: $!";
		return @myFeatures;
	}

	my @data = <CSHFILE>;
	close(CSHFILE);
	unlink $csh_file;

	# first try with attribute
	my @rs = searchFeature( \@data, $myItem, $myAttribute );
	if ( $#rs == -1 ) {

		# second try without attribute
		@rs = searchFeature( \@data, $myItem );
		if ( $#rs == -1 ) {

# $text->insert( "end", "Couldn't find any X-ray fiducial \non layer $myTab[2]. \n" );
			return;
		}
	}
	push @myFeatures, $rs[1];
	push @myFeatures, $rs[2];

	#showArray(\@myFeatures);
	return @myFeatures;
}

sub getCopperInnerLayers {

	my @cuLayers = ();
	$job_name = shift;
	if ( $job_name eq '' ) {
		$text->insert( "end", "getCopperInnerLayers(): Wrong parameters. \n" );
		return @cuLayers;
	}

	$genesis->INFO(
		entity_type => 'matrix',
		entity_path => "$job_name/matrix",
		data_type   => 'ROW'
	);

	# returns -1 if matrix empty
	my $total_rows = @{ $genesis->{doinfo}{gROWrow} };
	if ( $total_rows == -1 ) {
		return @cuLayers;
	}

	my $mRow;
	my $mLayerName;
	my $mLayerContext;
	my $mLayerType;
	my $mLayerSide;

	for ( my $count = 0 ; $count <= $total_rows ; $count++ ) {
		$mRow          = ${ $genesis->{doinfo}{gROWrow} }[$count];
		$mLayerName    = ${ $genesis->{doinfo}{gROWname} }[$count];
		$mLayerContext = ${ $genesis->{doinfo}{gROWcontext} }[$count];
		$mLayerType    = ${ $genesis->{doinfo}{gROWlayer_type} }[$count];
		$mLayerSide    = ${ $genesis->{doinfo}{gROWside} }[$count];

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

# $text->insert( "end", "getCopperInnerLayers(): #cuLayers: " . @cuLayers . "\n" );
	return @cuLayers;
}

sub getMatrix {
	my $job_name = shift;
	if ( $job_name eq '' ) {
		$text->insert( "end", "getMatrix(): Empty parameter job_name \n" );
		return;
	}
	$genesis->INFO(
		entity_type => 'matrix',
		entity_path => "$job_name/matrix",
		data_type   => 'ROW'
	);

	my $total_rows = @{ $genesis->{doinfo}{gROWrow} };
	if ( $total_rows == -1 ) {
		$text->insert( "end", "getMatrix(): $total_rows " . "\n" );
		return;
	}

	my $mRow;
	my $mName;
	my $mContext;
	my $mLayerType;
	my $mPolarity;
	my $mSide;
	my $mSheetSide;
	my $myLayers = {};    # deklaracja hasz tabeli, kluczem bedzie nazwa warstwy

	my $j       = 0;
	my @tempArr = ();
	for ( my $count = 0 ; $count <= $total_rows ; $count++ ) {
		if ( ${ $genesis->{doinfo}{gROWtype} }[$count] eq 'empty' ) {
			next;
		}
		$mRow       = ${ $genesis->{doinfo}{gROWrow} }[$count];
		$mName      = ${ $genesis->{doinfo}{gROWname} }[$count];
		$mContext   = ${ $genesis->{doinfo}{gROWcontext} }[$count];
		$mLayerType = ${ $genesis->{doinfo}{gROWlayer_type} }[$count];
		$mPolarity  = ${ $genesis->{doinfo}{gROWpolarity} }[$count];
		$mSide      = ${ $genesis->{doinfo}{gROWside} }[$count];
		$mSheetSide = ${ $genesis->{doinfo}{gROWsheet_side} }[$count];
		@tempArr    = (
			$mRow, $mName, $mContext, $mLayerType, $mPolarity, $mSide,
			$mSheetSide
		);
		$myLayers{$mName} = [@tempArr];
	}

	#showHashArray(\%myLayers);
	return %myLayers;
}

sub isStep {
	$job_name  = shift;
	$step_name = shift;
	if ( ( $job_name eq '' ) || ( $step_name eq '' ) ) {
		print "isStep(): Wrong parameters. \n";
		$text->insert( "end", "isStep(): Wrong parameters. \n" );
		$statusLabel = "Wrong parameters. \n";
		return 0;
	}

	$genesis->INFO(
		'entity_type' => 'job',
		'entity_path' => "$job_name",
		'data_type'   => 'steps_list'
	);
	@step_list = @{ $genesis->{doinfo}{gSTEPS_LIST} };
	for ( my $i = 0 ; $i <= $#step_list ; $i++ ) {
		if ( $step_list[$i] eq $step_name ) {
			return 1;
		}
	}
	return 0;
}

# function returns coordinates of superimposed pads in a hash array
# nothing is returned in case of error
sub getSIXrayPads {

	my $my_entity_path = shift;
	my @myTab          = split /\//, $my_entity_path;
	my $rs             = isStep( $myTab[0], $myTab[1] );    # job i step
	if ( $rs == 0 ) {
		$statusLabel = "Step '$step_name' does not exist.";
		return;
	}

	$genesis->INFO(
		units       => 'mm',
		entity_type => 'step',
		entity_path => "$job_name/$step_name",
		data_type   => 'REPEAT'
	);

	my @gREPEATstep = @{ $genesis->{doinfo}{gREPEATstep} };
	my @gREPEATxa   = @{ $genesis->{doinfo}{gREPEATxa} };
	my @gREPEATya   = @{ $genesis->{doinfo}{gREPEATya} };

	my %inspectaSIPads = ();                       # deklaracja hasz tabeli
	my @myXrayKeys = ( 'BL', 'TL', 'BR', 'TR' );

	my $j       = 0;
	my @tempArr = ();
	for ( my $i = 0 ; $i <= $#gREPEATstep ; $i++ ) {
		if ( $gREPEATstep[$i] eq 'xray' ) {
			@tempArr = ( $gREPEATxa[$i], $gREPEATya[$i] );

			# @tempArr must be in braces, when declaration outside the loop
			$inspectaSIPads{ $myXrayKeys[$j] } = [@tempArr];
			$j++;
		}
	}
	if ( $j == 0 ) {
		$text->insert( "end", "getSIXrayPads(): Missing xray-step \n",
			'errorline' );
		return;
	}

	return %inspectaSIPads;
}

# this function returns an etch-compensation as a number
# if etch-compensation has not been filled out, then its value get 'na'
# see the attribute: Etch_compensation in the Layer Attributes Popup of the Matrix
sub getEtchCompensation {
	my @myLayAttrName  = ();
	my @myLayAttrValue = ();

	$my_localEntityPath = shift;

	$genesis->INFO(
		'units'       => 'mm',
		'entity_type' => 'layer',
		'entity_path' => $my_localEntityPath,
		'data_type'   => 'ATTR'
	);

	@myLayAttrName  = @{ $genesis->{doinfo}{gATTRname} };
	@myLayAttrValue = @{ $genesis->{doinfo}{gATTRval} };

	for ( my $i = 0 ; $i <= $#myLayAttrName ; $i++ ) {
		if ( $myLayAttrName[$i] =~ /etch_comp/ ) {
			if ( $myLayAttrValue[$i] eq 'na' ) {
				return 0;
			}
			else {
				return $myLayAttrValue[$i];
			}
		}
	}
	return 0;
}

sub getLayerPadOffsets {

	my $my_entity_path = shift;
	my @myTab          = split /\//, $my_entity_path;
	my $rs             = isStep( $myTab[0], $myTab[1] );
	if ( $rs == 0 ) {
		$text->insert( "end",
			"Step '$step_name' does not exist. Program exits. \n" );
		return;
	}

	my $array_ref = shift;
	my @myCULays  = @{$array_ref};

	$myBasePad = 1000;    # 1000 + etch-compensation

	# get the array of etch-compensations
	my @myEtchCompArr = ();
	$step_name = "pcb";
	foreach my $myCULayer (@myCULays) {
		my $myEntityPath  = "$job_name/$step_name/$myCULayer";
		my $myLayEtchComp = getEtchCompensation($myEntityPath);
		push @myEtchCompArr, $myLayEtchComp;
	}

	my %myLocalXRAYCoords = ();    # a to i ofszem
	my @tempArray         = ();

	$step_name = "xray";
	for ( my $i = 0 ; $i <= $#myCULays ; $i++ ) {
		$my_entity_path = "$job_name/$step_name/$myCULays[$i]";
		my $myItemMM = $myBasePad + $myEtchCompArr[$i];
		@tempArray = getXY( $myItemMM, $my_entity_path );
		$myLocalXRAYCoords{ $myCULays[$i] } = [@tempArray];

		# clean the temporarry array
		@tempArray = ();
	}

	# showHashArray( \%myLocalXRAYCoords );
	return %myLocalXRAYCoords;
}

# function returns coordinates of inspecta pads
# in order of array: layer - corner - x - y
# the parameters:
#	hash-array of SI-pads and
#	hash-array of Inspecta offsets for each pad
sub getLayerXrayPads {

	my $array_ref           = shift;
	my %localInspectaSIPads = %{$array_ref};

	$array_ref = shift;
	my %localInspectaLayerPadOffsets = %{$array_ref};

	my %myLayerXrayPads = ();
	my $myKey, my $ilCoordsx, my $ilCoordsy;
	my @tempArray       = ();
	my $myAllignedLayer = '';

	foreach my $myLayer ( keys %localInspectaLayerPadOffsets ) {
		foreach my $myCorner ( keys %localInspectaSIPads ) {
			if ( ( $myCorner eq 'TR' ) || ( $myCorner eq 'BR' ) ) {
				$ilCoordsx =
				  $localInspectaSIPads{$myCorner}[0] -
				  $localInspectaLayerPadOffsets{$myLayer}[0];

				$ilCoordsy =
				  $localInspectaSIPads{$myCorner}[1] -
				  $localInspectaLayerPadOffsets{$myLayer}[1];
			}
			else {
				$ilCoordsx =
				  $localInspectaSIPads{$myCorner}[0] +
				  $localInspectaLayerPadOffsets{$myLayer}[0];

				$ilCoordsy =
				  $localInspectaSIPads{$myCorner}[1] +
				  $localInspectaLayerPadOffsets{$myLayer}[1];
			}

			# wstaw brakujace zero do nazwy warstwy
			$myAllignedLayer = $myLayer;
			if ( $myLayer !~ m/([0-9]{2})/ ) {
				$myAllignedLayer =~ s/([0-9])/0$1/;
			}

			push @tempArray, $myLayer;
			push @tempArray, $myCorner;
			push @tempArray, $ilCoordsx;
			push @tempArray, $ilCoordsy;

			# build the unique key
			$myKey = $myAllignedLayer . "_" . $myCorner;

			# the @tempArray declared outside the loop thus braces are used here
			$myLayerXrayPads{$myKey} = [@tempArray];
			@tempArray = ();
		}
	}

	#showHashArray(\%myLayerXrayPads);
	return %myLayerXrayPads;
}

# functions search matrix and checks if a parameter (a layer) is a copper layer
# if it is then 1 is returned, otherwise 0
sub isCULayer {

	my $myLayerIndex = shift;
	my $array_ref    = shift;
	my %mLayers      = %{$array_ref};

	# showHashArray(\%mLayers);
	# $text->insert( "end", "isCULayer(): \n");

	foreach $myLay ( keys %mLayers ) {
		if ( $mLayers{$myLay}[0] == $myLayerIndex ) {
			if (
				( $mLayers{$myLay}[2] eq 'board' )
				&& (   ( $mLayers{$myLay}[3] eq 'signal' )
					|| ( $mLayers{$myLay}[3] eq 'power_ground' )
					|| ( $mLayers{$myLay}[3] eq 'mixed' ) )
			  )
			{
				return 1;
			}
		}
	}
	return 0;
}

# function returns a position of a layer in the matrix
# paramaters: a layer name as string and a matrix as hash-array
sub getLayerIndex {

	my $myLocalLayer = shift;
	my $array_ref    = shift;
	my %mLayers      = %{$array_ref};

	foreach $myKey ( keys %mLayers ) {
		if ( $myKey eq $myLocalLayer ) {
			return $mLayers{$myKey}[0];    # row
		}
	}
	return -1;
}

# zwraca drill_start i drill_end w hash-tabeli dla wszystkich warstw wiercacych
# kluczem jest nazwa warstwy wiercacej
# palka w parametrze wywolania jako referencja!!!!!!!!!
sub getDrillStack {

	my %myStack        = ();
	my $my_entity_path = shift;
	my @myTab          = split /\//, $my_entity_path;

	my $rs = isStep( $myTab[0], $myTab[1] );
	if ( $rs == 0 ) {
		print "Step '$step_name' does not exist. Program exits. \n";
		return %myStack;
	}

	my $array_ref2 = shift;
	local @drillLayers = @{$array_ref2};

	my @tempArr = ();

	local $myDrillLayer = '';
	foreach $myDrillLayer (@drillLayers) {
		$my_entity_path = "$job_name/$step_name/$myDrillLayer";
		$genesis->INFO(
			'entity_type' => 'layer',
			'entity_path' => $my_entity_path,
			'data_type'   => 'DRL_START'
		);

		$genesis->INFO(
			'entity_type' => 'layer',
			'entity_path' => $my_entity_path,
			'data_type'   => 'DRL_END'
		);
		my $drl_start = $genesis->{doinfo}{gDRL_START};
		my $drl_end   = $genesis->{doinfo}{gDRL_END};

		@tempArr = ( $drl_start, $drl_end );

		$myStack{$myDrillLayer} = [@tempArr];
		@tempArr = ();
	}
	return %myStack;
}

# returns a list of drill-layers with start-end positions as a hash array
# parameters are: type, jobnumber_stepnumber as entity_path
sub getDrillLayers {

	my @dltArr = ( 'normal', 'laser', 'depth' );
	my $myDrillLayerType = shift;
	if (   ( $myDrillLayerType ne $dltArr[0] )
		&& ( $myDrillLayerType ne $dltArr[1] )
		&& ( $myDrillLayerType ne $dltArr[2] ) )
	{
		$text->insert( "end", "Drill layer type not allowed. \n" );
		$statusLabel = "Drill layer type not allowed";
		return -1;
	}

	my $my_entity_path = shift;
	my @myEntities = split /\//, $my_entity_path;

	my $job_number = $myEntities[0];
	my $step_name  = $myEntities[1];

	# read-in the whole matrix
	$genesis->INFO(
		entity_type => 'matrix',
		entity_path => "$job_number/matrix",
		data_type   => 'ROW'
	);

	my $total_rows = @{ $genesis->{doinfo}{gROWrow} };

	my $mRow;
	my $mLayerName;
	my $mLayerContext;
	my $mLayerType;
	my $mLayerSide;
	my @drillLayers = ();

	for ( $count = 0 ; $count <= $total_rows ; $count++ ) {
		$mRow          = ${ $genesis->{doinfo}{gROWrow} }[$count];
		$mLayerName    = ${ $genesis->{doinfo}{gROWname} }[$count];
		$mLayerContext = ${ $genesis->{doinfo}{gROWcontext} }[$count];
		$mLayerType    = ${ $genesis->{doinfo}{gROWlayer_type} }[$count];

		if ( ( $mLayerContext eq 'board' ) && ( $mLayerType eq 'drill' ) ) {
			push @drillLayers, $mLayerName;    # add name of layer to array
		}
	}

	my @myLayAttrName   = ();
	my @myLayAttrValue  = ();
	my @drillLayerArray = ();

	foreach my $myDrillLayer (@drillLayers) {
		$genesis->INFO(
			entity_type => 'layer',
			entity_path => "$job_number/$step_name/$myDrillLayer",
			data_type   => 'ATTR'
		);

		@myLayAttrName  = @{ $genesis->{doinfo}{gATTRname} };
		@myLayAttrValue = @{ $genesis->{doinfo}{gATTRval} };

		for ( my $i = 0 ; $i <= $#myLayAttrName ; $i++ ) {
			if ( $myLayAttrName[$i] =~ /drill_layer_type/ ) {
				if ( $myLayAttrValue[$i] =~ /$myDrillLayerType/ ) {
					push @drillLayerArray, $myDrillLayer;
				}
			}
		}
	}

	if ( $#drillLayerArray == -1 ) {
		$text->insert( "end",
"There aren't any drill layers of type $myDrillLayerType in this job. \n"
		);
		$statusLabel =
		  "Missing drill layers of type $myDrillLayerType in this job.";
		return 0;
	}

	my %myDrillStack = getDrillStack( $my_entity_path, \@drillLayerArray );
	if ( keys %myDrillStack == 0 ) {
		$text->insert( "end",
			"Error: Couldn't get start-end pair for drill layer. \n" );
		$statusLabel = "Couldn't get start-end pair for drill layer";
		return -1;
	}

	# showHashArray(\%myDrillStack);

	# get the whole matrix into a hash array
	my %myMatrix = getMatrix($job_number);

	my $startLayer,    my $endLayer;
	my $startLayerIdx, my $endLayerIdx;

	my @myLocalArray     = ();
	my %localDrillLayers = ();    # deklaracja tabeli

	foreach my $myDrillLayer ( keys %myDrillStack ) {

		$startLayer = $myDrillStack{$myDrillLayer}[0];
		$startLayerIdx = getLayerIndex( $startLayer, \%myMatrix );

		$endLayer = $myDrillStack{$myDrillLayer}[1];
		$endLayerIdx = getLayerIndex( $endLayer, \%myMatrix );

		my $rs = 0;
		while ( $startLayerIdx < $endLayerIdx ) {
			$rs = isCULayer( $startLayerIdx, \%myMatrix );
			if ( $rs == 1 ) {
				last;
			}
			$startLayerIdx++;
		}

		while ( $endLayerIdx > $startLayerIdx ) {
			$rs = isCULayer( $endLayerIdx, \%myMatrix );
			if ( $rs == 1 ) {
				last;
			}
			$endLayerIdx--;
		}

		push @myLocalArray, $startLayerIdx;
		push @myLocalArray, $endLayerIdx;

		$localDrillLayers{$myDrillLayer} = [@myLocalArray];
		@myLocalArray = ();
	}

	#showHashArray( \%localDrillLayers );
	return %localDrillLayers;
}

# function returns an array of layer names aquired by parameters:
# jobnumber and 2-value array with layer-start and layer-end
# usage: my @cuLays = getLayNameByIndex( $myLocalJobNumber, \@myLayFromToArray );
sub getLayNameByIndex {

	my $job_name         = shift;
	my $array_ref        = shift;
	my @myLayFromToArray = @{$array_ref};

	# 	must decrement by 1 because of matrix rows which starts with 0
	my $layerStart = $myLayFromToArray[0] - 1;
	my $layerEnd   = $myLayFromToArray[1] - 1;

	$genesis->INFO(
		entity_type => 'matrix',
		entity_path => "$job_name/matrix",
		data_type   => 'ROW'
	);

	my $mRow;
	my $mLayerName;
	my $mLayerContext;

	my @myLayerArray = ();
	for ( $layerStart .. $layerEnd ) {
		$mLayerName    = ${ $genesis->{doinfo}{gROWname} }[$_];
		$mLayerContext = ${ $genesis->{doinfo}{gROWcontext} }[$_];
		if ( $mLayerContext eq 'board' ) {
			push @myLayerArray, $mLayerName;    # add name of layer to array
		}
	}

	# showArray(\@myLayerArray);
	return @myLayerArray;
}

sub getGenesisXrayCoords {

	my $myLocalJobNumber = shift;
	my $myLocalStepName  = shift;

	my $array_ref             = shift;
	my @myLocalLayFromToArray = @{$array_ref};

	# we have to reject the outer layers as they don't participate on inspecta meassurement
	$myLocalLayFromToArray[0]++;
	$myLocalLayFromToArray[1]--;

	my @myLayerXrayPads = ();

	# get the xray coordinates for superimposed pads
	my $my_entity_path = "$myLocalJobNumber/$myLocalStepName";
	my %inspectaSIPads = getSIXrayPads($my_entity_path);
	if ( keys %inspectaSIPads == 0 ) {
		$text->insert( "end", "Error: Couldn't get inspectaSIPads. \n" );
		$statusLabel = "Couldn't get coordinates of superimposed pads";
		return @myLayerXrayPads;
	}

	#showHashArray(\%inspectaSIPads);

	my @cuLays =
	  getLayNameByIndex( $myLocalJobNumber, \@myLocalLayFromToArray );

	# $text->insert( "end", "cuLays[]: " . "\n" );
	# showArray(\@cuLays);

	# show me the offsets for XRAY pads (r1015) in xray step
	$my_entity_path = "$myLocalJobNumber/xray";
	my %inspectaLayerPadOffsets =
	  getLayerPadOffsets( $my_entity_path, \@cuLays );
	if ( keys %inspectaLayerPadOffsets == 0 ) {
		$text->insert( "end", "Error: Couldn't get inspecta pad offsets. \n" );
		$statusLabel = "Couldn't get inspecta pad offsets";
		return @myLayerXrayPads;
	}

	my %myLayXrayPads =
	  getLayerXrayPads( \%inspectaSIPads, \%inspectaLayerPadOffsets );

	# @myLayXrayPads: layer - corner - x - y
	my $left,      my $right,     my $top,       my $bottom;
	my $ABSposX11, my $ABSposY11, my $ABSposX12, my $ABSposY12;
	my $ABSposX21, my $ABSposY21, my $ABSposX22, my $ABSposY22;

	my $i = 0;
	my $myBLx, my $myBLy, my $myBRx, my $myBRy;
	my $myTLx, my $myTLy, my $myTRx, my $myTRy;

	my @tempArray        = ();
	my @myKeyGroup       = ();
	my %myLayXrayPadsRot = ();

	# by sorting we get the group of 4 corners on same layer
	# foreach $myKey ( sort keys %mySortedLayXrayPads ) {
	foreach $myKey ( sort keys %myLayXrayPads ) {
		@myKeyGroup = split /_/, $myKey;    # split by underscore
		if ( $myKeyGroup[1] eq 'BL' ) {
			$myBLx = $myLayXrayPads{$myKey}[2];
			$myBLy = $myLayXrayPads{$myKey}[3];
		}
		elsif ( $myKeyGroup[1] eq 'BR' ) {
			$myBRx = $myLayXrayPads{$myKey}[2];
			$myBRy = $myLayXrayPads{$myKey}[3];
		}
		elsif ( $myKeyGroup[1] eq 'TL' ) {
			$myTLx = $myLayXrayPads{$myKey}[2];
			$myTLy = $myLayXrayPads{$myKey}[3];
		}
		elsif ( $myKeyGroup[1] eq 'TR' ) {
			$myTRx = $myLayXrayPads{$myKey}[2];
			$myTRy = $myLayXrayPads{$myKey}[3];
		}

		else {
			$myBLx = 0;
			$myBLy = 0;
			$myBRx = 0;
			$myBRy = 0;
			$myTLx = 0;
			$myTLy = 0;
			$myTRx = 0;
			$myTRy = 0;
		}

		$i++;
		if ( $i % 4 == 0 ) {

			$left   = $myTLy - $myBLy;
			$right  = $myTRy - $myBRy;
			$top    = $myTRx - $myTLx;
			$bottom = $myBRx - $myBLx;

			$ABSposX11 = -$left / 2;
			$ABSposY11 = $bottom / 2;

			$ABSposX12 = $left / 2;
			$ABSposY12 = ( $top / 2 ) + 5;

			$ABSposX21 = -$right / 2;
			$ABSposY21 = -$bottom / 2;

			$ABSposX22 = $right / 2;
			$ABSposY22 = ( -$top / 2 ) + 5;

			push @tempArray, $ABSposX11;
			push @tempArray, $ABSposY11;
			push @tempArray, $ABSposX12;
			push @tempArray, $ABSposY12;

			push @tempArray, $ABSposX21;
			push @tempArray, $ABSposY21;
			push @tempArray, $ABSposX22;
			push @tempArray, $ABSposY22;

			# nie uzywac ponownie %myLayXrayPads !!!!
			$myLayXrayPadsRot{ $myKeyGroup[0] } = [@tempArray];
			@tempArray = ();

		}    # end if modulo
	}    # end foreach

	$statusLabel = "Got coordinates of XRAY-pads on each inner layer";

	# showHashArray(\%myLayXrayPadsRot);
	return %myLayXrayPadsRot;
}

sub getJobPPMs {

	my $myLocalJobNumber      = shift;
	my $myLocalStepName       = shift;
	my $myLocalDrillLayerName = shift;
	my $myLocalMDBName        = shift;

	# sprawdzenie co przychodzi
	$text->insert( "end",
		    "job:\t"
		  . $myLocalJobNumber . "\n"
		  . "step:\t"
		  . $myLocalStepName . "\n"
		  . "drill:\t"
		  . $myLocalDrillLayerName . "\n"
		  . "mdb:\t"
		  . $myLocalMDBName . "\n"
		  . "\n" );

	my @myPPMs = ();

	my $my_entity_path = "$myLocalJobNumber/$myLocalStepName";
	my %drillLays = getDrillLayers( 'normal', $my_entity_path );
	if ( keys %drillLays == 0 ) {
		$text->insert( "end", "Error: no drill layers has been found. \n" );
		$statusLabel = "No drill layers has been found";
		return @myPPMs;
	}

	my @myDrillStartEnd = @{ $drillLays{$myLocalDrillLayerName} };

	my %myXrayCoords =
	  getGenesisXrayCoords( $myLocalJobNumber, $myLocalStepName,
		\@myDrillStartEnd );
	if ( keys %myXrayCoords == 0 ) {
		$text->insert( "end", "Error: Couldn't get XRAY coordinates. \n" );
		$statusLabel = "Couldn't get coordinates of XRAY pads";
		return @myPPMs;
	}

	showHashArray(\%myXrayCoords );

	my @myLayStartEnd =
	  getLayNameByIndex( $myLocalJobNumber, \@myDrillStartEnd );
	
	showArray( \@myLayStartEnd );

	my $myFromLayer = $myLayStartEnd[0];
	my $myToLayer   = $myLayStartEnd[$#myLayStartEnd];

	# make the %myXrayCoords unique by delete of the same rows (comparing by coordinates)
	my $i = 0, my $j = 0;
	my $result             = 0;
	my $myEqualLayerNumber = 0;
	my @myLayerPair        = ();

	my @myLayerNames = keys %myXrayCoords;
	for ( $i = 0 ; $i <= $#myLayerNames ; $i++ ) {
		for ( $j = 0 ; $j <= $#myLayerNames ; $j++ ) {
			if ( $myLayerNames[$i] eq $myLayerNames[$j] ) {
				next;   # skip if layers are the same or type of outer (from-to)
			}
			$result = hashCompare( \%myXrayCoords, $myLayerNames[$i],
				$myLayerNames[$j] );
			if ( $result == 1 ) {
				delete $myXrayCoords{ $myLayerNames[$j] };
				$myLayerPair[$myEqualLayerNumber] =
				  $myLayerNames[$i] . "_" . $myLayerNames[$j];
				$myEqualLayerNumber++;
			}
		}
	}

	my $myLayerCounter = keys %myXrayCoords;

	# rewrite a hash-array to the linear array and by the same remove the keys
	my @myNomCoordinates = ();
	my @myTab            = ();
	my $k                = 0;
	my @myKeys           = sort keys %myXrayCoords;   # the keys MUST be sorted!
	for ( my $i = 0 ; $i <= $#myKeys ; $i++ ) {
		@myTab = @{ $myXrayCoords{ $myKeys[$i] } };
		for ( my $j = 0 ; $j <= $#myTab ; $j++ ) {
			$myNomCoordinates[$k] = $myTab[$j];
			$k++;
		}
	}

	my $myLayersFile = $myMDBName;

	# replace file-extension by a '_Layers.csv'
	$myLayersFile =~ (s/.mdb/_Layers.csv/g);
	my $myLayersPath = $ENV{GENESIS_TMP} . "/" . $myLayersFile;
	
	# read the csv-file into a memory array
	my $myCSVFILE;
	my $myStatus = open( $myCSVFILE, $myLayersPath );
	if ( !defined $myStatus ) {
		$text->insert( "end", "$!: $myLayersPath \n", 'errorline' );
		$statusLabel = "Cannot open file $myLayersFile";
		return @myPPMs;
	}
	my @data = <$myCSVFILE>;
	close $myCSVFILE;
	
	# showArray(\@data);
	

	my @myRow    = ();
	my @myLinear = ();
	my $m        = 0;
	my $test     = 0;

	# put the whole file into $myLinear array excluding rows with 0
	for ( my $j = 0 ; $j <= $#data ; $j++ ) {
		@myRow = split /;/, $data[$j];
		for ( my $i = 0 ; $i < 10 ; $i++ ) {
			$myRow[$i] =~ s/,/./g;    # replace a comma by a dot
			if ( $myRow[$i] == 0 ) {  # check every column for 0
				$test++;
				last;
			}
		}
		if ( $test == 0 ) {
			for ( my $i = 0 ; $i < 10 ; $i++ ) {
				$myLinear[$m] = $myRow[$i];    # add to array
				$m++;
			}
		}
		$test = 0;
	}
	
	# showArray(\@myLinear);


	# check if number of XRAY pads equals $myLayerCounter
	my $myPrevious = 0;
	my $myIndex    = 0;
	for ( my $j = 1 ; $j <= $#myLinear ; $j++ ) {
		$myIndex = ( ( $j - 1 ) * 10 ) + 1;    # 1 .. 11 .. 21 .. 31 .. 41
		if ( $myPrevious < $myLinear[$myIndex] ) {
			$myPrevious = $myLinear[$myIndex];
		}
	}

	if ( $myPrevious != $myLayerCounter ) {
		$text->insert(
			"end",
			"Different number of XRAY pads! \n"
			  . "The factors will be probably wrong. \n",
			"warningline"
		);
	}

	# excludes indexes 0, 1, 10, 11, 20, 21 ... from @myLinear
	my @myLinear2;
	my $n = 0;
	$i = 0;
	$j = 0;
	while ( $i <= $#myLinear ) {
		if ( ( $i == $n + 0 ) || ( $i == $n + 1 ) ) {
			$i++;
			next;    # ommits the rest
		}
		$myLinear2[$j] = $myLinear[$i];
		$j++;

		$i++;
		if ( $i % 10 == 0 ) {
			$n += 10;
		}
	}

	my $myPanelCounter =
	  ( $#myLinear + 1 ) / 10 / $myLayerCounter;    # 10 to ilosc kolumn
	if ( $myPanelCounter == 0 ) {
		$text->insert( "end",
			"The number of panels is 0. Thus calculation is not possible. \n",
			'errorline' );
		return -1;
	}

	####################
	# czas na statystyke
	
	# time	N_layer	ABSposX11	ABSposY11	ABSposX12	ABSposY12	ABSposX21	ABSposY21	ABSposX22	ABSposY22
	
	# 032x0013.1013
	# 098x0145.1712
	# 292x0477.1636
	
	
	# showArray(\@myNomCoordinates);	# $i
	# showArray(\@myLinear2);			# $j

	my @myStat = ();
	my $myTemp = 0;
	
	$i = 0;
	for ( my $j = 0 ; $j <= $#myLinear2 ; $j++ ) {
		if ($j % ($#myNomCoordinates + 1) == 0) {
			$i = 0;
		}
		$myTemp = round($myLinear2[$j] - $myNomCoordinates[$i], 3) * 1000;		# offset ma byc w mikronach
		push @myStat, $myTemp;
		$i++;
	}

	 showArray2(\@myStat);	
	


	
	##################



	# get an average of the sum particular for every layer in every column
	# and save it in an array where 0-7 is layer1, 8-15 is layer2 ...
	my @myAvgABSPos = ();
	my $myABSPosSum = 0;

	# every layer has 8 meassureable coordinates:
	# ABSposX11/ABSposY11	 ABSposX12/ABSposY12		ABSposX21/ABSposY21		ABSposX22/ABSposY22
	my $numberCoords = 8;
	for ( my $k = 0 ; $k < $myLayerCounter ; $k++ ) {
		for ( my $i = 0 ; $i < $numberCoords ; $i++ ) {
			$myABSPosSum = 0;
			$j = $i + ( $k * $numberCoords );
			do {
				$myABSPosSum += $myLinear2[$j];
				
				# $text->insert( "end", $myLinear2[$j] . "\n");
				
				$j += $myLayerCounter * $numberCoords;
			} while ( $j <= $#myLinear2 );
			$myAvgABSPos[ $i + ( $k * $numberCoords ) ] =
			  $myABSPosSum / $myPanelCounter;
		}
	}

	# get PPMs by divide
	my @myAvgPPMs = ();
	for ( my $i = 0 ; $i <= $#myAvgABSPos ; $i++ ) {
		$myAvgPPMs[$i] = $myAvgABSPos[$i] / $myNomCoordinates[$i];
	}

	my $myCommonPPM;
	my @myAvgCommonPPMs;
	for ( my $k = 0 ; $k < 8 ; $k++ ) {
		$myCommonPPM = 0;
		for ( my $i = 0 ; $i < $myLayerCounter ; $i++ ) {
			my $index = ( $i * 8 ) + $k;    # 0 - 8 - 1 - 9 - 2 - 10
			$myCommonPPM += $myAvgPPMs[$index];
		}
		$myAvgCommonPPMs[$k] = $myCommonPPM / $myLayerCounter . "\n";
	}

	my $myPPMx = 0;
	my $myPPMy = 0;

	# sum PPMx and PPMy respectivelly
	for ( my $j = 0 ; $j <= $#myAvgCommonPPMs ; $j++ ) {
		if ( $j % 2 == 0 ) {
			$myPPMx += $myAvgCommonPPMs[$j];
		}
		else {
			$myPPMy += $myAvgCommonPPMs[$j];
		}
	}

	@myPPMs = ();
	my $myPPMxRounded = 0;
	my $myPPMyRounded = 0;

	$myPPMx = ( ( $myPPMx / 4 ) - 1 ) * 1000000;
	$myPPMs[1] = getRounded($myPPMx);

	$myPPMy = ( ( $myPPMy / 4 ) - 1 ) * 1000000;
	$myPPMs[0] = getRounded($myPPMy);

	return @myPPMs;
}

sub getJobList {
	$genesis->INFO(
		entity_type => 'root',
		data_type   => 'JOBS_LIST'
	);
	return @{ $genesis->{doinfo}{gJOBS_LIST} };
}

# function returns 1 if file has been found, 0 otherwise
# parameters: #1. an array of file names, #2. a string with name of file to be searched through the array
sub fileExist {
	my $myListe      = shift;
	my @myArray      = @$myListe;
	my $mySearchFile = shift;

	for my $myFile (@myArray) {
		if ( $myFile eq '.' or $myFile eq '..' ) {
			next;    # get next file name
		}
		if ( $myFile eq $mySearchFile ) {
			return 1;
		}
	}
	return 0;
}

# this function is called when the calculation_button has been clicked
# before pressing on the calculation-button one has to choose the mdb-file and the right step
sub myCalcBtnCmd {

	$text->delete( "0.0", "end" );    # erase the text area

 # najpierw sprawdzic czy wszystkie 4 comboboxy sa wypelnione. Jak nie to kucha.
	if (   ( $myJobNumber eq '' )
		|| ( $myStepName eq '' )
		|| ( $myDrillLayerName eq '' )
		|| ( $myMDBName eq '' ) )
	{
		$text->insert( "end", "All fields must have been chosen!  $!\n",
			'errorline' );
		$statusLabel = "Some fields are empty.";
		return;
	}

	my @myScaleFactors =
	  getJobPPMs( $myJobNumber, $myStepName, $myDrillLayerName, $myMDBName );

	my $myPPMx = $myScaleFactors[0];
	my $myPPMy = $myScaleFactors[1];

	$text->insert( "end", "Komp. af boreprogram i X [ppm]: ");
			
	# show ranges for X
	if (   ( ( $myPPMx > 200 ) && ( $myPPMx <= 300 ) )
		|| ( ( $myPPMx < -200 ) && ( $myPPMx >= -300 ) ) )
	{
		$text->insert( "end", $myScaleFactors[0] . "\n", 'warningline' );
	}
	elsif (( ( $myPPMx > 300 ) && ( $myPPMx <= 400 ) )
		|| ( ( $myPPMx < -300 ) && ( $myPPMx >= -400 ) ) )
	{
		$text->insert( "end", $myScaleFactors[0] . "\n", 'warningline2' );
	}
	elsif (( ( $myPPMx > 400 ) && ( $myPPMx <= 500 ) )
		|| ( ( $myPPMx < -400 ) && ( $myPPMx >= -500 ) ) )
	{
		$text->insert( "end", $myScaleFactors[0] . "\n", 'warningline3' );
	}
	elsif ( ( $myPPMx > 500 ) || ( $myPPMx < -500 ) ) {
		$text->insert( "end", $myScaleFactors[0] . "\n", 'errorline' );
	}
	else {
		$text->insert( "end", $myScaleFactors[0] . "\n", 'successline' );
	}

	$text->insert( "end", "Komp. af boreprogram i Y [ppm]: ");
	# show ranges for Y
	if (   ( ( $myPPMy > 200 ) && ( $myPPMy <= 300 ) )
		|| ( ( $myPPMy < -200 ) && ( $myPPMy >= -300 ) ) )
	{
		$text->insert( "end", $myScaleFactors[1] . "\n", 'warningline' );
	}
	elsif (( ( $myPPMy > 300 ) && ( $myPPMy <= 400 ) )
		|| ( ( $myPPMy < -300 ) && ( $myPPMy >= -400 ) ) )
	{
		$text->insert( "end", $myScaleFactors[1] . "\n", 'warningline2' );
	}
	elsif (( ( $myPPMy > 400 ) && ( $myPPMy <= 500 ) )
		|| ( ( $myPPMy < -400 ) && ( $myPPMy >= -500 ) ) )
	{
		$text->insert( "end", $myScaleFactors[1] . "\n", 'warningline3' );
	}
	elsif ( ( $myPPMy > 500 ) || ( $myPPMy < -500 ) ) {
		$text->insert( "end", $myScaleFactors[1] . "\n", 'errorline' );
	}
	else {
		$text->insert( "end", $myScaleFactors[1] . "\n", 'successline' );
	}

	#showArray(\@myScaleFactors, 2);

	$statusLabel = "Enjoy your scale factors above";
}

# function checks if the right PRG file has been used on Inspecta machine (2nd. column in the quadrotti.csv)
# if the PRG equals to the job number the function returns 1, otherwise it will be 0.
# the parameter is the quadrotti.csv as string
sub checkUsedPrg {

	my $myLocalQuadFile = shift;
	my $myPRGFile = substr( $myLocalQuadFile, 0, 13 );
	
	# replace X with x in the *.mdb file
	$myPRGFile =~ s/X/x/;
	
	my $status = open( my $myINPUTFILE, $ENV{GENESIS_TMP} . "/" . $myLocalQuadFile );
	if ( !defined $status ) {
		$text->insert( "end", "$!: $myLocalQuadFile \n", 'errorline' );
		return 0;
	}
	my @data = <$myINPUTFILE>;    # read the file into the memory array
	close $myINPUTFILE;

	my @myLayers = ();
	my $mySum    = 0;
	for ( my $i = 0 ; $i <= $#data ; $i++ ) {
		@myLayers = split /;/, $data[$i];
		if ( substr( $myLayers[1], 0, 13 ) ne $myPRGFile ) {
			return 0;
		}
	}
	return 1;
}

sub chosen_mdbBE {

	$text->delete( "0.0", "end" );    # erase the text area

	if ( $myMDBName eq '' ) {
		$text->insert( "end", "MDB-file cannot be read.\n", 'errorline' );
		return -1;
	}

	$text->insert( "end", "You have chosen: $myMDBName\n" );
	$statusLabel = "Status: $myJobNumber/$myStepName/$myMDBName";

	my $myCustNumber   = substr( $myJobNumber, 0, 3 );
	my $myPath         = $myInspectaPath . $myCustNumber . "\\";
	my $myFullMDBName  = $myPath . $myMDBName;
	my $myMDBtoCSVProg = $myInspectaPath . 'MDBtoCSV.exe';         # .NET 2.0

	# open the local temporary folder  
	$myPath = $ENV{GENESIS_TMP};
	my $myStatus = opendir $myVERZ, $myPath;
	if ( !defined $myStatus ) {
		$text->insert( "end", "$!: $myPath \n", 'errorline' );
		$statusLabel = "Status: Cannot open directory";
		return -1;
	}

	my @liste = readdir($myVERZ);
	closedir $myVERZ;

	# $myMDBName should not be modified
	my $tempName = $myMDBName;
	$tempName =~ (s/.mdb/_/g);    # replace file-extension by an underscore
	my $destPath = $ENV{GENESIS_TMP} . "/" . $tempName;
	
	# $myLayersFile is a global variable
	my $myLayersFile = $tempName . 'Layers.csv';
	my $result = fileExist( \@liste, $myLayersFile );
	if ( $result != 1 ) {

	  # the CSV files are created in the local folder of the running perl-script
		my $myOutput = `$myMDBtoCSVProg $myFullMDBName $destPath`;
	}

	my $myLayersPath = $ENV{GENESIS_TMP} . "/" . $myLayersFile;

	# check the length of $myLayersFile
	my @stat = stat $myLayersPath;
	if ( $stat[7] == 0 ) {
		$text->insert(
			"end",
			"Error: The length of $myLayersFile is 0, \n"
			  . "thus the PPM calculation is not possible.\n",
			'errorline'
		);

		# disable the button
		$myButton->configure( -state => 'disabled' );
		return;
	}

	# check if right PRG has been used
	my $myQuadPath = substr( $myMDBName, 0, -4 ) . "_Quadrotti.csv";
	my $rs = checkUsedPrg($myQuadPath);
	if ( $rs != 1 ) {
		$text->insert( "end", "A wrong PRG used in the $myMDBName. \n",
			'warningline' );
		$myMDBName = "";
		$myButton->configure( -state => 'disabled' );
	}
	else {
		# finally enable the button
		$myButton->configure( -state => 'normal' );
		$text->insert( "end", "$myLayersFile \nhas been prepared.\n" );
	}
}

sub getMDBList {

	$myJobNumber      = shift;
	$myCustNumber     = substr( $myJobNumber, 0, 3 );
	$myShortJobNumber = substr( $myJobNumber, 0, 8 );
		$text->insert( "end", "myShortJobNumber: " . $myShortJobNumber . "\n" );

	my @liste = ();

	my $myPath = $myInspectaPath . $myCustNumber;
	my $myStatus = opendir $myVERZ, $myPath;

	# check read status
	if ( !defined $myStatus ) {
		$text->insert( "end", "$!: $myPath \n", 'errorline' );
		$statusLabel = "Status: $!";
		return @liste;
	}

	@liste = readdir($myVERZ);    # @liste to pliki mdb
	closedir $myVERZ;
	my $listeLn = $#liste;

	# choose mdb-files corresponding to the jobnumber (no case sensitive)
	my $mySubFile = "";
	for ( my $i = 0 ; $i <= $listeLn ; $i++ ) {
		if ( $liste[$i] !~ /$myShortJobNumber/i ) {
			delete $liste[$i];    # delete does not shift array
		}
	}

	# return if list empty
	if ( $#liste < 0 ) {
		return @liste;
	}

	# rewrite list removing undefined cells
	my @resultList = ();
	my $j          = 0;
	for ( my $i = 0 ; $i <= $#liste ; $i++ ) {
		if ( defined $liste[$i] ) {
			$resultList[$j] = $liste[$i];
			$j++;
		}
	}
	return @resultList;
}

sub chosen_drillBE {

	# delete mdb-comboboxes
	$mdbBE->delete( 0, 'end' );
	$myButton->configure( -state => 'disabled' );

	$myJobNumber =~ s/\s//g;    # remove any white space

	my @myMDBList = getMDBList( $myJobNumber, $myStepName );
	if ( $#myMDBList < 0 ) {
		$text->insert(
			"end",
			"Error: MDB list is empty. \n"
			  . "Please choose another job-number.\n",
			'errorline'
		);
		$statusLabel = "MDB-list empty.";
		return;
	}

	# fill out the browseentry (MDBList)
	my $mdbName;
	foreach $mdbName ( sort @myMDBList ) {
		$mdbBE->insert( "end", $mdbName );
	}

	# show last element
	$myMDBName = $mdbName;

	$statusLabel = "Status: Now choose a MDB file";
	$text->insert( "end",
		"The drill layer $myDrillLayerName has been chosen.\n" );

	# move focus to next field
	$mdbBE->focusNext;
	Tk->break;

}

sub chosen_stepBE {

	# delete drill- and mdb-comboboxes
	$drillBE->delete( 0, 'end' );
	$mdbBE->delete( 0, 'end' );
	$myButton->configure( -state => 'disabled' );
	$myJobNumber =~ s/\s//g;    # remove any white space

	############
	my $my_entity_path = "$myJobNumber/$myStepName";
	my %drillLays = getDrillLayers( 'normal', $my_entity_path );
	if ( keys %drillLays == 0 ) {
		$text->insert( "end", "Error: no drill layers has been found. \n" );
		$statusLabel = "No drill layers has been found";
		return;
	}

	# fill out the browseentry
	my $drillLayerName;
	foreach $drillLayerName ( sort keys %drillLays ) {
		$drillBE->insert( "end", $drillLayerName );
	}

	$myDrillLayerName = $drillLayerName;

	$statusLabel = "Status: $myJobNumber/$myStepName";
	$text->insert( "end", "The step " . $myStepName . " has been read. \n" );

	# move focus to next field
	$drillBE->focusNext;
	Tk->break;
}

sub chosen_jobBE {

	$stepBE->delete( 0, 'end' );
	$drillBE->delete( 0, 'end' );
	$mdbBE->delete( 0, 'end' );

	$text->delete( "0.0", "end" );    # erase the text area
	$myButton->configure( -state => 'disabled' );

	# now clear the global variables
	$myStepName       = '';
	$myDrillLayerName = '';
	$myMDBName        = '';

	$myJobNumber =~ s/\s//g;          # remove any white space

	# check if jobname is a multilayer
	if (   ( substr( $myJobNumber, 3, 1 ) ne 'x' )
		&& ( substr( $myJobNumber, 3, 1 ) ne 'X' ) )
	{
		$text->insert(
			"end",
			"The job " . $myJobNumber . " is not a multilayer job. Try another job.\n", 'warningline'
		);
		$statusLabel = "Status: Not a multilayer";
		return;
	}

	#######
	@mySteps = getStepList($myJobNumber);

	# check step number
	if ( $#mySteps == -1 ) {
		$text->insert( "end",
			"The job " . $myJobNumber . " has not any steps. \n",
			'warningline' );
		$statusLabel = "Status: no steps found.";
		return;
	}

	# fill out the browseentry
	my $stepName;
	foreach $stepName (@mySteps) {
		$stepBE->insert( "end", $stepName );
	}

	# show last element
	$myStepName = $stepName;

	# move focus to next field
	$stepBE->focusNext;
	Tk->break;
}

sub getStepList {

	my $localJobNumber = shift;
	my @stepList       = ();

	if ( $localJobNumber eq '' ) {
		print("getStepList(): Missing parameter. \n");
		$text->insert( "end", "getStepList(): Missing parameter. \n" );
		return @stepList;
	}

	$statusLabel = "Status: job reading...";

	# the window-update is necessary here, because the program seems to freese when reading huge jobs
	$text->insert( "end",
		'The job ' . $localJobNumber . " is reading now.. \nBe patient. \n" );
	$myFrame->update;

	$genesis->INFO(
		entity_type => 'job',
		entity_path => $localJobNumber,
		data_type   => 'STEPS_LIST'
	);

	$text->insert( "end", "The job " . $localJobNumber . " has been read. \n" );
	$statusLabel = "Status: Successful with reading.";

	return @{ $genesis->{doinfo}{gSTEPS_LIST} };
}

sub myAbout {

	my $tp = $myFrame->Toplevel( -title => ' About' );
	my $x = $myFrame->rootx + 60;
	my $y = $myFrame->rooty + 100;
	$tp->geometry("240x340+$x+$y");

	my $myLogoFile = "logo.png";

	# create PNG file if it does not exist
	if ( !-e $myLogoFile ) {
		my @myPNGData = (
			0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00,
			0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x64,
			0x00, 0x00, 0x00, 0x64, 0x08, 0x02, 0x00, 0x00, 0x00, 0xFF,
			0x80, 0x02, 0x03, 0x00, 0x00, 0x00, 0x01, 0x73, 0x52, 0x47,
			0x42, 0x00, 0xAE, 0xCE, 0x1C, 0xE9, 0x00, 0x00, 0x00, 0x04,
			0x67, 0x41, 0x4D, 0x41, 0x00, 0x00, 0xB1, 0x8F, 0x0B, 0xFC,
			0x61, 0x05, 0x00, 0x00, 0x00, 0x09, 0x70, 0x48, 0x59, 0x73,
			0x00, 0x00, 0x0E, 0xC3, 0x00, 0x00, 0x0E, 0xC3, 0x01, 0xC7,
			0x6F, 0xA8, 0x64, 0x00, 0x00, 0x04, 0x20, 0x49, 0x44, 0x41,
			0x54, 0x78, 0x5E, 0xED, 0x92, 0xD1, 0x8D, 0xDC, 0x48, 0x0C,
			0x05, 0x1D, 0xCB, 0xC5, 0xE3, 0x60, 0xBD, 0x39, 0xDD, 0xBF,
			0x81, 0x4B, 0xE0, 0xDC, 0xC0, 0xBC, 0x67, 0xD0, 0xD5, 0xA3,
			0x1E, 0x52, 0xD2, 0xEC, 0x42, 0x32, 0x0B, 0xF5, 0x61, 0x63,
			0xD8, 0x24, 0x54, 0xD8, 0x6F, 0xFF, 0x7C, 0x7C, 0x6F, 0x93,
			0x76, 0xAC, 0x82, 0x1D, 0xAB, 0x60, 0xC7, 0x2A, 0xD8, 0xB1,
			0x0A, 0x76, 0xAC, 0x82, 0x1D, 0xAB, 0x60, 0xC7, 0x2A, 0xD8,
			0xB1, 0x0A, 0x76, 0xAC, 0x82, 0x1D, 0xAB, 0x60, 0xC7, 0x2A,
			0xD8, 0xB1, 0x0A, 0x76, 0xAC, 0x82, 0xE5, 0x58, 0xDF, 0xEA,
			0x60, 0xC3, 0x75, 0xAD, 0x7D, 0x89, 0xBE, 0xBE, 0x0E, 0xF6,
			0x5C, 0xD4, 0xC2, 0x67, 0xE8, 0xBB, 0x77, 0x81, 0x55, 0x9F,
			0xA0, 0x0E, 0x9F, 0x7A, 0xFA, 0x9E, 0xB1, 0x74, 0xD5, 0xE0,
			0xD7, 0xDD, 0x76, 0xAC, 0x82, 0xFB, 0x63, 0xFD, 0xFF, 0xDF,
			0x4A, 0x80, 0x55, 0x6F, 0x55, 0x27, 0xFF, 0x04, 0x33, 0xFB,
			0xEC, 0x58, 0x05, 0xEF, 0x16, 0x4B, 0xF7, 0x9E, 0x81, 0xC9,
			0x1D, 0x76, 0xAC, 0x82, 0x1D, 0xAB, 0xE0, 0xAD, 0x62, 0xE9,
			0xD8, 0x36, 0x98, 0xAF, 0x7A, 0xE7, 0x58, 0x3F, 0xFF, 0xFD,
			0xA1, 0x7F, 0x19, 0xCC, 0x57, 0xBD, 0x4F, 0x2C, 0x5D, 0x0A,
			0xCC, 0xB1, 0x06, 0x78, 0x55, 0xF2, 0xB6, 0xB1, 0x46, 0xA9,
			0x87, 0xFA, 0xBF, 0xC1, 0xAB, 0x92, 0x37, 0x89, 0xA5, 0x33,
			0x81, 0xAD, 0x58, 0x03, 0xBC, 0xCD, 0x7B, 0xCF, 0x58, 0xBF,
			0x4B, 0x3D, 0xED, 0x85, 0xB7, 0x79, 0x3B, 0x56, 0xC1, 0x3B,
			0xC4, 0xD2, 0x8D, 0xC0, 0x3A, 0xD6, 0x00, 0x1B, 0x92, 0xDE,
			0x30, 0x16, 0x4A, 0x3D, 0xD4, 0x6F, 0x06, 0x1B, 0x92, 0x5E,
			0x3E, 0x96, 0x0E, 0x04, 0x90, 0xE9, 0xA1, 0x7E, 0x0B, 0x60,
			0x4F, 0xC6, 0xBB, 0xC5, 0x42, 0xA3, 0xA8, 0x26, 0x0C, 0xF6,
			0x64, 0xBC, 0x76, 0x2C, 0x6D, 0x0F, 0x20, 0x50, 0x54, 0x13,
			0x01, 0x6C, 0x7B, 0xE9, 0xAD, 0x62, 0xA1, 0xCE, 0xAC, 0xE6,
			0x0C, 0xB6, 0xBD, 0xF4, 0xC2, 0xB1, 0xB4, 0x3A, 0x80, 0x34,
			0xB3, 0x9A, 0x0B, 0x60, 0xE7, 0xDA, 0xBF, 0x2B, 0xD6, 0x50,
			0xA3, 0x06, 0x3B, 0xD7, 0xDE, 0x27, 0x16, 0xA2, 0x6C, 0xA9,
			0x69, 0x83, 0x9D, 0x6B, 0xAF, 0x1A, 0x4B, 0x7B, 0x03, 0x88,
			0xB2, 0xA5, 0xA6, 0x03, 0xD8, 0xBC, 0xF0, 0x26, 0xB1, 0x50,
			0x64, 0xAD, 0xDE, 0x18, 0x6C, 0x5E, 0x78, 0xC9, 0x58, 0x5A,
			0x1A, 0x40, 0x8E, 0xB5, 0x7A, 0x13, 0xC0, 0xFE, 0x2D, 0xEF,
			0x10, 0x0B, 0x2D, 0x32, 0xEA, 0xA5, 0xC1, 0xFE, 0x2D, 0xAF,
			0x17, 0x4B, 0x1B, 0x03, 0x08, 0x91, 0x51, 0x2F, 0x03, 0xB8,
			0xF2, 0xD4, 0xD5, 0x90, 0xD6, 0x6C, 0x80, 0x3A, 0x70, 0x0D,
			0x0E, 0x95, 0xD4, 0x0A, 0x83, 0x0A, 0x79, 0xF5, 0xDE, 0xE0,
			0xCA, 0x53, 0x37, 0x87, 0xB4, 0x63, 0x1B, 0xD4, 0x81, 0x19,
			0x70, 0x31, 0xA9, 0x1E, 0x1B, 0x24, 0xC8, 0xAB, 0xF7, 0x06,
			0x57, 0x9E, 0xFA, 0x7C, 0x48, 0x0B, 0x96, 0xA0, 0x0E, 0x4C,
			0x82, 0xBB, 0x2F, 0xD5, 0xB3, 0x00, 0x12, 0xE4, 0xD5, 0xFB,
			0x00, 0x6E, 0xCD, 0xBE, 0x2B, 0xD6, 0x30, 0x03, 0xEE, 0xBE,
			0x54, 0xCF, 0x36, 0x40, 0x8E, 0x59, 0xCD, 0x6D, 0x80, 0x5B,
			0xB3, 0x57, 0x8A, 0xA5, 0x37, 0x4B, 0x50, 0x27, 0xAA, 0x89,
			0x25, 0xB8, 0x08, 0x37, 0x7F, 0xD6, 0xEB, 0x00, 0x5A, 0xEC,
			0x10, 0xE0, 0xE2, 0x4B, 0xF5, 0x6C, 0x09, 0x02, 0x45, 0x35,
			0xB1, 0x04, 0x17, 0xE1, 0xE7, 0xC5, 0x9A, 0xC1, 0xC5, 0x97,
			0xEA, 0xD9, 0x12, 0x04, 0x8A, 0x6A, 0x62, 0x09, 0x2E, 0xC2,
			0xD5, 0xCF, 0x5A, 0x60, 0xF0, 0xF1, 0x55, 0x01, 0x6E, 0x25,
			0xD5, 0xE3, 0x6D, 0x10, 0x28, 0xAA, 0x89, 0x6D, 0x70, 0x6B,
			0xB6, 0x10, 0x6B, 0x80, 0xEF, 0xCF, 0x3B, 0x83, 0x5B, 0xBB,
			0xD5, 0x3A, 0x83, 0x40, 0x51, 0x4D, 0x18, 0xEC, 0xC9, 0xF8,
			0xE2, 0x8D, 0x16, 0x1B, 0x24, 0xC8, 0x0B, 0x70, 0xE5, 0x88,
			0xDA, 0x68, 0x10, 0x28, 0xAA, 0x09, 0x83, 0x3D, 0x19, 0x6B,
			0xB1, 0x06, 0xA8, 0x90, 0x71, 0x06, 0x57, 0x8E, 0xA8, 0x8D,
			0x06, 0x81, 0xA2, 0x9A, 0x30, 0xD8, 0x93, 0xF1, 0xF5, 0x1B,
			0xED, 0x36, 0x08, 0x91, 0x11, 0x60, 0xFF, 0x41, 0xB5, 0xD4,
			0x20, 0x50, 0x54, 0x13, 0x06, 0x7B, 0x32, 0x96, 0x63, 0x0D,
			0xD0, 0x62, 0xED, 0x0C, 0xF6, 0x1F, 0x54, 0x4B, 0x0D, 0x02,
			0x45, 0x35, 0x61, 0xB0, 0x27, 0x63, 0xEA, 0x8D, 0xD6, 0x1B,
			0xE4, 0x58, 0x0B, 0xB0, 0xF9, 0xB8, 0xDA, 0x6B, 0x10, 0x28,
			0xAA, 0x09, 0x83, 0x3D, 0x19, 0xF7, 0xC4, 0x1A, 0xA0, 0xC8,
			0x96, 0x33, 0xD8, 0x7C, 0x5C, 0xED, 0x35, 0x08, 0x14, 0xD5,
			0x84, 0xC1, 0x9E, 0x8C, 0xD9, 0x37, 0xBA, 0x60, 0x10, 0x65,
			0x4B, 0x80, 0x9D, 0xA7, 0xA8, 0xD5, 0x06, 0x81, 0xA2, 0x9A,
			0x30, 0xD8, 0x93, 0x71, 0x67, 0xAC, 0x01, 0xBA, 0xCC, 0xCE,
			0x60, 0xE7, 0x29, 0x6A, 0xB5, 0x41, 0xA0, 0xA8, 0x26, 0x0C,
			0xF6, 0x64, 0x2C, 0xBC, 0xD1, 0x11, 0x83, 0x34, 0xB3, 0x00,
			0xDB, 0xCE, 0x52, 0xDB, 0x0D, 0x02, 0x45, 0x35, 0x61, 0xB0,
			0x27, 0xE3, 0xFE, 0x58, 0x03, 0xD4, 0x89, 0xCE, 0x60, 0xDB,
			0x59, 0x6A, 0xBB, 0x41, 0xA0, 0xA8, 0x26, 0x0C, 0xF6, 0x64,
			0xAC, 0xBD, 0xD1, 0x1D, 0x83, 0x40, 0x51, 0x80, 0x3D, 0x27,
			0xAA, 0x03, 0x06, 0x81, 0xA2, 0x9A, 0x30, 0xD8, 0x93, 0xF1,
			0x50, 0xAC, 0x01, 0x1A, 0x3D, 0x9C, 0xC1, 0x9E, 0x13, 0xD5,
			0x01, 0x83, 0x40, 0x51, 0x4D, 0x18, 0xEC, 0xC9, 0x58, 0x7E,
			0xA3, 0x53, 0x06, 0x99, 0x1E, 0xCE, 0x60, 0xC9, 0x89, 0xEA,
			0x80, 0x41, 0xA0, 0xA8, 0x26, 0x0C, 0xF6, 0x64, 0x3C, 0x1A,
			0x6B, 0xF0, 0x85, 0xA5, 0x86, 0xBA, 0x61, 0x10, 0x28, 0xAA,
			0x09, 0x83, 0x3D, 0x19, 0x3B, 0x56, 0xC1, 0x5D, 0x6F, 0x26,
			0x16, 0xB1, 0xF0, 0xF6, 0x74, 0x75, 0xC6, 0x20, 0x50, 0x54,
			0x13, 0x06, 0x7B, 0x32, 0x9E, 0x1C, 0x6B, 0x06, 0x6F, 0x4F,
			0x57, 0x67, 0x0C, 0x02, 0x45, 0x35, 0x61, 0xB0, 0x27, 0xE3,
			0xCE, 0x8F, 0xD1, 0xC1, 0xC0, 0x97, 0xFC, 0x59, 0x0D, 0x75,
			0xC9, 0x20, 0x50, 0x54, 0x13, 0x06, 0x7B, 0x32, 0x9E, 0x19,
			0x6B, 0x06, 0xAF, 0xDE, 0xA1, 0x2E, 0x19, 0x04, 0x8A, 0x6A,
			0xC2, 0x60, 0x4F, 0xC6, 0xFD, 0xDF, 0xA3, 0x9B, 0xE6, 0x4B,
			0xFE, 0xAC, 0x86, 0x3A, 0x66, 0x10, 0x28, 0xAA, 0x09, 0x83,
			0x3D, 0x19, 0x4F, 0x8B, 0x35, 0x83, 0xF9, 0x37, 0xA9, 0x63,
			0x06, 0x81, 0xA2, 0x9A, 0x30, 0xD8, 0x93, 0xF1, 0xD0, 0x27,
			0xE9, 0xEC, 0x33, 0x30, 0xF9, 0x3E, 0x75, 0xCF, 0x20, 0x50,
			0x54, 0x13, 0x06, 0x7B, 0x32, 0x76, 0xAC, 0x82, 0x47, 0xBF,
			0x4A, 0x97, 0xFF, 0x04, 0x33, 0x6F, 0x55, 0x27, 0x0D, 0x02,
			0x45, 0x35, 0x61, 0xB0, 0x27, 0x63, 0xC7, 0x2A, 0x78, 0xC2,
			0x87, 0xE9, 0xB8, 0xC1, 0xAF, 0xEF, 0x56, 0x57, 0x0D, 0x02,
			0x45, 0x35, 0x61, 0xB0, 0x27, 0xE3, 0xDD, 0x62, 0xE5, 0xC1,
			0x9E, 0x8C, 0xE7, 0x7C, 0x9B, 0xEE, 0x7F, 0x7A, 0xA9, 0xA1,
			0x0E, 0xD7, 0xC1, 0x9E, 0x8C, 0x5F, 0xF0, 0x79, 0xE7, 0xAA,
			0x4F, 0xAF, 0x83, 0x3D, 0x19, 0x3B, 0x56, 0xC1, 0xCB, 0xC7,
			0x1A, 0xEA, 0xEB, 0x2B, 0x60, 0x43, 0xD2, 0x3B, 0xC4, 0xFA,
			0x34, 0x3B, 0x56, 0xC1, 0x8E, 0x55, 0xB0, 0x63, 0x15, 0xEC,
			0x58, 0x05, 0x3B, 0x56, 0xC1, 0x8E, 0x55, 0xB0, 0x63, 0x15,
			0xEC, 0x58, 0x05, 0x3B, 0x56, 0xC1, 0x8E, 0x55, 0xB0, 0x63,
			0x15, 0xEC, 0x58, 0x05, 0x3B, 0x56, 0xC1, 0x8E, 0x95, 0xF6,
			0xE3, 0xFB, 0x2F, 0xD2, 0x63, 0x8E, 0x5B, 0xB7, 0x5B, 0xAC,
			0x05, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
			0x42, 0x60, 0x82
		);
	
		my $OUT = new FileHandle;
		open( $OUT, ">$myLogoFile" );
	
		# should not parse new lines (0D-0A)
		binmode $OUT;
	
		# write binaries from @myPNGData to the file
		print $OUT pack( 'C*', @myPNGData );
		$OUT->close;
		print "png file created. \n";
	}

	#my $image = $myFrame->Photo( -file => $myLogoFile );    
	#$tp->Label( -image => $image )
	#  ->pack( -side => 'top', -padx => 10, -pady => 10 );

	$tp->Label(
		-font => "Verdana 10 normal",
		-text => 'The script calculates scale factors for drill data'
		  . ' by using of the corresponding (m)DB-file from the Inspecta machine',
		-wraplength => 220
	)->pack( -side => 'top', -padx => 10, -pady => 10 );

	$tp->Label(
		-font       => "Verdana 8 normal",
		-text       => 'For comments please write to pkr@pridana.dk',
		-wraplength => 220
	)->pack( -side => 'bottom', -padx => 10, -pady => 10 );

	my $tpbtn = $tp->Button(
		-width   => 15,
		-borderwidth => 3, 
		-activebackground => 'light sky blue',
		-font => "Verdana 10 normal",
		-text    => '   Close   ',
		-command => [ $tp => 'destroy' ],
	)->pack( -side => 'bottom', -padx => 10, -pady => 10 );

	$tpbtn->focus;
}

sub mySettings {

	$text->delete( "0.0", "end" );    # erase the text area
	$text->insert( "end", "Sorry. Not implemented yet. \n" );
	$statusLabel = "Settings are not implemented yet :-)";
	
}

sub myExit {
	
	my $myAnswer = $myFrame->messageBox(
		-message		=> 'Do you want to exit?',
		-title          => 'Quit?',
		-type			=> 'YesNo',
		#-default 		=> 'No',
		-icon			=> 'question'
	);

	if ( $myAnswer =~ /y/i ) {
		exit(0);
	}
	else {
		return;
	}
}

############################ MAIN ############################

use FindBin '$RealBin';
chdir $RealBin or warn "Cannot chdir to $RealBin because: $!";

$genesis = new Genesis;
@myJobs  = getJobList();
myGUIInit();

MainLoop();

# end of script
