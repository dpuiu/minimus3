#!/usr/bin/env perl
 
use strict;
use warnings;
use Getopt::Long;

sub mySort
{
	my ($a1,$b1);
	$a=~/^(\d+)/ or die "ERROR:$a\n"; $a1=$1;
	$b=~/^(\d+)/ or	die "ERROR:$b\n"; $b1=$1;
	return $a1<=>$b1 ;
}


###############################################################################
#
# Main program
#
###############################################################################

MAIN:
{
	# define variables
	my %opt;
	my @L; 
	
	# validate input parameters
	my $result = GetOptions(
	);
			
	# read the Delta file
	# >2004.10 2052.5 29195 63212
	# 1 1223 61406 62627 9 9 0
	# 10
	# 0
	# 11536 29106 1491 20566 28 28 0
	# 22
	# 55
	# 0

	while(<>)
	{	
		my @F=split;

		#if($.<=2) { print }
		if(@F==2 or /^NUCMER/) { print }
		elsif(/^>/)
		{
			if($.>3)
			{
				@L=sort mySort @L;
				print join "", @L; 
			}
			@L=();
			print;	
		}	
		elsif(@F==7)
		{			
			push @L,$_;
		}
		else
		{
			$L[-1].=$_;
		}

	}
	
	if($.>3)
	{
		@L=sort mySort @L;
		print join "", @L;
	}

}
