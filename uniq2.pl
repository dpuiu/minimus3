#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long;

###############################################################################
#             
# Main program       
#
###############################################################################

MAIN:         
{
	my %h;
	my ($i,$j)=(0,1);

        my $result = GetOptions(
		"i=i"	=> \$i,
                "j=i"   => \$j
	);
	die "ERROR: $! " if (!$result);

	while(<>)
	{
		my @f=split;
		next if(/^$/ or /^#/);

		my $key="$f[$i] $f[$j]\n";
		print unless($h{$key});

		$h{$key}=1;
	}
     					
	exit 0;
}
