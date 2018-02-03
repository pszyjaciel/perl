#!c:/Perl/bin/perl -w 

# c:\genesis\help\pdf\0203\0203.pdf
# c:\genesis\help\pdf\0204\0204.pdf
# c:\genesis\help\pdf\0205\0205.pdf
# c:\genesis\help\pdf\0206\0206.pdf (!)

#http://www.frontline-pcb.com/support/genesis/articles/scripting/infowiz/infowiz.html
#https://www.frontline-pcb.com/register.html

# directory: c:/Users/pkr.PRIDANA/.genesis/scripts/
# script: myGenesis2.pl

use Tk;
use Genesis;
require Tk::Dialog;

#use diagnostics -verbose;
#use strict;

sub showMessageBox {
	my $myTitle = shift;
	my $myText  = shift;
	my $mw      = new MainWindow;
	$mw->withdraw();

	my $reponse_messageBox = $mw->messageBox(
		-icon    => 'info',
		-title   => $myTitle,
		-type    => 'OK',
		-message => $myText,
	);
}

sub showYesNoMessageBox {
	my $myTitle = shift;
	my $myText  = shift;
	my $mw      = new MainWindow;
	$mw->withdraw();

	my $reponse_messageBox = $mw->messageBox(
		-icon    => 'question',
		-title   => $myTitle,
		-type    => 'yesno',
		-message => $myText,
	);
	return $reponse_messageBox;
}

sub exit_script {
	showMessageBox( "Exit", "Program exits." );
	exit(0);
}

############################ MAIN ############################

print "---------- script starts here --------- \n\n";
$f = new Genesis;
$f->VON;

#$f->PAUSE("dupa");

#c:\genesis\help\pdf\0203\0203.pdf p. 157
$_genesis_root = $ENV{GENESIS_DIR};
print $_genesis_root . "\n";

$_genesis_edir = $ENV{GENESIS_EDIR};
print $_genesis_edir . "\n";

$_genesis_ver = $ENV{GENESIS_VER};
print $_genesis_ver . "\n";

$_genesis_tmp = $ENV{GENESIS_TMP};
print $_genesis_tmp . "\n";

print $ENV{DISPLAY} . "\n";
print $ENV{GENESIS_FONTSIZE} . "\n";
print $ENV{GENESIS_HELP_DIRS} . "\n";
print $ENV{GENESIS_XSERVER} . "\n";
print $ENV{HOME} . "\n";

#my $job_name = $ENV{JOB};
#if ( !defined $job_name ) {
#	showMessageBox( "Error", "undefined variable." );
#	exit(0);
#}

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

$f->VON;

$myInfo = $f->INFO(
	entity_type => 'job',
	entity_path => "$job_name",
	data_type   => 'FORMS_LIST'
);

# moze ilosc elementow zwracanych (tu: 1 czyli jedna tablica)
print "myInfo1: " . $myInfo . "\n";

@myFORMS_LIST = $f->{doinfo}{gFORMS_LIST};
print "myFORMS_LIST[0]: " . $myFORMS_LIST[0] . "\n";
print "myFORMS_LIST[0][0]: " . $myFORMS_LIST[0][0] . "\n";

#teras to:
#DO_INFO_MM -t step -e $JOB/panel -d PROF_LIMITS
#set pan_x_size = `echo $gPROF_LIMITSxmin $gPROF_LIMITSxmax | gawk -F' ' '{print ($2 - $1) - 16}'`
#set pan_y_size = `echo $gPROF_LIMITSymin $gPROF_LIMITSymax | gawk -F' ' '{print ($2 - $1) - 16}'`

my $step_name = "panel";
$f->INFO(
	'units'         => 'mm',
	'entity_type'   => 'step',
	'entity_path'   => "$job_name/$step_name",
	'output_method' => 'display',
	'data_type'     => 'PROF_LIMITS'
);

$xmin = $f->{doinfo}{gPROF_LIMITSxmin};
$xmax = $f->{doinfo}{gPROF_LIMITSxmax};
$ymin = $f->{doinfo}{gPROF_LIMITSymin};
$ymax = $f->{doinfo}{gPROF_LIMITSymax};
print( "xmin: " . $xmin . " xmax: " . $xmax . "\n" );
print( "ymin: " . $ymin . " ymax: " . $ymax . "\n" );

#########
#DO_INFO_MM -t step -e $JOB/panel -d SR

$step_name = "panel";
$f->INFO(
	units       => 'mm',
	entity_type => 'step',
	entity_path => "$job_name/$step_name",
	data_type   => 'SR'
);

my @gSRstep   = @{ $f->{doinfo}{gSRstep} };
my @gSRxa     = @{ $f->{doinfo}{gSRxa} };
my @gSRya     = @{ $f->{doinfo}{gSRya} };
my @gSRdx     = @{ $f->{doinfo}{gSRdx} };
my @gSRdy     = @{ $f->{doinfo}{gSRdy} };
my @gSRnx     = @{ $f->{doinfo}{gSRnx} };
my @gSRny     = @{ $f->{doinfo}{gSRny} };
my @gSRangle  = @{ $f->{doinfo}{gSRangle} };
my @gSRmirror = @{ $f->{doinfo}{gSRmirror} };
my @gSRxmin   = @{ $f->{doinfo}{gSRxmin} };
my @gSRymin   = @{ $f->{doinfo}{gSRymin} };
my @gSRxmax   = @{ $f->{doinfo}{gSRxmax} };
my @gSRymax   = @{ $f->{doinfo}{gSRymax} };

#print "length: " . $#gSRxa . "\n";

for ( my $i = 0 ; $i < $#gSRxa ; $i++ ) {
	print(  $gSRstep[$i] . "\t"
		  . $gSRxa[$i] . "\t"
		  . $gSRya[$i] . "\t"
		  . $gSRdx[$i] . "\t"
		  . $gSRdy[$i] . "\t"
		  . $gSRnx[$i] . "\t"
		  . $gSRny[$i] . "\t"
		  . $gSRangle[$i] . "\t"
		  . $gSRmirror[$i] . "\t"
		  . $gSRxmin[$i] . "\t"
		  . $gSRymin[$i] . "\t"
		  . $gSRxmax[$i] . "\t"
		  . $gSRymax[$i]
		  . "\n" );
}

########

#DO_INFO_MM -t step -e $JOB/panel -d LAYERS_LIST
$f->INFO(
	units       => 'mm',
	entity_type => 'step',
	entity_path => "$job_name/$step_name",
	data_type   => 'LAYERS_LIST'
);

my @gLAYERS_LIST = @{ $f->{doinfo}{gLAYERS_LIST} };
foreach my $i (@gLAYERS_LIST) {
	print $i . "\n";
}

my $layer_name = 'top';

############

#DO_INFO_MM -t layer -e $JOB/panel/top -d ATTR
$f->INFO(
	units       => 'mm',
	entity_type => 'layer',
	entity_path => "$job_name/$step_name/$layer_name",
	data_type   => 'ATTR'
);

my @gATTRname = @{ $f->{doinfo}{gATTRname} };
my @gATTRval  = @{ $f->{doinfo}{gATTRval} };
for ( my $i = 0 ; $i < $#gATTRname ; $i++ ) {
	print( $gATTRname[$i] . "\t" . $gATTRval[$i] . "\n" );
}

############

#DO_INFO_MM -t layer -e $JOB/panel/$LAYER






$memUsage = $f->COM('memory_usage');
print "memory_usage: $memUsage \n";

$f->COM(
	'open_entity',
	job    => "$job_name",
	type   => "step",
	name   => "$step_name",
	iconic => "no"
);

my $val = $f->{COMANS};    # na razie tego nie rozumiem..
print("COMANS: $val \n");

#$f->COM( 'open_entity', job => "$job_name", type => "step", name => "$line" );
$f->AUX( 'set_group', group => $val );

#$f->PAUSE('Do you want to select anything?');
$selCount = $f->COM('get_select_count');
print "get_select_count: $selCount \n";

$workLayer = $f->COM('get_work_layer');
print "get_work_layer: $workLayer  \n";

$units = $f->COM('get_units');
if ( $units eq "mm" ) {
	print("You are europaer! \n");
}
else {
	print("The units are $units \n");
}

$origin = $f->COM('get_origin');
print "get_origin: $origin \n";

$userName = $f->COM('get_user_name');
print "get_user_name: $userName \n";

$userGroup = $f->COM('get_user_group');
print "get_user_group: $userGroup \n";

$result = $f->COM('get_user_priv');
print "get_user_priv: $result \n";

$canOpenJob = $f->COM( 'get_user_permission', command => 'open_job' );
print "get_user_permission: $canOpenJob \n";

$myVersion = $f->COM('get_version');
print "myVersion: $myVersion \n";

#print "   ----> $job_name $step_name" . "\n";

#$f->INFO(units => 'mm', entity_type => 'step', entity_path => "$job_name/$step_name", data_type => 'EXISTS');
$f->INFO(
	'units'         => 'mm',
	'entity_type'   => 'step',
	'entity_path'   => "$job_name/$step_name",
	'output_method' => 'display',
	'data_type'     => 'PROF_LIMITS'
);

print "... \n";
print $f->{STATUS};
print "\n... \n";

#A call to "DOINFO" which returns a value of "gEXISTS" would be referenced as
#$f->{doinfo}{gEXISTS}. If an array were to be received, the elements could be referenced as
#$f->{doinfo}{gWIDTHS}[$i].

my $panel_right  = $f->{doinfo}{gPROF_LIMITSxmax};
my $panel_left   = $f->{doinfo}{gPROF_LIMITSxmin};
my $panel_top    = $f->{doinfo}{gPROF_LIMITSymax};
my $panel_bottom = $f->{doinfo}{gPROF_LIMITSymin};

#print( $panel_right . " : " . $panel_left . "\n" );

$f->INFO(
	units       => 'mm',
	entity_type => 'job',
	entity_path => "777x0488.1701",
	data_type   => 'STEPS_LIST'
);

#print $job_name;

$f->INFO(
	entity_type => 'job',
	entity_path => $job_name,
	data_type   => 'FORMS_LIST'
);

#gFORMS_LIST = ('priform')
my @myArray = $f->{doinfo}{gFORMS_LIST};
print $myArray[0] . "\n";

#print $myArray[1] . "\n";
#print $myArray[2] . "\n";
#print $myArray[3] . "\n";

#print $#myArray;

# wyswietla wszystkie warstwy w trybie multi
#$f->COM( 'multi_layer_disp', mode => "many", show_board => "Yes" );

$response = $f->COM('get_disp_layers');
print("response: $response \n");

#$f->COM('get_disp_layers');
#print("COMANS: $f->{COMANS} \n");

# to nie dziala jakos..
#$f->PAUSE("mesecz bar");
$f->COM('get_message_bar');

#print("READANS: $f->{READANS} \n");
#print("COMANS: $f->{COMANS} \n");

# wyswietla text boxa z zawartosciom plika
#$f->COM(
#	'display_text_file',
#	title => 'maj_tajtl',
#	path  => 'c:/Users/pkr.PRIDANA/.genesis/scripts/majfajl.txt'
#);

#$f->COM( 'stk_select', all => 'yes' );
#$f->COM( 'stk_units', units => 'mm' );
#$f->COM('stk_imp_open');

#$result =
#  showYesNoMessageBox( "Question", "Do you want to close the Graphic Editor?" );
#print $result . "\n";
#
#if ( $result eq "yes" ) {
#	$f->COM('editor_page_close');
#
#	#$f->COM('disp_on');
#}
#else {
#	#$f->COM('disp_off');
#}

#if ($gFORMS_LIST != "") then
#	set formname = $gFORMS_LIST[1]
#endif

#	$f->{doinfo}{gSYMS_HISTsymbol}})
#	$num_lines = $f->{doinfo}{gSYMS_HISTline}[$i];
#	$f->{doinfo}{gTYPE}

#$f->COM( close_job, job => $job_name );
#print "STATUS: $f->{STATUS} \n";

print "\nEnd of program.\n";

##############################################################
# c:\genesis\help\pdf\0204\0204.pdf str. 19
# The public functions are:
#   VON, VOF, SU_ON, SU_OFF, PAUSE, MOUSE, COM, AUX, DO_INFO, and INFO
# The return results are called STATUS, READANS, PAUSANS, MOUSEANS and COMANS.
# funkcje new Genesis - pacz: genesis.pl

# smietnik
#$value = $f->{doinfo}{gPROF_LIMITS}[0];
#print $value . "\n";
#$value = $f->{doinfo}{gPROF_LIMITS}[1];
#print $value . "\n";
#$value = $f->{doinfo}{gPROF_LIMITS}[2];
#print $value . "\n";
#$value = $f->{doinfo}{gPROF_LIMITS}[3];
#print $value . "\n";

#print "myInfo2: " . $myInfo . "\n";
#print "myInfo3: " . @myInfo;
#
#$value = $f->{doinfo}{gPROF_LIMITS}[0];
#print "value: " . $value . "\n";
#
#
#@myPROF_LIMITS = $f->{doinfo}{gPROF_LIMITS}[1];
#
#print "\n ---> before <---\n";
#print "myPROF_LIMITS: " . @myPROF_LIMITS;
#print "#myPROF_LIMITS: " . $#myPROF_LIMITS . "\n";
#print "myPROF_LIMITS[0]: " . $myPROF_LIMITS[0] . "\n";
#print "myPROF_LIMITS[0][0]: " . $myPROF_LIMITS[0][0] . "\n";
#print " ---> after <---\n";

#@myPROF_LIMITSxmin = $f->{doinfo}{gPROF_LIMITSxmin};
#print "myPROF_LIMITSxmin[0]: " . $myPROF_LIMITSxmin[0] . "\n";
#
#@myPROF_LIMITSxmax = $f->{doinfo}{gPROF_LIMITSxmax};
#print "myPROF_LIMITSxmax[0]: " . $myPROF_LIMITSxmax[0] . "\n";
#
#@myPROF_LIMITSymin = $f->{doinfo}{gPROF_LIMITSymin};
#print "myPROF_LIMITSymin[0]: " . $myPROF_LIMITSymin[0] . "\n";
#
#@myPROF_LIMITSymax = $f->{doinfo}{gPROF_LIMITSymax};
#print "myPROF_LIMITSymax[0]: " . $myPROF_LIMITSymax[0] . "\n";
#
