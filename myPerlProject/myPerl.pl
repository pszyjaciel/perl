#!/bin/env perl -w
# C:\Users\pkr.PRIDANA\workspace\myPerlProject 442x011-b-703 442x011-b-703_out
# http://www.comp.leeds.ac.uk/Perl/sandtr.html
# http://www.comp.leeds.ac.uk/Perl/matching.html

open myINPUTFILE,    "<", $ARGV[0] or die $!;
open myOUTPUTFILE, ">", $ARGV[1] or die $!;

#Read the input file line by line
while ( my $line = <myINPUTFILE> ) {
	#print $line;

	#$line =~ s/^M08\n$/M__\n/;

	# zapisywac linia po linii, gdy znajde co szukam, to zapisuje moja linie
	$lookingFor = "M08\n";
	if ( $line eq $lookingFor ) {
		$line = "M99\n";
		print myOUTPUTFILE $line;
		print("mam go. \n");
	}
	else {
		print myOUTPUTFILE $line;
		#print("albo i nie mam. \n");
	}
}

close myINPUTFILE;
close myOUTPUTFILE;

print("done. \n");

#	chomp;			       # usuwa koniec linii
#	    s/^--.*//;                 # no oracle comments
#	    s/^prompt.*//;             # no oracle prompt lines
#	    s/^\s+//;                  # no leading white
#	    s/\s+$//;                  # no trailing white
#	    s/\s+/ /;                  # replace series of white with one space

# \s to white space
# /g to global

# musi byc M08X<cyfra><cyfra><cyfra>Y<cyfra><cyfra><cyfra>T<cyfra><cyfra>
#s/M08\nX\d\d\d\nT\d\d/M08\nX888Y999\nT33/;
#s/M08\nX\d\d\d\r\nT\d\d/M08\r\nX888Y99\r\nT33/;
#s/M08\nX[0-1][0-9][0-9]/M08\nX888/;

#	s/X100Y009/X150Y009/;		# s/ otwiera
#	s/X105Y008/X155Y008/;		# ostatnia /; zamyka
#	s/X110Y008/X160Y008/;
#	s/X115Y008/X165Y008/;
#	s/X120Y008/X170Y008/;
#	s/X125Y008/X175Y008/;
#	s/X130Y008/X180Y008/;
#	s/X135Y008/X185Y008/;
#	s/X140Y008/X190Y008/;
#	s/X145Y009/X195Y009/;

#next unless length;    # next record unless anything left

