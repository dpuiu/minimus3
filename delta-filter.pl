#!/usr/bin/perl -w
 
use strict;
use warnings;

###############################################################################

sub min
{
	my @F=@_;
	return ($F[0]<$F[1])?$F[0]:$F[1];
}

sub max
{
        my @F=@_;
        return ($F[0]>$F[1])?$F[0]:$F[1];
}

sub included
{
	my @F=@_;
	my $min=min($F[2],$F[3]);
	my $max=max($F[2],$F[3]);

	if($min<=$F[0] and $F[0]<=$max and $min<=$F[1] and $F[1]<=$max) { return 1 }
	else                                                            { return 0 }
} 
		

MAIN:
{
	my ($ref,$qry,$skipPair,$skipAlign);
	my @P;
		
	##################################################	
	# read the Delta file
	
	while(<>)
	{			

		my @F=split;

		if(/^>/)
		{
			($skipPair,$skipAlign)=(0,0);
			if(/^>(\S+) (\S+)/ and $1 eq $2) { $skipPair=1 }

			@P=();
		}
		elsif(@F==7)
		{
			die "ERROR: $_" if(@P and $F[0]<$P[0]);   

			if(@P and $F[1]<$P[1])                          { $skipAlign=1; }
                        elsif(@P and included($F[2],$F[3],$P[2],$P[3])) { $skipAlign=1; }
#			else                                            { $skipAlign=0; @P=@F; }
		}

		print unless($skipPair or $skipAlign);
	}

	exit 0;
}
