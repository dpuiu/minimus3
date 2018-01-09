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
	my $m;
	my $i=0;
	
	# validate input parameters
	my $result = GetOptions(	
		"i=i"	=>	\$i,
		"missing=s" =>	\$m,
	);
	die "ERROR: $!" if (!$result);
	
	###########################################################################

	open(IN,$ARGV[1]) or die "ERROR:$!";
	while(<IN>)
	{
		next if(/^$/ or /^#/);

		my @F=split;		
		my $F=shift @F;
		
    		$h{$F}=join "\t",@F;
	}
	close(IN);

	###########################################################################
	
	open(IN,$ARGV[0]) or die "ERROR:$!";
	while(<IN>)
	{
		next if(/^$/ or /^#/);
		
    		my @F=split;		
		my $F=$F[$i];

		if(defined($h{$F})) { print join "\t",(@F,$h{$F}); print "\n"; }
		elsif(defined($m))  { print join "\t",(@F,$m); print "\n"; }
	}
	close(IN);
	
	exit 0;
}

