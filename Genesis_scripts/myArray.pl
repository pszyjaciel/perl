#!/usr/bin/perl -w

sub deleteAndShift {
	my $myListe = shift;
	my @myArray = @$myListe;
	my $myIndex = shift;

	if ( ( $myIndex > $#myArray ) || ( $myIndex < 0 ) ) {
		return @myArray;
	}

	for ( my $i = $myIndex ; $i <= $#myArray ; $i++ ) {
		$myArray[$i] = $myArray[ $i + 1 ];
	}
	$#myArray--;                # zmniejsza wielkosc tablicy
	return @myArray;
}

########### test ##############
@anArray = ( 1, 2, 3, 'a', 'b', 'c', 0.11, 0.33, 0.78 );
@anArray = deleteAndShift( \@anArray, 1 );
foreach $value (@anArray) {
	print $value . "\t";
}
