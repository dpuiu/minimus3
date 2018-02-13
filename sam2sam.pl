#!/usr/bin/env perl
 
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
	while(<>)
	{
		if(/^\@/) { print }
		else
		{
			my @F=split;
	 		next if($F[1] & 0x4);
		
		 	@F=@F[0..11]; 
                        $F[9]="." ;
 	                print join "\t",@F; print "\n";
		}
	}
			
	exit 0;
}
