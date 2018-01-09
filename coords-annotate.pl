#!/usr/bin/perl

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
	my %opt;
	$opt{ignore}=20;
	$opt{percent}=0.05;                                # percent to ignore
        $opt{K}=0;

        my $result = GetOptions(
		"ignore=s"  =>   \$opt{ignore},
		"percent=s" =>   \$opt{percent},
		"all"	    =>   \$opt{all},
	);
	die "ERROR: $! " if (!$result);
	($opt{percent}>=0 and $opt{percent}<1) or die "ERROR: $opt{percent}";

	# parse input
	while(<>)
	{ 
		my @f=split;
		my $ignore=$opt{ignore};

		next if(scalar(@f)<13);
		next if($f[0]!~/^\d+$/);
		die "ERROR: $_" unless($f[9]=~/^\d+$/ or $f[9]=~/^\d+\.\d+$/ and $f[9]<=100);

		my $n=scalar(@f);
		if($f[$n-1]=~/\[/) 
		{
			pop @f;
			$n--;
		}
		$f[$n]="";
	 	next if($f[-2] eq $f[-3]);
			
		if($opt{percent})
		{
			my $ignoreP=$opt{percent}*(($f[11]<$f[12])?$f[11]:$f[12]);
			$ignore=$ignoreP if($ignore>$ignoreP);
		}

		$f[0]--;
		if($f[3]<$f[4]) 
		{
			$f[3]--;	
	                if($f[0]<=$ignore and $f[11]-$f[1]<=$ignore and $f[3]<=$ignore and $f[12]-$f[4]<=$ignore)       { $f[$n]="[IDENTITY]" }
	               	elsif($f[0]<=$ignore and $f[11]-$f[1]<=$ignore)                                                 { $f[$n]="[CONTAINED]" }
        	       	elsif($f[3]<=$ignore and $f[12]-$f[4]<=$ignore)                                                 { $f[$n]="[CONTAINS]" }
                       	elsif($f[0]<=$ignore and $f[12]-$f[4]<=$ignore)                                                 { $f[$n]="[BEGIN]" ; }  
                       	elsif($f[11]-$f[1]<=$ignore and $f[3]<=$ignore)                                                 { $f[$n]="[END]" ; }
			$f[3]++;
		}
		else
		{
			$f[4]--;
	                if($f[0]<=$ignore and $f[11]-$f[1]<=$ignore and $f[4]<=$ignore and $f[12]-$f[3]<=$ignore)     { $f[$n]="[IDENTITY]" }
	                elsif($f[0]<=$ignore and $f[11]-$f[1]<=$ignore)                                               { $f[$n]="[CONTAINED]" }
              		elsif($f[4]<=$ignore and $f[12]-$f[3]<=$ignore)                                               { $f[$n]="[CONTAINS]" }
                        elsif($f[0]<=$ignore and $f[4]<=$ignore)                                                     { $f[$n]="[BEGIN]" ; }
                        elsif($f[11]-$f[1]<=$ignore and $f[12]-$f[3]<=$ignore)                                       { $f[$n]="[END]" ; }
			$f[4]++;

		}
  
		$f[0]++;

		if($f[$n] or $opt{all})
		{
			print join "\t",@f;
			print "\n";
		}
	}
	
	exit 0;
}
