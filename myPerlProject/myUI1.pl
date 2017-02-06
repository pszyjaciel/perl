# http://www.perlmonks.org/?node_id=922840
use Tk;
use Cwd;

require "myPerl4.pl";

# Main Window
my $mw = new MainWindow;
my $but = $mw->Button( -text => "Convert", -command => \&push_button );
$but->grid(
	-row        => 8,
	-column     => 1,
	-columnspan => 2,
	-padx       => 15,
	-pady       => 15,
	-sticky     => "e"
);

#GUI Building Area
my $frm_name = $mw->Frame();

my $ent = $frm_name->Entry(
	-background  => 'white',
	-foreground  => 'black',
	-borderwidth => 2,
	-relief      => 'groove',
	-width       => 50
);

$ent->focus;

$ent->grid( -row => 1, -column => 1, -columnspan => 1 );
$frm_name->grid(
	-row        => 1,
	-column     => 1,
	-columnspan => 2,
	-padx       => 15,
	-pady       => 15,
	-sticky     => "w"
);

#Text Area
my $textarea = $mw->Frame();
$textarea->grid( -row => 2, -column => 1, -columnspan => 2 );
my $txt = $textarea->Text(
	-width  => 44,
	-height => 6,
	-relief => "groove",
	-padx   => 1,
	-pady   => 1
);
$txt->grid(
	-row        => 1,
	-column     => 1,
	-columnspan => 1,
	-padx       => 10,
	-pady       => 10
);

## Functions
#This function will be executed when the button is pushed
sub push_button {

	# $name = cwd();
	# print($name, "\n");

	my $myFilename = $ent->get();
	if ( $myFilename ne "" ) {
		$rs = convert( { filename => $myFilename } );
		if ( $rs == 0 ) {
			$txt->insert( 'end', "error: something goes wrong.. \n" );
		}
		elsif ( $rs != 0 ) {
			$txt->insert( 'end', "done. $rs changes. \n" );
		}
	}
	else {
		$txt->insert( 'end', "error: file cannot be found. \n" );
	}
}

#$ent -> bind('<Key-Return>' => print());
#$textEntry -> bind('<Return>' => \&get);

# trza zrobic eventa dla pola textowego

MainLoop;

