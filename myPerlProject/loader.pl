#!/usr/bin/perl -w
# http://docstore.mik.ua/orelly/perl/cookbook/ch15_18.htm 

use strict;
use Win32;
use Win32::Process;

sub print_error() {
    return Win32::FormatMessage( Win32::GetLastError() );
}

# Create the process object.
Win32::Process::Create($Win32::Process::Create::ProcessObj,
    'C:/Perl/bin/perl.exe',            # Whereabouts of Perl
    'perl myConvertUI2.pl',            #
    0,                                 # Don't inherit.
    DETACHED_PROCESS,                  #
    ".") or                            # current dir.
die print_error();
