
#!/bin/env perl -w

# wyswietla pliki w aktualnym katalogu
opendir myVERZ, '.' or die "$!\n";
my @liste = readdir(myVERZ);

for my $f (@liste) {
	next if $f eq '.' or $f eq '..';
	print "$f\n" if -r $f;
}
