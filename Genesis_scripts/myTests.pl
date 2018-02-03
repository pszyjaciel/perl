#!/usr/bin/perl

use Genesis;

#require 'shellwords.pl';

# wywolanie: my $result = hashCompare (\%localHashArray, 'majKij', 'majKij2');
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

sub searchFeature {

	my $foundPattern = 0;
	my @foundFeature = ();
	my $array_ref    = shift;
	my @myData       = @{$array_ref};

	my $myItem      = shift;
	my $myAttribute = shift;

	my $myTempValue = $myItem;
	if ( $myTempValue !~ /^[0-9,.E]+$/ ) {

		#print("The item $myItem must be a digit! \n");
		return @foundFeature;
	}

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
					push @foundFeature, $myArrSplittedLine[$i];
				}
			}
		}
	}
	else {
		print "Search features only by size of the feature\n";
		foreach my $line (@myData) {
			@myArrSplittedLine = split /[\s\.]/, $line;
			if (   ( $myArrSplittedLine[0] ne '#P' )
				|| ( $#myArrSplittedLine < 7 ) )
			{
				next;
			}
			$myArrSplittedLine[3] =~ s/^r//g;
			if ( $myArrSplittedLine[3] == $myItem ) {
				print $myArrSplittedLine[3] . "\n";
				print $myItem . "\n";
				for ( my $i = 0 ; $i < $#myArrSplittedLine ; $i++ ) {
					push @foundFeature, $myArrSplittedLine[$i];
				}
			}
		}
	}
	if ( $#foundFeature == -1 ) {

		#		print "searchFeature(): nothing found. \n";
	}
	return @foundFeature;
}

sub parse_csh {
	local ($genesis) = shift;
	local $csh_file = shift;

	open( CSH_FILE, "$csh_file" )
	  or warn "Cannot open info file - $csh_file: $!\n";
	while (<CSH_FILE>) {
		chomp;
		next if /^\s*$/;

		#ignore blank lines
		#extract the name and value
		( $var, $value ) = /set\s+(\S+)\s*=\s*(.*)\s*/;

		#remove leading and trailing spaces from the value
		$value =~ s/^\s*|\s*$//g;

		#change ^M temporarily to something else
		#This happens mainly in giSEP, and shellwords makes it disappear
		$value =~ s/\cM/<^M>/g;

		@value = shellwords($_);

		#Deal with an csh array differently from a csh scalar
		if ( $value =~ /^\(/ ) {

			#remove leading and trailing () from the value
			#This is a standard part of the Perl library
			$value =~ s/^\(|\)$//g;
			@words = shellwords($value);
			grep { s/\Q<^M>/\cM/g } @words;

			#print "$var = @words\n";
			$genesis->{parsed_csh}{$var} = [@words];
		}
		else {
			$value =~ s/\Q<^M>/\cM/g;
			$value =~ s/^'|'$//g;

			$genesis->{parsed_csh}{$var} = $value;
		}
	}
	close(CSH_FILE);
	unlink($csh_file);
}

#sub parse {
#    local ($genesis) = shift;
#    local($request) = shift;
#    local $csh_file  = "$ENV{GENESIS_TMP}/info_csh.$$";
#}
#
#sub DO_INFO {
#    local ($genesis) = shift;
#    local $info_pre = "info,out_file=\$csh_file,write_mode=replace,args=";
#    local $info_com = "$info_pre @_ -m SCRIPT";
#    $genesis->parse($info_com);
#}

# $genesis->INFO('entity_type'=>'layer','entity_path'=>"$JOB/$step_name/rout",'data_type'=>'tool');
# DO_INFO -t layer -e $JOB/${step_name}/rout -d tool

#		$genesis->INFO('entity_type'=>'layer','entity_path'=>"$JOB/$step_name/rout_outline",'data_type'=>'limits');
#		DO_INFO -t layer -e $JOB/${step_name}/rout_outline -d limits

sub getXY {
	my $item = shift;

	#local $csh_file  = "$ENV{GENESIS_TMP}/info_csh.pk";
	local $csh_file = "c:/info_csh2.pk";
	local ($attribute) = 'fiducial_name';
	my @features       = ();
	my @mySplittedLine = ();

	#print "\n\n";

	open( CSHFILE, $csh_file )
	  or die " ---> 1. can not open file $csh_file: $!\n";
	while ( $line = <CSHFILE> ) {
		next unless ( $line =~ /$attribute/ );
		@mySplittedLine = split /\s/, $line;

	 #( $type, $xstart, $ystart, $xend, $yend, $symbol, $pol, $decode, $attr ) =
		$mySplittedLine[3] =~ s/^r//g;
		if ( are_equal( $item, $mySplittedLine[3] ) == 1 ) {
			push( @features, { 'x' => $mySplittedLine[1] } );
			push( @features, { 'y' => $mySplittedLine[2] } );
		}
	}
	close(CSHFILE);
	return @features;
}

sub TOLERANCE () { 1e-13 }    # ??

sub are_equal {
	my ( $a, $b ) = @_;
	return ( abs( $a - $b ) < TOLERANCE );
}

# function returns a rounded value to 0.5
sub getRounded {
	my $nr = shift;
	my $rounded;
	if ( $nr > 0 ) {
		$rounded =
		  ( int( ( $nr * 2000 ) + .0005 ) ) / 2000;    # rounding up to 0.5
	}
	else {
#		$rounded = ( int( ( $nr * 2000 ) - .0005 ) ) / 2000;    # rounding down to 0.5
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

my @fields = ( "1.00", "2.00", "2.40", "3.30" );

#printf("fields[1]: $fields[1] \n");

my $size = sprintf( "%.2f", $fields[1] / 1000 );

#printf("size: $size\n");

$size = $size * 2;

#printf("size: $size * 2\n");

my @fields2 = ( "1.00", "2.00", "2.40", "3.30" );
my $size2 = sprintf( "%.2f", $fields2[1] );

#printf("size2: $size2\n");

$size2 = sprintf( "%.2f", $fields2[1] / 100 );

#printf("size2: $size2\n");

#		@mySplittedLine = split /\s/, $line;
#		for (my $i = 0; $i < $#mySplittedLine; $i++) {
#			print $mySplittedLine[$i] . "\n";
#		}
#
#		print $mySplittedLine[1] . "\n";
#		print $mySplittedLine[2] . "\n";

my $myItemMM = 1015;
$myItemInch = round( ( $myItemMM / 25.4 ), 3 );

my @myFeatures = getXY($myItemInch);

#foreach $record (@myFeatures) {
#	for $key ( sort keys %$record ) {
#		print "$key: $record->{$key}\n";
#	}
#}

#if ( are_equal( $myItemInch, 39.961 ) == 1 ) {
#	print "ikual.\n";
#}

########################

my $x = 'x';
my $k = 0;

$x .= $k;

#print $x . "\n";

$k++;
$x .= $k;

#print $x . "\n";

############## hash table ##############

# ten => zastepuje przecine i tyle.
# a ten -> jest wywolaniem metody

# a tak dodaje zwyklom tabele do hasza:
my @a = ( 10, 20 );
my @b = ( 15, 25, 35, 45 );
my @c = ( 24, 44 );

my $myHashArray = {};    # deklaracja hasza
$myHashArray{'TL'} = \@a;  # i wstawiam tablice do hasza
$myHashArray{'TR'} = \@b;  # (!) uwaga: podawac referencje, bez palki nie dziala
$myHashArray{'BL'} = \@c;
$myHashArray{'BR'} = [@c];

$myHashArrayLength = keys %myHashArray;
print "myHashArrayLength: " . $myHashArrayLength . "\n";

my $myArrayLengthInHash = @{ $myHashArray{'TL'} };

#print "size of TL: " . $myArrayLengthInHash . "\n";

$myArrayLengthInHash = @{ $myHashArray{'TR'} };

#print "size of TR: " . $myArrayLengthInHash . "\n";

$myArrayLengthInHash = @{ $myHashArray{'BR'} };

#print "size of BR: " . $myArrayLengthInHash . "\n";

#print "BR0: " . $myHashArray{'BR'}[0] . "\n";
#print "BR1: " . $myHashArray{'BR'}[1] . "\n";

#print "TL0: " . $myHashArray{'TL'}[0] . "\n";
#print "TL1: " . $myHashArray{'TL'}[1] . "\n";

#print "TR0: " . $myHashArray{'TR'}[0] . "\n";
#print "TR1: " . $myHashArray{'TR'}[1] . "\n";
#print "TR2: " . $myHashArray{'TR'}[2] . "\n";
#print "TR3: " . $myHashArray{'TR'}[3] . "\n";

#print $myHashArray{'BL'}[0] . "\n";
#print $myHashArray{'BL'}[1] . "\n";

# $$ example (double dollar)
#	$comment = $$LOC{'DESCRIPTION'};
#	$LOC->{'DESCRIPTION'};

my $str   = 'a string';
my %hash  = ( a => 1, b => 2 );
my @array = ( 1 .. 4 );

my $str_ref   = \$str;
my $hash_ref  = \%hash;
my $array_ref = \@array;

#print "String value is $$str_ref\n";
#print "Hash values are either $$hash_ref{a} or $hash_ref->{b}\n";
#print "Array values are accessed by either $$array_ref[0] or $array_ref->[2]\n";

my @rvar = ( 10, 20, 30 );

# $$ is one of Perl's built-in vars. It holds the process ID of the running script.
my $v = $$;

#printf "process ID: %d\n", $v;

my $seed1;
my $seed2;
for ( my $i = 0 ; $i < 1000 ; $i++ ) {
	$v     = $$;
	$seed1 = ( time ^ $$ or time ^ ( $$ + ( $$ < 15 ) ) );
	$seed2 = ( time ^ $v or time ^ ( $v + ( $v < 15 ) ) );

	#	print $v . "\n";		# PID (process ID)
	#	print $seed1 . "\n";
	#	print $seed2 . "\n";
}

#$f = new Genesis;

#$job_name = "098x0145.1712";
my $job_name = "777x0488.1701";

#$isOpen = $f->COM( 'is_job_open', job => $job_name );
#if ( $isOpen eq "no" ) {
#	$f->COM( open_job, job => $job_name );
#	if ( $f->{STATUS} != 0 ) {
#		print("kucha. program exits.");
#		exit(0);
#	}
#}

my $my_entity_path = "$job_name/xray/il2p";

#$f->INFO(
#	'units'       => 'mm',
#	'entity_type' => 'layer',
#	'entity_path' => $my_entity_path,
#	'data_type'   => 'FEAT_HIST',
#	'parse'       => 'no'
#);

#FEAT_HIST:line=0,pad=12,surf=0,arc=0,text=0,total=12
$myFeatures = $f->{doinfo}{gFEAT_HISTline};

#print "gFEAT_HISTline: " . $myFeatures . "\n";

$myFeatures = $f->{doinfo}{gFEAT_HISTpad};

#print "gFEAT_HISTpad: " . $myFeatures . "\n";

$myFeatures = $f->{doinfo}{gFEAT_HISTtotal};

#print "gFEAT_HISTtotal: " . $myFeatures . "\n";

$my_entity_path = "$job_name/xray/il2p";
my $csh_file = "$ENV{GENESIS_TMP}/info_csh.$$";    # $$ is the process ID (PID)

#print "csh_file: " . $csh_file . "\n";

#@csh_file = $f->INFO(
#	'units'       => 'mm',
#	'entity_type' => 'layer',
#	'entity_path' => $my_entity_path,
#	'data_type'   => 'FEATURES',
#	'parse'       => 'yes'
#);
#
#open( CSHFILE, "$csh_file" ) or warn "$! \n";
#my @data = <CSHFILE>;
#close(CSHFILE);

my $foundFeatures = 0;

#my @rs = searchFeature( \@data, 1015, 'fiducial_name=inspecta' );
#foreach my $myFeature (@rs) {
#	print $myFeature . "\n";
#}

#@rs = searchFeature( \@data, 'r1015' );
#foreach my $myFeature (@rs) {
#	print $myFeature . "\n";
#}

# podaje liste jobow
#$f->INFO(
#	entity_type => 'root',
#	data_type   => 'JOBS_LIST'
#);

#my @myJobList = @{ $f->{doinfo}{gJOBS_LIST} };
#print( "#myJobList: " . $#myJobList . "\n" );

#foreach my $jl (@myJobList) {
#	print( $jl . "\n" );
#}

# daje liste stepow w jobie
#$f->INFO(
#		entity_type => 'job',
#		entity_path => '032x0011.1237',
#		data_type   => 'STEPS_LIST'
#	);

#my @stepList = @{ $f->{doinfo}{gSTEPS_LIST} };
#print( "#stepList: "  . $#stepList . "\n" );

######################

my $myCustNumber = "278x0359.1649";

#print( "myCustNumber: " . $myCustNumber . "\n" );

$mySubCustNumber = substr( $myCustNumber, 0, 3 );

#print( "mySubCustNumber: " . $mySubCustNumber . "\n" );

if ( $mySubCustNumber eq "278" ) {

	#print "mam go. \n";
}

my @data = ();
$data[0] = 'set Order_Nr = ' . "XALOrderNr" . "\n";
$data[1] = 'set MANUF = ' . "dotVareNummer" . "\n";
$data[2] = 'set REVISION = ' . "revision" . "\n";
$data[3] = 'set KUNDE = ' . " :" . "KUNDE" . "\n";

foreach my $line (@data) {
	@myArrSplittedLine = split /[\s\.]/, $line;    # split by dot or by space
	if ( $#myArrSplittedLine != 3 ) {

		#print "Error: " . $#myArrSplittedLine . "\n";
	}
}

# tak przy okazji:
# Use substr when possible, it can be ~3 times faster then a simple regex

my $myFile = "032x0011.1237.1.mdb";
$myFile =~ s/^.{3}//;

#print $myFile . "\n";

$myFile = "032x0011.1237.1.mdb";
$mySubFile = substr( $myFile, 0, 8 );
print $mySubFile . "\n";

my @myArray = (
	'032x0011.1237.10.mdb', '032x0011.1237.2.mdb',
	'032x0011.1237.3.mdb',  '032x0011.1237.3-oj.mdb',
	'032x0011.1237.4.mdb',  '032x0011.1237.5.mdb'
);

#print $#myArray . "\n";

splice( @myArray, 4 )
  ;  # zachowuje pierwsze 4 elementy, 2 ostatnie wypadaja, dlugosc tablicy 6-2=4

#print $#myArray . "\n";

#foreach $myValue (@myArray) {
#	print( $myValue . "\n" );
#}

sub shiftArray {
	my @localArr = shift;    # chyba bylo inaczej..
	my $myIndex  = shift;

	foreach my $myValue3 (@localArr) {

		#print( "myValue3: " . $myValue3 . "\n" );
	}
}

####################
my @myArray2 = (
	'032x0011.1237.10.mdb', '032x0011.1237.2.mdb',
	'032x0011.1237.3.mdb',  '032x0011.1237.3-oj.mdb',
	'032x0011.1237.4.mdb',  '032x0011.1237.5.mdb'
);

my $index = 2;

#print( "pszet #myArray2: " . $#myArray2 . "\n" );
delete( $myArray2[$index] );

#print "po dilicie powinien pszesunac komurki tablicy.. \n";
shiftArray( \@myArray2, $index );

#print( "ipo1 #myArray2: " . $#myArray2 . "\n" );
delete( $myArray2[3] );

#print( "ipo2 #myArray2: " . $#myArray2 . "\n" );
delete( $myArray2[4] );

#print( "ipo3 #myArray2: " . $#myArray2 . "\n" );

foreach my $myValue2 (@myArray2) {

	#print ($myValue2 . "\n");
}

for ( my $i = 0 ; $i <= $#myArray2 ; $i++ ) {

	#		print ($i . ": " . $myArray2[$i] . "\n");
}

my $myJob = "442-0040.1735";
if ( ( substr( $myJob, 3, 1 ) ne 'x' ) && ( substr( $myJob, 3, 1 ) ne 'X' ) ) {

	#	print ("not a multilayer \n");
}

# wyswietl 2, 3, 6, 7, 10, 11: 	6 = 2 + 4; 7 = 3 + 4; 10 = 6 + 4; ..
my $j = 0;

#for ( my $i = 0 ; $i <= 40 ; $i++ ) {

my $i = 0;
do {
	if ( $i % 4 == 0 ) {
		$j = $i + 2;

		#		print ("$j \t");
		$j++;

		#		print ("$j \n");
	}

	if ( ( $i % 16 == 0 ) && ( $i != 0 ) ) {

		#		print "--\n";
		#$i++;
	}
	$i++;

} while ( $i <= 40 );

$j = 0;
$i = 0;
do {
	if ( $i % 4 == 0 ) {
		$j = $i + 2;

		#print("$j \t");
		$j++;

		#print("$j \n");
	}
	else {
		#print "--\n";
	}
	$i++;
} while ( $i <= 40 );

# lepiej zrobic hash tablice TLx, TLy itd..

###########################

my $ABSposX11, my $ABSposY11, my $ABSposX12, my $ABSposY12, my $ABSposX21,
  my $ABSposY21, my $ABSposX22, my $ABSposY22;

my @tempArray = ();
$localHashArray = {};

push @tempArray, 1.11;
push @tempArray, 2.4;
push @tempArray, 3.33;
push @tempArray, 4.3;

push @tempArray, 5.55;
push @tempArray, 6.2;
push @tempArray, 7.1;
push @tempArray, 8.88;
$localHashArray{"majKij"} = [@tempArray];
@tempArray = ();

push @tempArray, 1.11;
push @tempArray, 2.4;
push @tempArray, 3.33;
push @tempArray, 4.3;

push @tempArray, 5.55;
push @tempArray, 6.2;
push @tempArray, 7.1;
push @tempArray, 8.88;
$localHashArray{"majKij2"} = [@tempArray];

@tempArray = ();
push @tempArray, 2.23;
push @tempArray, 7.737;
$localHashArray{"majKij3"} = [@tempArray];

$localHashArray{"extraKij"} = [ 10.12, 9.99 ];
$localHashArray{"extraKij2"} = [11.11];

my $value;
foreach my $myKey ( keys %localHashArray ) {

	#	print("{ $myKey }\t");

	#$value = $localHashArray{$myKey};
	foreach my $myValue ( @{ $localHashArray{$myKey} } ) {

		#		print("$myValue ");
	}

	#	print("\n");
}

# wyswietl hasz-arraya z uzyciem for-loop
my @myTab  = ();
my @klucze = keys %localHashArray;
for ( my $i = 0 ; $i <= $#klucze ; $i++ ) {

	#print( $klucze[$i] . "\n" );
	@myTab = @{ $localHashArray{ $klucze[$i] } };
	for ( my $j = 0 ; $j <= $#myTab ; $j++ ) {

		#	print( "[" . $j . "]: " . $myTab[$j] . "\n" );
	}
}

#print("\n----------------\n");

my $result = hashCompare( \%localHashArray, 'majKij', 'majKij2' );

#print $result . "\n";

for ( my $i = 0 ; $i <= $#klucze ; $i++ ) {
	for ( my $j = 0 ; $j <= $#klucze ; $j++ ) {
		if ( $klucze[$i] eq $klucze[$j] ) {
			next;
		}

		#print ($klucze[$i] . " : " . $klucze[$j] . "\t");
		$result = hashCompare( \%localHashArray, $klucze[$i], $klucze[$j] );

		#print $result . "\n";
	}
}

#my @klucze =  keys %localHashArray;
#for ( my $i = 0 ; $i <= $#klucze ; $i++ ) {
#	print( $klucze[$i] . "\n" );
#	@myTab = @{ $localHashArray{ $klucze[$i] } };
#	for ( my $j = 0 ; $j <= $#myTab ; $j++ ) {
#		print ("[" . $j . "]: " . $myTab[$j] . "\n");
#	}
#}
print("\n----------------\n");

$localHashArray = {};    # to nie czysci tablicy haszy!!!!!
%localHashArray = ();    # a to i ofszem

push @tempArray, 112.66;
$localHashArray{"majKij4"} = [@tempArray];

foreach my $myKey ( keys %localHashArray ) {

	#	print( "{ $myKey }\t" );
	#$value = $localHashArray{$myKey};
	foreach my $myValue ( @{ $localHashArray{$myKey} } ) {

		#		print( "$myValue " );
	}

	#	print( "\n" );
}

#print ($localHashArray{'majKij4'}[0] . "\n");
#my $val = $localHashArray{'majKij4'}[0] - 1;
#print $val . "\n";

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

my @myStrings = ( "il7p_il6p", "il4p_il5p", "il5p_il4p", "il6p_il7p" );

my $charSum      = 0;
my $charValue    = 0;
my @chars        = ();
my @charSumArray = 0;
$i = 0;
my $rs = 0;
foreach my $myStr (@myStrings) {
	@chars = $myStr =~ /./sg;
	for ( my $j = 0 ; $j <= $#chars ; $j++ ) {
		$charValue = ord( $chars[$j] );
		$charSum += $charValue;
	}

	# sprawdzac wystepowanie w momencie dodawania!
	$rs = doesExist( $charSum, \@charSumArray );
	if ( $rs == 0 ) {
		$charSumArray[$i] = $charSum;
		$i++;
	}
	$charSum = 0;
}

foreach (@charSumArray) {

	#print " $_ \n";
}

#$k = 0;
#$j = 0;
## teraz usunac duplikaty
#for ( $j = 1 ; $j <= $#charSumArray ; $j++ ) {
#	if ($charSumArray[$j] == $charSumArray[$j - 1]) {
##		# przesun
##		for ( $k = $j ; $k <= $#charSumArray ; $k++ ) {
##			$charSumArray[$k] = $charSumArray[$k + 1];
#		}
#		print $j . "\n";
##	}
#}
#
#foreach (@charSumArray) {
#	print " $_ \n";
#}

#		print "-->" . $charSum . "\n";
#
#	# pierwszy element listy
#	$charSumArray[$i] = $charSum;
#	#print "-->" . $charSumArray[$i] . "\n";
#
#	# dodaj gdy nie wystepuje
#	foreach (@charSumArray) {
#		#print "---> $charSum \n";
#		if ( $_ == $charSum) {
#			#print "$i $myElement $charSum\n";
#			last;
#		}
#		$charSumArray[$i] = $charSum;
#		#print ($charSum . "\n");
#	}

# print $#charSumArray . "\n";

foreach my $mcs (@charSumArray) {

	#print $mcs . "\n";
}

#	if ($myStr eq $myStrings[0]) {
#		print ("sie rowna: $myStr $myStrings[0]\n");
#	}

#print ord ('a') . "\n";

#my $string = "Hello, how are you?";
my $string = "Hello, how are you?";
@chars = $string =~ /./sg;

#print "Fourth char: " . $chars[3] . "\n";

$charSum   = 0;
$charValue = 0;
for ( my $j = 0 ; $j <= $#chars ; $j++ ) {
	$charValue = ord( $chars[$j] );

	#print $charValue . "\n";
	$charSum += $charValue;
}

#print $charSum . "\n";

###########

sub my_complex_sort {

 # code that compares $a and $b and returns -1, 0 or 1 as appropriate
 # It's probably best in most cases to do the actual comparison using cmp or <=>

	# Extract the digits following the first comma
	my ($number_a) = $a =~ /,(\d+)/;
	my ($number_b) = $b =~ /,(\d+)/;

	# Extract the letter following those digits
	my ($letter_a) = $a =~ /,\d+(a-z)/;
	my ($letter_b) = $b =~ /,\d+(a-z)/;

	# Compare and return
	return $number_a <=> $number_b or $letter_a cmp $letter_b;
}


sub showHashArray {
	my $array_ref      = shift;
	my %localHashArray = %{$array_ref};
	foreach my $myKey ( sort keys %localHashArray ) {
		print("{ $myKey }\t");
		foreach my $myValue ( @{ $localHashArray{$myKey} } ) {
			print("$myValue ");
		}
		print("\n");
	}
}


# function inserts a zero before the 1-digit layer name: il2p -> il02p
# it doesn't touch the 2-digit names
# call: @myAllignedLayerKeys = getAllignedLayerNames (\@myLayerKeys);
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


# call example: sortMyHashArray( \%myCoord );
sub sortMyHashArray {

	my $array_ref      = shift;
	my %localHashArray = %{$array_ref};

	# obie tablice maja taka samom wielkosc
	my @myTempLayerKeys   = keys %localHashArray;
	my @myLocalLayerValues = values %localHashArray;

	my @myLocalLayerKeys = getAllignedLayerNames( \@myTempLayerKeys );

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

	# utworzyc nowom hasz-tabele i zwrocic w returnie
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


my @myLayerKeys = (
	"il22p", "il3n",  "il16p", "il4n",  "il5p", "il21p", "il2p", "il23p",
	"il10p", "il12p", "il15p", "il17p", "il9p", "il13p"
);

@myAllignedLayerKeys = getAllignedLayerNames( \@myLayerKeys );

foreach my $mcs ( sort @myAllignedLayerKeys ) {

	# print $mcs . "\n";
}

###########


my %myCoord = ();

my @myTab0 = ( 10, 20 );
my @myTab1 = ( 11, 12 );
my @myTab2 = ( 22, 23 );
my @myTab3 = ( 31, 33 );

$myCoord{ $myLayerKeys[0] } = [@myTab0];
$myCoord{ $myLayerKeys[1] } = [@myTab1];
$myCoord{ $myLayerKeys[2] } = [@myTab2];
$myCoord{ $myLayerKeys[3] } = [@myTab3];
$myCoord{ $myLayerKeys[4] } = [@myTab0];

# zanim skasowalem jednego klucza
foreach my $myKey ( keys %myCoord ) {
	print $myKey . "\n";
}

print "-----------\n";

delete $myCoord{ $myLayerKeys[4] };

# i po skasowaniu
foreach my $myKey ( keys %myCoord ) {
	print $myKey . "\n";
}

print "before sorting: \n";
# obie tablice maja taka samom wielkosc
my @myKeyArr   = keys %myCoord;
my @myValueArr = values %myCoord;

my @tempArr = ();
for ( $k = 0 ; $k <= $#myValueArr ; $k++ ) {
	print( $myKeyArr[$k] . "\t" );
	@tempArr = @{ $myValueArr[$k] };
	for ( $j = 0 ; $j <= $#tempArr ; $j++ ) {
		print( $tempArr[$j] . "\t" );
	}
	print "\n";
}

print "after sorting: \n";
my %mySortedHashArray = sortMyHashArray( \%myCoord );
showHashArray( \%mySortedHashArray );


#print( $#myKeyArr . "\n" );      # daje 3 (bo 4 stringi)
#print( $#myValueArr . "\n" );    # daje 3 (bo 4 tablice)

@tempArr = ();
for ( $k = 0 ; $k <= $#myValueArr ; $k++ ) {

	#print( $myKeyArr[$k] . "\t" );
	#print( $mySortedHashArray[$k] . "\t" );
	@tempArr = @{ $myValueArr[$k] };
	for ( $j = 0 ; $j <= $#tempArr ; $j++ ) {

		#	print( $tempArr[$j] . "\t" );
	}

	#print "\n";
}

######################

	print "--------------------\n";
 
	for ( $j = 0 ; $j <= $#myLayerKeys ; $j++ ) {
	#	print ($myLayerKeys[$j] . "\n");
	}

	for ( $j = 1 ; $j <= $#myLayerKeys ; $j++ ) {
		$myLayerKeys[$j - 1] = $myLayerKeys[$j];
	}
	$#myLayerKeys--;


	for ( $j = 0 ; $j <= $#myLayerKeys ; $j++ ) {
		print ($myLayerKeys[$j] . "\n");
	}



sub showArray2 {
	my $array_ref    = shift;
	my @myLocalArray = @{$array_ref};
	foreach my $value (@myLocalArray) {
		if ($_ % 4 == 0) {
			print ("\n");
		}
		#$text->insert( "end", $_ . " $value \n" );
		print ($_ . " $value \t");
	}
}

sub showArray {
	my $array_ref    = shift;
	my @myLocalArray = @{$array_ref};
	my $myModulus = shift;
	
	$myModulus = 1 unless defined $myModulus;      # set default after the fact
	if ($myModulus == 0) {
		$myModulus = 1;
	}
	
	for ( my $i = 0 ; $i <= $#myLocalArray ; $i++ ) {
		if ($i % $myModulus == 0) {
			print ("\n");
		}
		#$text->insert( "end", "[" . $i . "]\t" . $myLocalArray[$i] . "\t" );
		print ("[" . $i . "]\t" . $myLocalArray[$i] . "\t" );
	}
}

my @myTestArray = ();
for (0 .. 99) {
	$myTestArray[$_] = $_;
	#print ($_ . "\n");
}

showArray(\@myTestArray);



print "\n\nkoniec tego gniota. \n";

############################################

###########
#	my $a = 10;
#	my $b = 22;
#
#	$result = $a <=> $b;    # -1 bo a < b
#	                        #print ($result . "\n");
#
#	$result = $b <=> $a;    # 1 bo b > a
#	                        #print ($result . "\n");
#
#	$result = $b <=> $b;    # 0 bo b = b
#	                        #print ($result . "\n");
#
#	# ---------------------
#	#print ("3. sortMyHashArray():" . "\n");
#
#	my $c = 'il12p';
#	my $d = 'il06p';
#
#	$result = $c cmp $d;    # 1 bo c przed d
#	                        #print ($result . "\n");
#
#	$result = $d cmp $c;    # -1 bo d przed c
#	                        #print ($result . "\n");
#
#	$result = $d cmp $d;    # 0 bo takie same
#	                        #print ($result . "\n");
#



