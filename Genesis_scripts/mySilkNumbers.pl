
#!/usr/bin/perl -w

###################
# prepare numbering array
my @abc1   = ();
my @abc2   = ();
my @abcOut = ();

for ( 1 .. 1000 ) {
	push @abcOut, $_;
}

############
# read and replace
my @mySplittedLine = ();
my @outData        = ();
my $j              = 0;

$feat_file = "features";
open( FEATURES_FILE, $feat_file ) or die "$!\n";
while ( $line = <FEATURES_FILE> ) {
	if ( $line eq "\n" ) {
		push @outData, $line;
		next;
	}
	@mySplittedLine = split /\s/, $line;
	if ( $mySplittedLine[0] ne "T" ) {
		push @outData, $line;
		next;
	}

	$mySplittedLine[9] = '\'' . $abcOut[$j] . '\'';
	foreach my $val (@mySplittedLine) {
		push @outData, $val . " ";
	}
	push @outData, "\n";
	$j++;
}

close (FEATURES_FILE);

# write changes to file
open( OUTPUTFILE, ">", $feat_file . '.out' ) or die "$!\n";
print OUTPUTFILE @outData;
close (OUTPUTFILE);

print "done. \n";
 