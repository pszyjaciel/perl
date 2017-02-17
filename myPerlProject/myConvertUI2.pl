# http://www.perlmeister.com/books/perlpower/source/scripts/
# http://www.perlmonks.org/?node_id=922840
use Tk;
require "myPerl4.pl";

my $myPath  = '';
my $xoffset = 0;
my $yoffset = 0;

# Main Window
my $mw = new MainWindow;

# create the two frames
$upperframe =
  $mw->Frame( -relief => 'groove', )->pack( -padx => 3, -pady => 3 );
$lowerframe =
  $mw->Frame( -relief => 'groove', )->pack( -padx => 3, -pady => 3 );

$btnframe = $mw->Frame()->pack( -padx => 3, -pady => 3 );

$txtframe =
  $mw->Frame()->pack( -side => 'top', -fill => 'both', -padx => 3, -pady => 3 );

# labels in the upper frame
$upperframe->Label(
	-font => "{Verdana} 8 {normal}",
	-text => "path",
)->pack( -side => "left" );
$myPath = $upperframe->Entry(
	-takefocus   => 1,
	-font        => "{Verdana} 8 {normal}",
	-borderwidth => 2,
	-relief      => 'groove',
	-width       => 31
)->pack( -side => "right" );

# labels in the lower frame
$lowerframe->Label(
	-font => "{Verdana} 8 {normal}",
	-text => "offset-x",
)->pack( -side => "left" );

$xoffset = $lowerframe->Entry(
	-font        => "{Verdana} 8 {normal}",
	-borderwidth => 2,
	-relief      => 'groove',
	-width       => 10
)->pack( -side => "left" );

$lowerframe->Label(
	-font => "{Verdana} 8 {normal}",
	-text => "offset-y",
)->pack( -side => "right" );

$yoffset = $lowerframe->Entry(
	-font        => "{Verdana} 8 {normal}",
	-borderwidth => 2,
	-relief      => 'groove',
	-width       => 10
)->pack( -side => "left" );

## Button
my $butBrowse = $btnframe->Button(
	-text      => "Browse ...",
	-command   => sub { fileDialog( $upperframe, $myPath, 'open' ) },
	-font      => "{Verdana} 8 {normal}",
	-takefocus => 1,
	-width     => 12,
	-height    => 0,
	-underline => 0
);

my $butConvert = $btnframe->Button(
	-text      => "Convert",
	-command   => sub { myConvert( $myPath, $xoffset, $yoffset ) },
	-font      => "{Verdana} 8 {normal}",
	-takefocus => 1,
	-width     => 12,
	-height    => 1,
	-underline => 0
);
$butBrowse->pack( -side => 'left', -expand => 1 );
$butConvert->pack( -side => 'right', -expand => 1 );

##Text Area
# http://docstore.mik.ua/orelly/perl3/tk/ch05_02.htm
# http://docstore.mik.ua/orelly/perl3/tk/ch06_04.htm
$yscroll = $txtframe->Scrollbar();
$text    = $txtframe->Text(
	-font           => "Verdana 9 normal",
	-width          => 35,
	-height         => 14,
	-yscrollcommand => [ 'set', $yscroll ]
);
$yscroll->configure( -command => [ 'yview', $text ] );
$yscroll->pack( -side => 'right', -fill => 'y' );
$text->pack( -side => 'bottom', -fill => 'both', -expand => 1 );

$text->insert( 'end',
	"It moves testing holes in a drill \nfile with the offset " );
$text->insert( 'end',
	"in X and Y direction. \nIf successed then a new file named '*-out' \n" );
$text->insert( 'end', "will be created. \n\n" );

$text->tagConfigure( "red",  -foreground => "red" );
$text->tagConfigure( "blue", -foreground => "blue" );

### Functions

sub fileDialog {
	my $w         = shift;
	my $ent       = shift;
	my $operation = shift;
	my $types;
	my $file;

	@types = (
		[ "Drill files",       ['*-b*'] ],
		[ "Laser drill files", ['*-l*'] ],
		[ "Rout files",        ['*-f*'] ],
		[ "All files", '*' ]
	);
	if ( $operation eq 'open' ) {
		$file = $w->getOpenFile( -filetypes => \@types );
	}
	if ( defined $file and $file ne '' ) {
		$ent->delete( 0, 'end' );
		$ent->insert( 0, $file );
		$ent->xview('end');
	}
}

sub isDigit {
	my $myValue = shift;
	if ( $myValue =~ /^[0-9,.E]+$/ ) {
		return 1;
	}
	else {
		return 0;
	}
}

sub myConvert {
	my $my_Path    = shift->get();    # get parameters
	my $my_OffsetX = shift->get();
	my $my_OffsetY = shift->get();
	my $myFilename;

	$text->delete( "0.0", 'end' );    # erase the text area

	if (   ( !defined $myPath )
		|| ( $my_OffsetX eq '' )
		|| ( $my_OffsetY eq '' ) )
	{
		$text->insert( 'end', "offset fields cannot be empty.\n", 'red' );
		return 0;
	}
	else {

		if (   ( isDigit($my_OffsetX) != 1 )
			|| ( isDigit($my_OffsetY) != 1 ) )
		{
			$text->insert( 'end', "offset-x/offset-y is not a digit.\n",
				'red' );
			return 0;
		}

		$rs = convert3(
			{
				textbox  => $text,
				filename => $my_Path,
				offsetx  => $my_OffsetX,
				offsety  => $my_OffsetY
			}
		);
		if ( $rs == 0 ) {
			$text->insert( 'end', "error: something went wrong.. \n", 'red' );
		}
		elsif ( $rs != 0 ) {
			$text->insert( 'end', "done. $rs changes.", 'blue', "\n" );
		}
	}
}

MainLoop;
