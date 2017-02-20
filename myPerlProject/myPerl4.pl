#!/bin/env perl -w
# http://www.comp.leeds.ac.uk/Perl/sandtr.html
# http://www.comp.leeds.ac.uk/Perl/matching.html

sub prepareString {
	my ($args)       = @_;
	my $myString     = $args->{baseString};
	my $myNewOffsetX = $args->{offsetx};
	my $myNewOffsetY = $args->{offsety};

	my $mySubString1 = substr( $myString, 1, 3 ) + $myNewOffsetX;
	if ( $mySubString1 < 100 ) {
		$mySubString1 = sprintf( "%03d", $mySubString1 );    # add leading 0
	}

	my $mySubString2 = substr( $myString, 5, 5 ) + $myNewOffsetY;
	if ( $mySubString2 < 100 ) {
		$mySubString2 = sprintf( "%03d", $mySubString2 );
	}

	$myString = "X" . $mySubString1 . ".000Y" . $mySubString2 . ".000\n";
	return $myString;
}

sub convert3 {

	my ($args)       = @_;
	my $myText       = $args->{textbox};
	my $myFilename   = $args->{filename};
	my $myNewOffsetX = $args->{offsetx};
	my $myNewOffsetY = $args->{offsety};

	open ($myINPUTFILE, "$myFilename") or return -1;
	@data = <$myINPUTFILE>;
	close $myINPUTFILE;

	$num_byte_read = $#data;
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

			# lets add here more conditions...
			|| (   ( $data[$i] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 1 ] =~ /^M30\n$/ ) )
			|| (   ( $data[$i] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 1 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 2 ] =~ /^T\d\d\n$/ ) )
			|| (   ( $data[$i] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 1 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 2 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 3 ] =~ /^T\d\d\n$/ ) )
			|| (   ( $data[$i] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 1 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 2 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 3 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 4 ] =~ /^T\d\d\n$/ ) )
			|| (   ( $data[$i] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 1 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 2 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 3 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 4 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 5 ] =~ /^T\d\d\n$/ ) )
			|| (   ( $data[$i] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 1 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 2 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 3 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 4 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 5 ] =~ /^X\d\d\dY\d\d\d\n$/ )
				&& ( $data[ $i + 6 ] =~ /^T\d\d\n$/ ) )
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

	# remove the extension in file name
	$myFilename = substr( $myFilename, 0, -3 );
	open( my $myOUTPUTFILE, ">", $myFilename . 'out' )
	  || return -1;    # .txt -> .out

	print $myOUTPUTFILE @data;
	close $myOUTPUTFILE;

	if ( $success != 0 ) {
		return $success;
	}
	else {
		return 0;
	}
}

return 1;

# The last line in any module should be 1;
