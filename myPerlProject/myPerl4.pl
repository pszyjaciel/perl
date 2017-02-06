#!/bin/env perl -w
# U:\ucamusers\java\ucam\home\Workspace\myPerl1 data.txt 442x011-b-703_out
# http://www.comp.leeds.ac.uk/Perl/sandtr.html
# http://www.comp.leeds.ac.uk/Perl/matching.html

# u:/ucamusers/java/ucam/home/Workspace/myPerl1/data.txt

sub convert {

	my ($args) = @_;

	#print( $args->{filename} );

	my $myCounter  = 0;
	my $myPrevious = 0;
	my $found1     = 0, my $found2 = 0, my $found3 = 0;
	my $offset;
	my $success = 0;

	my $myNewOffsetX = 20;
	my $myNewOffsetY = 30;
	my $myValue;

	#	open( my $myINPUTFILE, "<", $args->{filename} ) || die $!;
	open( my $myINPUTFILE, "<", $args->{filename} ) || return 0;

	# usun rozszerzenie pliku
	my $myFilename = substr( $args->{filename}, -3 ) = "";
	open( my $myOUTPUTFILE, ">", $myFilename . 'out' ) || return 0; # .txt -> .out

	#Read the input file line by line
	while ( my $line = <$myINPUTFILE> ) {
		$myCounter++;

		 print( $found1, " : ", $found2, " : ", $found3, "\n" );

		if ( ( $line =~ /^M08\n$/ ) && ( $found1 != 1 ) ) {
			$myPrevious = $myCounter;
			$found1     = 1;
			$offset     = tell($myINPUTFILE);
			print $myOUTPUTFILE $line;
		}
		elsif (( $line =~ /^X\d\d\dY\d\d\d\n$/ )
			&& ( $myCounter == $myPrevious + 1 )
			&& ( $found2 != 1 ) )
		{
			$myPrevious = $myCounter;
			if ( $found1 == 1 ) {
				$found2 = 1;    # ustaw gdy poprzedni zaliczony
			}
			$myValue      = $line;
			$mySubString1 = substr( $myValue, 1, 3 ) + $myNewOffsetX;
			$mySubString2 = substr( $myValue, 5, 3 ) + $myNewOffsetY;
			$myValue      = "X" . $mySubString1 . "Y" . $mySubString2 . "\n";
			print $myOUTPUTFILE $line;
		}
		elsif (( $line =~ /^T\d\d\n$/ )
			|| ( $line =~ /^T\d\n$/ )
			&& ( $myCounter == $myPrevious + 1 )
			&& ( $found3 != 1 ) )
		{
			$myPrevious = $myCounter;
			if ( ( $found2 == 1 ) && ( $found1 == 1 ) ) {
				$found3 = 1;    # ustaw gdy oba poprzednie zaliczone
			}
			seek( $myOUTPUTFILE, $offset, 0 ) || return 0;
			print $myOUTPUTFILE $myValue;
			print $myOUTPUTFILE $line;

			$found1 = 0;
			$found2 = 0;
			$found3 = 0;

			$success++;
		}
		else {
			print $myOUTPUTFILE $line;
		}
	}

	close $myINPUTFILE;
	close $myOUTPUTFILE;

	if ( $success != 0 ) {
		print("changes: $success. \n");
		return $success;
	}
	else {
		print("no changes. \n");
		return 0;
	}
}

return 1;

# The last line in any module should be 1;
