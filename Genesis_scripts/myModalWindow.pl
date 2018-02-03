#!/usr/bin/perl -w

use Tk;
use strict;
require Tk::Table;
require Tk::Dialog;

my $main2 = MainWindow->new;

$main2->geometry("300x160");
$main2->title("Multiple Windows Test");

my $f_blue = $main2->Frame( -bg => 'BLUE', -border => 1 )
  ->pack( -expand => 0, -fill => 'none' );

$f_blue->Label( -text => 'BLUE', -bg => 'blue', -fg => 'white' )->pack();

my $blue_table = $f_blue->Table(
	-rows         => 3,
	-columns      => 3,
	-fixedrows    => 0,
	-fixedcolumns => 0,
	-scrollbars   => 'oo',
	-relief       => 'raised',
	-takefocus    => 0
)->pack( -expand => 0, -fill => 'both' );

$blue_table->put( 1, 1, $blue_table->Label( -text => 'Cs-137:' ) );
my $t_blue_cs137 = $blue_table->Entry( -selectbackground => "blueviolet" );
$blue_table->put( 1, 2, $t_blue_cs137 );
$blue_table->put( 2, 1, $blue_table->Label( -text => 'Tc-99m:' ) );
my $t_blue_tc99m = $blue_table->Entry( -selectbackground => "blueviolet" );
$blue_table->put( 2, 2, $t_blue_tc99m );

my $f_button = $main2->Frame( -border => 1 )->pack(
	-expand => 0,
	-fill   => 'none'
);

$f_button->Button(
	-width   => 10,
	-text    => "New window",
	-command => \&button1_sub
  )->pack(
	-side => 'left',
	-padx => 10,
	-pady => 10
  );

$f_button->Button(
	-width   => 10,
	-text    => "Exit",
	-command => sub { exit }
  )->pack(
	-side => 'right',
	-padx => 10,
	-pady => 10
  );

################## use this part in the jobsetup ###############
my $dato = '';
my $dialog = $main2->Dialog( -title => "Insert your plot-date" );
$dialog->Label( -text => "dato: " )->pack( -side => "left", -padx => 10 );
my $entry =
  $dialog->Entry( -textvariable => \$dato, )->pack( -side => "right" );
$dialog->Show();

# validate the date
if ( $dato !~ /^\d+$/ ) {
	$dato = 'wrong date';
}
elsif ( $dato < 0 || $dato > 9999 ) {
	$dato = 'wrong date';
}
##################

my $f_label = $main2->Frame( -bg => 'red', -border => 1 )->pack(
	-expand => 0,
	-fill   => 'none'
);

$f_label->Label( -text => $dato )->pack( -side => "left" );

MainLoop;

#############

sub button1_sub {
	my $subwin1 = $main2->Toplevel;
	$subwin1->geometry("300x150");
	$subwin1->title("Sub Window #1");

	$subwin1->raise($main2);
	$subwin1->grab();

	my $f_subwin1 =
	  $subwin1->Frame( -border => 1 )
	  ->pack( -expand => 0, -fill => 'none' );

	$f_subwin1->Label( -text => "Last Name" )->pack(
		-padx => 10,
		-pady => 10
	);
	$f_subwin1->Entry()->pack();

	$f_subwin1->Button(
		-width   => 20,
		-text    => "Close window",
		-command => [ $subwin1 => 'destroy' ]
	  )->pack(
		-padx   => 10,
		-pady   => 10,
		-expand => 0
	  );
}
