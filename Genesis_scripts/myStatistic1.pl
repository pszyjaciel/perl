#!c:/Perl/bin/perl 

use strict;

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

sub showArray {
	my $array_ref    = shift;
	my @myLocalArray = @{$array_ref};
	for ( my $i = 0 ; $i <= $#myLocalArray ; $i++ ) {
		print( "[$i]: " . $myLocalArray[$i] . "\n" );
	}
}

my $myXrayDots = 8;    # ilosc dotow w xrayu

my @myData = (
	176, -89,  -27,  15,  62,   33,   25,   45,
	118, 0,    -28,  13,  91,   -119, -19,  -2,
	-14, -16,  2,    -2,  -42,  -43,  6,    -6,
	2,   -39,  -225, -47, -23,  -9,   -16,  -17,
	13,  0,    17,   -36, -6,   27,   -127, -11,
	18,  18,   -10,  28,  6,    20,   0,    31,
	59,  23,   -273, 16,  44,   19,   -76,  -8,
	-7,  1,    -75,  -31, 2,    42,   -84,  244,
	31,  -97,  17,   -35, 36,   -8,   -5,   -20,
	98,  12,   15,   -28, 83,   7,    -22,  -31,
	-24, -17,  38,   18,  -22,  11,   26,   -6,
	334, -25,  7,    -41, -1,   17,   -5,   -16,
	-27, -7,   -12,  14,  -17,  22,   -26,  33,
	18,  23,   56,   59,  40,   19,   36,   51,
	151, 33,   -45,  35,  48,   7,    -65,  0,
	-70, -44,  -93,  -54, -159, 10,   -110, 36,
	21,  21,   -24,  35,  106,  -8,   -32,  12,
	30,  -79,  -60,  8,   100,  -25,  -29,  -7,
	-2,  -18,  30,   15,  110,  -39,  41,   5,
	-6,  39,   -24,  14,  -311, 4,    31,   -23,
	14,  -3,   -9,   -36, -11,  15,   3,    -1,
	-2,  31,   -1,   33,  20,   171,  -3,   11,
	58,  17,   -80,  -14, -18,  -311, -67,  -58,
	71,  45,   -66,  8,   -20,  -3,   -69,  14,
	45,  -29,  -3,   -2,  63,   277,  -49,  38,
	104, -5,   -30,  7,   -10,  -322, 15,   -14,
	90,  7,    -40,  30,  -26,  -17,  -5,   -20,
	-22, -9,   -12,  -17, -20,  7,    -122, 9,
	12,  9,    11,   3,   10,   -14,  -7,   272,
	24,  -9,   33,   -23, 14,   -15,  -38,  12,
	80,  20,   -56,  9,   72,   8,    -70,  -6,
	-4,  -8,   -90,  46,  84,   -63,  36,   -13,
	-5,  -48,  -85,  -52, 282,  79,   -26,  32,
	97,  -2,   -29,  5,   87,   111,  -44,  0,
	-25, -56,  -7,   -35, -1,   -116, -3,   -224,
	-23, -354, 25,   -35, -12,  4,    8,    9,
	23,  22,   35,   29,  10,   29,   118,  141,
	-37, -31,  -17,  0,   66,   26,   -165, 21,
	-26, -3,   -337, 14,  144,  -9,   -376, -1,
	-30, -12,  -56,  -15, -38,  12,   -284, 46,
	43,  38,   30,   21,  86,   -29,  -259, 2,
	264, -46,  330,  -18, 288,  -31,  -27,  -7,
	-32, -64,  -15,  11,   -226, -241, 20,   30,   26,  -333, -7,   -37,
	7,   11,   5,    4,    320,  16,   32,   -20,  19,  252,  -3,   -2,
	3,   20,   -11,  14,   11,   23,   -29,  213,  359, 362,  -63,  15,
	77,  13,   -83,  -11,  -314, -18,  -99,  -240, -37, 57,   -105, 21,
	27,  -104, -33,  -383, 352,  29,   -51,  218,  74,  143,  -34,  7,
	71,  22,   -48,  133,  -19,  -11,  16,   26,   -25, 303,  -25,  -12,
	2,   -40,  -4,   -318, 12,   6,    -322, 28,   5,   -143, 17,   7,
	14,  5,    13,   317,  43,   4,    217,  34,   30,  18,   -5,   18,
	92,  21,   -346, -8,   68,   223,  -70,  -28,
	-25, 10,   -383, 40,   223,  -49,  -31,  -27,
	-5,  -353, -80,  -33,  14,   351,  -31,  25,
	86,  -3,   -334, 118,  77,   -14,  -22,  -17,
	-24, 3,    114,  -18,  -13,  -27,  -14,  -35,
	-4,  -153, 18,   16,   -25,  -233, -8,   -11,
	-1,  236,  127,  215,  212,  36,   -6,   38,
	24,  234,  -214, -6,   279,  24,   -50,  16,
	-5,  -135, 2,    7,    81,   -15,  -53,  -8,
	-6,  -130, -49,  -41,  11,   30,   -69,  40,
	40,  165,  -30,  251,  75,   -2,   -33,  1,
	41,  -49,  -19,  -30,  81,   2,    -46,  -18,
	-23, -143, 32,   -223, -22,  -29,  23,   -29,
	-8,  141,  -24,  -218, -2,   1,    10,   -9,
	-9,  -25,  -8,   -32,  -6,   23,   3,    21,
	34,  42,   151,  64,   34,   42,   25,   49,
	54,  2,    -47,  -3,   -29,  -78,  -93,  -71,
	64,  51,   -36,  22,   -34,  -43,  -97,  42,
	42,  -60,  -113, -14,  45,   74,   -22,  41,
	89,  -14,  -124, -27,  -19,  -31,  35,   -6,
	85,  -5,   -6,   -4,   5,    -33,  20,   -32,
	-5,  -15,  -4,   -22,  -112, 28,   -16,  13,
	-22, -15,  18,   9,    -12,  -7,   -7,   24,
	-12, 217, 35,  30,  -16, 6,   6,   26,
	71,  41,  -24, 21,  172, 219, -46, 1,
	-67, -31, -62, -51, -55, -4,  -90, 720
);

my @hexData = (0x1a, 0xe3, 0xff, 0x0a, 0x0f);
#print ($hexData[0] . "\n");
#print ($hexData[1] . "\n");
#print ($hexData[2] . "\n");

#print (2 ** 8);	# 0xff
#print "\n";
#
#print (2 ** 16);	# 0xffff
#print "\n";
#
#print (2 ** 32);	# 0xffffffff
#print "\n";

# hex na signed byte
my $hexstr = '0xff';
my $num = hex($hexstr);
print ("1. --> " . $num);
print "\n";
print ($num >> 31);
print "\n";
print ($num - 2 ** 32);
print "\n";

$hexstr = '0xff';
$num = hex($hexstr);
print ("2 .--> " . $num);
print "\n";
if ($num >> 7) {
	print ($num - 2 ** 8);
}
else {
	print ($num);	
}
print "\n";



#    return $num >> 31 ? $num - 2 ** 32 : $num;

#######################

my $myFields = $#myData + 1;
print("$myFields pol \n");
my $myRows = $myFields / 8;
print("$myRows rzedow \n");

# wartosci z tabeli csv nalezy najpierw przepisac do odpowiednich tabel X i Y
my @myABSposX11, my @myABSposY11, my @myABSposX12, my @myABSposY12;
my @myABSposX21, my @myABSposY21, my @myABSposX22, my @myABSposY22;

#my $i = 0;
#while ( $i <= $#myData ) {
#	push @myABSposX11, int( $myData[$i] );
#	$i++;
#	push @myABSposY11, int( $myData[$i] );
#	$i++;
#	push @myABSposX12, int( $myData[$i] );
#	$i++;
#	push @myABSposY12, int( $myData[$i] );
#	$i++;
#	push @myABSposX21, int( $myData[$i] );
#	$i++;
#	push @myABSposY21, int( $myData[$i] );
#	$i++;
#	push @myABSposX22, int( $myData[$i] );
#	$i++;
#	push @myABSposY22, int( $myData[$i] );
#	$i++;
#}

my $i = 0;
while ( $i <= $#myData ) {
	push @myABSposX11, int( $myData[$i] );
	$i += $myXrayDots;
	push @myABSposY11, int( $myData[$i] );
	$i += $myXrayDots;
	push @myABSposX12, int( $myData[$i] );
	$i += $myXrayDots;
	push @myABSposY12, int( $myData[$i] );
	$i += $myXrayDots;
	push @myABSposX21, int( $myData[$i] );
	$i += $myXrayDots;
	push @myABSposY21, int( $myData[$i] );
	$i += $myXrayDots;
	push @myABSposX22, int( $myData[$i] );
	$i += $myXrayDots;
	push @myABSposY22, int( $myData[$i] );
	$i += $myXrayDots;
}

# kontrola dlugosci tabel: (w zasadzie zbedna)
if (
	(
		$#myABSposX11 -
		$#myABSposY11 +
		$#myABSposX12 -
		$#myABSposY12 +
		$#myABSposX21 -
		$#myABSposY21 +
		$#myABSposX22 -
		$#myABSposY22
	) != 0
  )
{
	print("rozne dlugosci. \n");
	exit();
}

# zlicz ilosc paneli
my $pnlnr = 0;

for ( my $i = 0 ; $i <= $#myData ; $i += 8 ) {
	if ( $i % ( 8 * $myXrayDots ) == 0 ) {
		$pnlnr++;    # zwiekszyc numer panela
	}
}

print( $pnlnr . " paneli \n" );

# zlicz liczbe elementow w tablicach (rowna wartosc)
my $myElements = (
	(
		$#myABSposX11 +
		  $#myABSposY11 +
		  $#myABSposX12 +
		  $#myABSposY12 +
		  $#myABSposX21 +
		  $#myABSposY21 +
		  $#myABSposX22 +
		  $#myABSposY22
	) / 8
) + 1;

print( $myElements . " elementow w kazdej tabeli\n" );

#showArray( \@myABSposX11 );
# showArray( \@myABSposY11 );

# @myABSposY22 zawiera calom kolumne myABSposY22 dla kazdego dota - przepisac!

# @myABSposY22 -> @pnlY22

print( 'ile?' . $#myABSposX21 . "\n" );

my $myStep = $myElements / $pnlnr;
print( "myStep: " . $myStep . "\n" );

my @x300h = (), my @y300h = ();
my @x200h = (), my @y200h = ();
my @x100h = (), my @y100h = ();
my @x0    = (), my @y0    = ();
my @x100l = (), my @y100l = ();
my @x200l = (), my @y200l = ();
my @x300l = (), my @y300l = ();

# teraz umieszczam te 8 tabel do dwoch nadrzednych tabel X i Y
my @myAllTabsX;
push @myAllTabsX, \@myABSposX11;
push @myAllTabsX, \@myABSposX12;
push @myAllTabsX, \@myABSposX21;
push @myAllTabsX, \@myABSposX22;

my @myAllTabsY;
push @myAllTabsY, \@myABSposY11;
push @myAllTabsY, \@myABSposY12;
push @myAllTabsY, \@myABSposY21;
push @myAllTabsY, \@myABSposY22;

# wielkosc tablicy nadrzednej
print( "#myAllTabsX: " . $#myAllTabsX . "\n" );

# wielkosc tablicy podrzednej
my $mySize = @{ $myAllTabsX[0] };

# dostep do elementu
print $myAllTabsX[0][0] . "\n";

my @keysX;
push @keysX, 'myABSposX11';
push @keysX, 'myABSposX12';
push @keysX, 'myABSposX21';
push @keysX, 'myABSposX22';

my %csvLayers;
my $myValue;

# przypisz numer panela do odpowiedniej tablicy 'X' w danym zakresie
for ( my $j = 0 ; $j <= $#myAllTabsX ; $j++ ) {

	$mySize = @{ $myAllTabsX[$j] };

	# print ("--> " . $mySize . "\n");

	# zerowanie tablic
	@x300h = ();
	@x200h = ();
	@x100h = ();
	@x0    = ();
	@x100l = ();
	@x200l = ();
	@x300l = ();

	# i liczby paneli
	$pnlnr   = 0;
	$myValue = 0;

	for ( $i = 0 ; $i < $mySize ; $i += 8 ) {

		$pnlnr++;
		$myValue = $myAllTabsX[$j][$i];

		# print ($j . " : " . $i . "\t" . $myValue . "\n");

		if ( $myValue >= -400 && $myValue < -300 ) {
			push @x300l, $pnlnr;
		}
		elsif ( $myValue >= -300 && $myValue < -200 ) {
			push @x200l, $pnlnr;
		}
		elsif ( $myValue >= -200 && $myValue < -100 ) {
			push @x100l, $pnlnr;
		}
		elsif ( $myValue >= -100 && $myValue < 100 ) {
			push @x0, $pnlnr;
		}
		elsif ( $myValue >= 100 && $myValue < 200 ) {
			push @x100h, $pnlnr;
		}
		elsif ( $myValue >= 200 && $myValue < 300 ) {
			push @x200h, $pnlnr;
		}
		elsif ( $myValue >= 300 && $myValue < 400 ) {
			push @x300h, $pnlnr;
		}
		else {
			print "---> $myValue \n";
		}
	}    # end 2. for

	# print ("x-> j: " . $j . "\t" . $keysX[$j] . "\n");

	#	print( "x300l:\t[" . $#x300l . "]\t" );
	#	print( "x200l:\t[" . $#x200l . "]\t" );
	#	print( "x100l:\t[" . $#x100l . "]\t" );
	#	print( "x0:\t[" . $#x0 . "]\t" );
	#	print( "x100h:\t[" . $#x100h . "]\t" );
	#	print( "x200h:\t[" . $#x200h . "]\t" );
	#	print( "x300h:\t[" . $#x300h . "]\n" );

	$csvLayers{'$keysX[$j]'}{'x300h'} = \@x300h;
	$csvLayers{ $keysX[$j] }{'x200h'} = \@x200h;
	$csvLayers{ $keysX[$j] }{'x100h'} = \@x100h;
	$csvLayers{ $keysX[$j] }{'x0'}    = \@x0;
	$csvLayers{ $keysX[$j] }{'x100l'} = \@x100l;
	$csvLayers{ $keysX[$j] }{'x200l'} = \@x200l;
	$csvLayers{ $keysX[$j] }{'x300l'} = \@x300l;

}    # end 1. for

my @keysY;
push @keysY, 'myABSposY11';
push @keysY, 'myABSposY12';
push @keysY, 'myABSposY21';
push @keysY, 'myABSposY22';

# to samo dla Y-kow
for ( my $j = 0 ; $j <= $#myAllTabsY ; $j++ ) {

	$mySize = @{ $myAllTabsY[$j] };

	@y300h = ();
	@y200h = ();
	@y100h = ();
	@y0    = ();
	@y100l = ();
	@y200l = ();
	@y300l = ();

	$pnlnr   = 0;
	$myValue = 0;

	for ( $i = 0 ; $i < $mySize ; $i += 8 ) {

		$pnlnr++;
		$myValue = $myAllTabsY[$j][$i];

		# print ($j . " : " . $i . "\t" . $myValue . "\n");

		if ( $myValue >= -400 && $myValue < -300 ) {
			push @y300l, $pnlnr;
		}
		elsif ( $myValue >= -300 && $myValue < -200 ) {
			push @y200l, $pnlnr;
		}
		elsif ( $myValue >= -200 && $myValue < -100 ) {
			push @y100l, $pnlnr;
		}
		elsif ( $myValue >= -100 && $myValue < 100 ) {
			push @y0, $pnlnr;
		}
		elsif ( $myValue >= 100 && $myValue < 200 ) {
			push @y100h, $pnlnr;
		}
		elsif ( $myValue >= 200 && $myValue < 300 ) {
			push @y200h, $pnlnr;
		}
		elsif ( $myValue >= 300 && $myValue < 400 ) {
			push @y300h, $pnlnr;
		}
		else {
			print "--> $myValue \n";
		}
	}

	# print ("y-> j: " . $j . "\t" . $keysY[$j] . "\n");

	#	print( "y300l:\t[" . $#y300l . "]\t" );
	#	print( "y200l:\t[" . $#y200l . "]\t" );
	#	print( "y100l:\t[" . $#y100l . "]\t" );
	#	print( "y0:\t[" . $#y0 . "]\t" );
	#	print( "y100h:\t[" . $#y100h . "]\t" );
	#	print( "y200h:\t[" . $#y200h . "]\t" );
	#	print( "y300h:\t[" . $#y300h . "]\n" );

	$csvLayers{'$keysY[$j]'}{'y300h'} = \@y300h;
	$csvLayers{'$keysY[$j]'}{'y200h'} = \@y200h;
	$csvLayers{'$keysY[$j]'}{'y100h'} = \@y100h;
	$csvLayers{'$keysY[$j]'}{'y0'}    = \@y0;
	$csvLayers{'$keysY[$j]'}{'y100l'} = \@y100l;
	$csvLayers{'$keysY[$j]'}{'y200l'} = \@y200l;
	$csvLayers{'$keysY[$j]'}{'y300l'} = \@y300l;
}

# slownie: daj panele dla przedzialu np. x300l i X11
# albo: daj panele dla przedzialu np. x0 i X12

# sie trza najsamfpjerf nauczyc haszy z dwoma kluczami.

print( $#{ $csvLayers{'myABSposX11'}{'x300h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX11'}{'x200h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX11'}{'x100h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX11'}{'x0'} } . "\t" );
print( $#{ $csvLayers{'myABSposX11'}{'x100l'} } . "\t" );
print( $#{ $csvLayers{'myABSposX11'}{'x200l'} } . "\t" );
print( $#{ $csvLayers{'myABSposX11'}{'x300l'} } . "\n" );

print( $#{ $csvLayers{'myABSposX12'}{'x300h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX12'}{'x200h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX12'}{'x100h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX12'}{'x0'} } . "\t" );
print( $#{ $csvLayers{'myABSposX12'}{'x100l'} } . "\t" );
print( $#{ $csvLayers{'myABSposX12'}{'x200l'} } . "\t" );
print( $#{ $csvLayers{'myABSposX12'}{'x300l'} } . "\n" );

print( $#{ $csvLayers{'myABSposX21'}{'x300h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX21'}{'x200h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX21'}{'x100h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX21'}{'x0'} } . "\t" );
print( $#{ $csvLayers{'myABSposX21'}{'x100l'} } . "\t" );
print( $#{ $csvLayers{'myABSposX21'}{'x200l'} } . "\t" );
print( $#{ $csvLayers{'myABSposX21'}{'x300l'} } . "\n" );

print( $#{ $csvLayers{'myABSposX22'}{'x300h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX22'}{'x200h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX22'}{'x100h'} } . "\t" );
print( $#{ $csvLayers{'myABSposX22'}{'x0'} } . "\t" );
print( $#{ $csvLayers{'myABSposX22'}{'x100l'} } . "\t" );
print( $#{ $csvLayers{'myABSposX22'}{'x200l'} } . "\t" );
print( $#{ $csvLayers{'myABSposX22'}{'x300l'} } . "\n" );

#print ("2. :" . @{ $csvLayers{ 'myABSposY11' }{'x300h'} } . "\n");

# dwie tabele nadrzedne dla offsetow X i Y
# uwaga na kolejnosc wstawiania!
my @myAllOffsetsX;
push @myAllOffsetsX, \@x300h;
push @myAllOffsetsX, \@x200h;
push @myAllOffsetsX, \@x100h;
push @myAllOffsetsX, \@x0;
push @myAllOffsetsX, \@x100l;
push @myAllOffsetsX, \@x200l;
push @myAllOffsetsX, \@x300l;

my @myAllOffsetsY;
push @myAllOffsetsY, \@y300h;
push @myAllOffsetsY, \@y200h;
push @myAllOffsetsY, \@y100h;
push @myAllOffsetsY, \@y0;
push @myAllOffsetsY, \@y100l;
push @myAllOffsetsY, \@y200l;
push @myAllOffsetsY, \@y300l;

# pokasz iksy
for ( my $j = 0 ; $j <= $#myAllOffsetsX ; $j++ ) {
	$mySize = @{ $myAllOffsetsX[$j] };

	#print( "x:[" . $mySize . "]\t" );
	for ( $i = 0 ; $i < $mySize ; $i++ ) {

		#printf( "%d ", $myAllOffsetsX[$j][$i] );
	}

	#print("\n");
}

# pokasz igreki
for ( my $j = 0 ; $j <= $#myAllOffsetsY ; $j++ ) {
	$mySize = @{ $myAllOffsetsY[$j] };

	#print( "y:[" . $mySize . "]\t" );
	for ( $i = 0 ; $i < $mySize ; $i++ ) {

		#printf( "%d ", $myAllOffsetsY[$j][$i] );
	}

	#print("\n");
}

# C:\Users\pkr.PRIDANA\.genesis\scripts\csv\032x0011.1237.2.Layers.xls

# do tont
####################################

## sprawdzenie X-ow
#print( "x300l:\t[" . $#x300l . "]\t" );
#foreach (@x300l) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x200l:\t[" . $#x200l . "]\t" );
#foreach (@x200l) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x100l:\t[" . $#x100l . "]\t" );
#foreach (@x100l) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x0:\t[" . $#x0 . "]\t" );
#foreach (@x0) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x100h:\t[" . $#x100h . "]\t" );
#foreach (@x100h) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x200h:\t[" . $#x200h . "]\t" );
#foreach (@x200h) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x300h:\t[" . $#x300h . "]\t" );
#foreach (@x300h) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
############
## sprawdzenie Y-ow
#print( "y300l:\t[" . $#y300l . "]\t" );
#foreach (@y300l) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "y200l:\t[" . $#y200l . "]\t" );
#foreach (@y200l) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "y100l:\t[" . $#y100l . "]\t" );
#foreach (@y100l) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "y0:\t[" . $#y0 . "]\t" );
#foreach (@y0) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "y100h:\t[" . $#y100h . "]\t" );
#foreach (@y100h) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "y200h:\t[" . $#y200h . "]\t" );
#foreach (@y200h) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "y300h:\t[" . $#y300h . "]\t" );
#foreach (@y300h) {
#	printf( "%d ", $_ );
#}
#print("\n");

#######################

# tego sie trzymac:
#$csvLayers{ $keys[0] } = \@x300l;

#my @keys;
#push @keys, 'myABSposX11';
#push @keys, 'myABSposY11';
#push @keys, 'myABSposX12';
#push @keys, 'myABSposY12';
#push @keys, 'myABSposX21';
#push @keys, 'myABSposY21';
#push @keys, 'myABSposX22';
#push @keys, 'myABSposY22';

########################

for ( $i = 0 ; $i <= $#myData ; $i += 8 ) {
	if ( $i % ( 8 * $myXrayDots ) == 0 ) {
		$pnlnr++;    # zwiekszyc numer panela
		             #print $pnlnr . "\t";

		# kluczem ma byc numer panela
		# $csvLayers{ $pnlnr } = \@tempArr;

	}

}

my $j       = 0;
my @tempArr = ();
my $temp;

#showHashArray( \%csvLayers );

#	if ( $i % ( 8 * $myXrayDots ) == 0 ) {
#		$pnlnr++;      # zwiekszyc numer panela
# print $i . "\t";
# 0 - 63 - 127 .. do myABSposX11

# kluczem ma byc numer panela

#$csvLayers{ $keys[$pnlnr] } = \@tempArr;
#		@tempArr = ();
#
#	}

#print( $i . " : " . $pnlnr . "\t" );
#print $#tempArr . "\t";
#showArray(\@tempArr);

#	print( $j . "\t" );

#	if ( $i % 8 == 0 ) {
#		$j = 0;
#	}
#	my $temp = int ($myData[$i]);
#	print $temp . "\t";
#
#	$csvLayers{ $keys[$j] } = int ($myData[$i]);
#	$j++;
#}

#$csvLayers{ $keys[0] } = \@x300l;
#$csvLayers{ $keys[1] } = \@x200l;
#$csvLayers{ $keys[2] } = \@x100l;
#$csvLayers{ $keys[3] } = \@x0;
#$csvLayers{ $keys[4] } = \@x100h;
#$csvLayers{ $keys[5] } = \@x200h;
#$csvLayers{ $keys[6] } = \@x300h;
#$csvLayers{ $keys[7] } = \@x300h;

foreach my $myByte (@myData) {

	#print $myByte . " ";
}

my $myRandomPanel;
my $myRandomXrayLayer;    # czyli te unikalne pady w kuponie Xray

# sie trza zastanowic co mam wyswietlic w statystyce
# np. osobno dla X i dla Y numery paneli w osobnych przedzialach wystepujace na kazdej warstwie (2 - 3,4 - 5,6 - 7,8 - 9 itd.)
# pacz tu: c:\work\Inspecta\CSV\032\032x0012.1538.6.csv

#my $myTestHash = {};

# 032x0011.1237

# posegreguj do poszczegolnych tabel (key-value)

# c:\Users\pkr.PRIDANA\.genesis\scripts\csv\032x0011.1237.2.Layers.xls (8 dotow)

for ( $i = 0 ; $i <= $#myData ; $i++ ) {
	if ( $i % ( 8 * $myXrayDots ) == 0 ) {
		$pnlnr++;    # zwiekszyc numer panela
		             #print( $i . " : " . $pnlnr . "\t" );
	}

	# ten modulo okresla X
	if ( $i % 2 == 0 ) {

		# segreguje koordynaty dla: ABSposX11 ABSposX12 ABSposX21 ABSposX22
		if ( $myData[$i] >= -300 && $myData[$i] < -200 ) {
			push @x300l, $pnlnr;
		}
		elsif ( $myData[$i] >= -200 && $myData[$i] < -100 ) {
			push @x200l, $pnlnr;
		}
		elsif ( $myData[$i] >= -100 && $myData[$i] < 0 ) {
			push @x100l, $pnlnr;
		}
		elsif ( $myData[$i] >= 0 && $myData[$i] < 100 ) {
			push @x0, $pnlnr;
		}
		elsif ( $myData[$i] >= 100 && $myData[$i] < 200 ) {
			push @x100h, $pnlnr;
		}
		elsif ( $myData[$i] >= 200 && $myData[$i] < 300 ) {
			push @x200h, $pnlnr;
		}
	}
	else {
		# segreguje koordynaty dla: ABSposY11 ABSposY12 ABSposY21 ABSposY22
		if ( $myData[$i] >= -300 && $myData[$i] < -200 ) {
			push @y300l, $pnlnr;
		}
		elsif ( $myData[$i] >= -200 && $myData[$i] < -100 ) {
			push @y200l, $pnlnr;
		}
		elsif ( $myData[$i] >= -100 && $myData[$i] < 0 ) {
			push @y100l, $pnlnr;
		}
		elsif ( $myData[$i] >= 0 && $myData[$i] < 100 ) {
			push @y0, $pnlnr;
		}
		elsif ( $myData[$i] >= 100 && $myData[$i] < 200 ) {
			push @y100h, $pnlnr;
		}
		elsif ( $myData[$i] >= 200 && $myData[$i] < 300 ) {
			push @y200h, $pnlnr;
		}
	}
}

# showArray(\@x100l);

# print( "\n" . $pnlnr . " paneli \n" );

#print( $#x200l . "\t" );
#print( $#x100l . "\t" );
#print( $#x0 . "\t" );
#print( $#x100h . "\t" );
#print( $#x200h . "\t" );
#print( $#x300h . "\n" );
#
#print( $#y300l . "\t" );
#print( $#y200l . "\t" );
#print( $#y100l . "\t" );
#print( $#y0 . "\t" );
#print( $#y100h . "\t" );
#print( $#y200h . "\t" );
#print( $#y300h . "\n" );

# potrzebuje wiedziec ktory to panel

#print( "x300l:\t[" . $#x300l . "]\t" );
#foreach (@x300l) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x200l:\t[" . $#x200l . "]\t" );
#foreach (@x200l) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x100l:\t[" . $#x100l . "]\t" );
#foreach (@x100l) {
#
#	#printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x0:\t[" . $#x0 . "]\t" );
#foreach (@x0) {
#
#	#printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x100h:\t[" . $#x100h . "]\t" );
#foreach (@x100h) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x200h:\t[" . $#x200h . "]\t" );
#foreach (@x200h) {
#	printf( "%d ", $_ );
#}
#print("\n");
#
#print( "x300h:\t[" . $#x300h . "]\t" );
#foreach (@x300h) {
#	printf( "%d ", $_ );
#}
#print("\n");

# c:\Users\pkr.PRIDANA\.genesis\scripts\csv\032x0011.1237.2.Layers.xls:
# time	N_layer	ABSposX11	ABSposY11	ABSposX12	ABSposY12	ABSposX21	ABSposY21	ABSposX22	ABSposY22

# time mozna potraktowac jako numer panela
# N_layer to nazwa warstwy, tutaj 6 warstw bo 6 dotow w kuponie XRAY: 2 - 3 - 4/5 - 6/7 - 8 - 9
# koordynaty dla 4 rogow: ABSposX11/ABSposY11	 ABSposX12/ABSposY12		ABSposX21/ABSposY21		ABSposX22/ABSposY22

