#!/usr/bin/perl -w
#require "myPerl3.pl";
# U:\ucamusers\java\ucam\home\Workspace\myPerl1

my @buffer;
my $myFilename = 'data2.txt';
my $FH;
my $myValue;
my $my_OffsetX = 10;
my $my_OffsetY = 5;

# up-case letter
sub isUpLetter {
	my $myLocalValue = ord(shift);
	if ( ( $myLocalValue > 64 ) && ( $myLocalValue < 91 ) ) {
		return 1;
	}
	else {
		return 0;
	}
}

# Takes the name of a file and returns its entire contents as a string.
sub getfile {
	my ($filename) = @_;
	my ($result);
	open( F, $filename ) or die "OPENING $filename: $!\n";
	while (<F>) {
		$result .= $_;
	}
	close(F);
	return $result;
}

###########################

sub makePaterns {

	return 0;
}

sub prepareString {
	my ($args)       = @_;
	my $myString     = $args->{baseString};
	my $myNewOffsetX = $args->{offsetx};
	my $myNewOffsetY = $args->{offsety};

	#	print("prepareString(): myString: $myString");
	#	print("prepareString(): myNewOffsetX, $myNewOffsetX \n");
	#	print("prepareString(): myNewOffsetX, $myNewOffsetY \n");

	my $mySubString1 = substr( $myString, 1, 3 ) + $myNewOffsetX;
	if ( $mySubString1 < 100 ) {
		$mySubString1 = sprintf( "%03d", $mySubString1 );    # dodaj leading 0
	}

	my $mySubString2 = substr( $myString, 5, 5 ) + $myNewOffsetY;
	if ( $mySubString2 < 100 ) {
		$mySubString2 = sprintf( "%03d", $mySubString2 );    # dodaj leading 0
	}

	$myString = "X" . $mySubString1 . "Y" . $mySubString2 . "\n";
	return $myString;
}

sub convert2 {

	my ($args) = @_;

	my $j;
	my $myNewOffsetX = $args->{offsetx};
	my $myNewOffsetY = $args->{offsety};

	$myResult       = getfile($myFilename);
	$myResultLength = length $myResult;
	print("myResultLength: $myResultLength \n");

	open $myINPUTFILE, "$myFilename";
	@data = <$myINPUTFILE>;
	close $myINPUTFILE;

	$num_byte_read = $#data;
	print("ile linii w pliku? $num_byte_read \n");

	my $success = 0;
	for ( my $i = 0 ; $i <= $num_byte_read ; $i++ ) {
		if (
			(
				   ( $data[$i] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 1 ] =~ /^T\d\d\n$/ )
			)
			|| (
				   ( $data[$i] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 1 ] =~ /^M09\n$/ )     # M09 between lines
				&& ( $data[ $i + 2 ] =~ /^T\d\d\n$/ )
			)
		  )
		{
			$myResult = prepareString(
				{
					baseString => $data[$i],
					offsetx    => $myNewOffsetX,
					offsety    => $myNewOffsetY
				}
			);
			$data[$i] = $myResult;
			$success++;
		}
	}
	# usun rozszerzenie pliku
	$myFilename = substr( $myFilename, 0, -3 );
	open( my $myOUTPUTFILE, ">", $myFilename . 'out' )
	  || return 0;    # .txt -> .out

	print $myOUTPUTFILE @data;
	close $myOUTPUTFILE;

	if ( $success != 0 ) {
		return $success;
	}
	else {
		return 0;
	}
}

my $rs = convert2(
	{
		filename => $myFilename,
		offsetx  => $my_OffsetX,
		offsety  => $my_OffsetY
	}
);

if ( $rs == 0 ) {
	print("error: something went wrong.. \n");
}
elsif ( $rs != 0 ) {
	print("done. $rs changes. \n");
}

