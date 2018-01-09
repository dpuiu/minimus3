#!/usr/bin/env perl
 
use strict;
use warnings;

MAIN:
{
	while(<>)
	{
		my @F=split;

		next if($F[-3] eq $F[-2]);
		my @L=("$F[-3].","$F[-2].");


		if(/BEGIN/)  
		{
			$L[0].=5;
			$L[1].=($F[3]<$F[4])?"3":"5";
		} 
		elsif(/END/) 
		{
			$L[0].=3;
			$L[1].=($F[3]<$F[4])?"5":"3";
		}
		else
		{
			next;
		}
		$L[2]=-int(($F[6]+$F[7])*$F[9]/200);


 		@L[0,1]=@L[1,0] if($L[0] gt $L[1]); 
		print join "\t",@L; print "\n";
	}
	exit 0;
}
