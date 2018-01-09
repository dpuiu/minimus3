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
	my $i=0;
	my $j=0;	 
	my %h;
	my $filter;
	
        my $result = GetOptions(
		"i=i"	=> \$i,
		"j=i"	=> \$j,		
	);
        die "ERROR: $! " if (!$result or @ARGV<2);
	
	#########################################
	
	open(IN,$ARGV[1]) or die("Cannot open input file".$!) ;  
	while(<IN>)
	{
		next if(/^#/);
    		my @f=split;
		shift @f if(@f and $f[0] eq "");

		next unless(defined($f[$j])); 
    		$h{$f[$j]}=1;
	}
	close(IN);

	#########################################
	
	open(IN,$ARGV[0]) or die("Cannot open input file".$!) ;	
	while(<IN>)
	{
		next if(/^#/);
    		my @f=split;
		shift @f if(@f and $f[0] eq "");

		next unless(defined($f[$i]));
    		print $_ unless(defined($h{$f[$i]}));
	}
	
	
	exit 0;
}
