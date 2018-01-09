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
	my %max;
	my %line;
	my ($i,$j)=(0,1);
	my $abs;

        my $result = GetOptions(
		"i=i"	=>	\$i,
		"j=i"	=>	\$j,
		"abs"	=>	\$abs
	);
	die "ERROR: $! " if (!$result);
			
	while(<>)
	{
		chomp;
		next if(/^$/ or /^#/);

		my @f=split;		
		my ($key,$val) =($f[$i],$f[$j]);
		
		if(!defined($max{$key}) or $max{$key}<$val)
		{
 			 $val=abs($val) if($abs);
			 $max{$key}=$val ;
			 $line{$key}=$_;
		}
	}		        	
	
	foreach my $key (sort {$max{$b}<=>$max{$a}} keys %max) 
	{ 
		print $line{$key},"\n"; 
	}
					
	exit 0;
}

