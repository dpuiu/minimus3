#!/usr/bin/env perl
 
use strict;
use warnings;

MAIN:
{
	while(<>)
	{
		#avoid
		#0	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16		17
		#1	1000	|	56	1055	|	1000	1000	|	99.90	|	1015	1055	|	1	1	B01_Ca_1508	H17_Ca_2216	[CONTAINED]
		#1	1007	|	50	1055	|	1007	1006	|	99.90	|	1028	1055	|	1	1	D26_Co_1338	H17_Ca_2216	[IDENTITY]
		#1	1015	|	7	1022	|	1015	1016	|	99.80	|	1015	1028	|	1	1	B01_Ca_1508	D26_Co_1338	[IDENTITY]

		my @F=split;

		print "$F[16]\t$F[17]\t$F[11]\n" if(/CONTAINED/ or /IDENTITY/ and $F[-2]<$F[-1] or /IDENTITY/ and $F[-2]==$F[-1] and $F[16] gt $F[17] );
		print "$F[17]\t$F[16]\t$F[12]\n" if(/CONTAINS/ or /IDENTITY/  and $F[-2]>$F[-1] or /IDENTITY/ and $F[-2]==$F[-1] and $F[16] lt $F[17] );
	}

	exit 0;
}
