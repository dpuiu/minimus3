#!/usr/bin/env perl
 
use strict;
use warnings;
use Getopt::Long;

# help info
my $HELPTEXT = qq~
Program that filters a FASTA file

Usage: $0 -file id.txt -i column [-n] < file.fa

~;

###############################################################################
#
# Main program
#
###############################################################################

MAIN:
{
	# define variables
	my %opt;
	my %h;
	my $ok=1;
	$opt{i}=0;
	
        my $result = GetOptions(
                "f=s" 	=> \$opt{file},
		"i=i"	=> \$opt{i},
		"n"	=> \$opt{negate}
        );
        die "ERROR: $HELPTEXT " if (!$result);

       	defined($opt{file}) or die "ERROR: Input file missing" ;

	#########################################################
        # read the filter file
        open(IN,$opt{file}) or die "ERROR: Cannot open input file ".$! ;
        while(<IN>)
        {
		chomp;
                next if(/^$/ or /^#/);

		my @f=split;
                $h{$f[$opt{i}]}=1 if(@f>$opt{i});
        }
        close(IN);

        #########################################################
        # read the FASTA/delta file
        while(<>)
        {
               	if(/^>(\S+)/)
                {
                       	$ok=($h{$1})?1:0;
                }

                print if($ok xor $opt{negate});
        }

	exit 0;
}
