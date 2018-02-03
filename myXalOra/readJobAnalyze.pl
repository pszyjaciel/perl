#!/bin/env perl -w

sub fileExist {
	my $myListe      = shift;
	my @myArray      = @$myListe;
	my $mySearchFile = shift;

	for my $myFile (@myArray) {
		if ( $myFile eq '.' or $myFile eq '..' ) {
			next;    # przeskocz do kolejnego
		}
		if ( $myFile eq $mySearchFile ) {
			return 1;
		}
	}
	return 0;
}

sub getLayerParams {
	my $varenummer = shift;			# przychodzi bez kropki
	$varenummer = substr( $varenummer, 0, -4 ) . "\." . substr( $varenummer, -4 ); 		# wstawia kropke
	my $myFile     = 'job_analyze';
	my $myPath     = $ENV{GENESIS_DATA} . '/jobs/' . $varenummer . '/user/';
		
	my %myLayerParams = ();
	opendir myVERZ, $myPath or die "$!\n";
	my @liste = readdir(myVERZ);

	# check if file exists, if not then exit
	my $rs = fileExist( \@liste, $myFile );    # po co ta palka w liste?
	if ( $rs != 1 ) {
		print "file not found. program exits.";
		return %myLayerParams;
	}

	my $myFilePath = $myPath . $myFile;
	print("$myFilePath \n");

	open( $myINPUTFILE, $myFilePath ) or exit;
	@data = <$myINPUTFILE>;    # read the file into the memory array
	close $myINPUTFILE;

	$num_byte_read = $#data;
	for ( my $i = 0 ; $i <= $num_byte_read ; $i++ ) {

		my @myParams = ();     # reset array
		@myParams = $data[$i] =~ /(\w+(?:'\w+)*)/g;

		if ( $data[$i] =~ /^top/ ) {
			$myLayerParams{'top'} = [@myParams];
		}
		elsif ( $data[$i] =~ /il2p/ ) {
			$myLayerParams{'il2p'} = [@myParams];
		}
		elsif ( $data[$i] =~ /il3p/ ) {
			$myLayerParams{'il3p'} = [@myParams];
		}
		elsif ( $data[$i] =~ /bottom/ ) {
			$myLayerParams{'bottom'} = [@myParams];
		}
	}
	return %myLayerParams;
}

return 1;
