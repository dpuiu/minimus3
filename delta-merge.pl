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
	# define variables
	my %opt;
        $opt{rm} = -200;
	$opt{rx} = 2000;
        $opt{qm} = -200;
        $opt{qx} = 2000;

        my ($ref,$qry,$ref_len,$qry_len,$err);
        my ($ref_start,$ref_end,$qry_start,$qry_end);
	my $dir; 
	
	# validate input parameters
	my $result = GetOptions(
                "rg=s"  =>	\$opt{rg},
                "qg=s"  =>	\$opt{qg},
		"rm=s"  =>      \$opt{rm},
		"rx=s"  =>      \$opt{rx},
                "qm=s"  =>      \$opt{qm},
                "qx=s"  =>      \$opt{qx},	
	);
			
	($opt{rm},$opt{rx})=(-$opt{rg},$opt{rg}) if(defined($opt{rg}));
	($opt{qm},$opt{qx})=(-$opt{qg},$opt{qg}) if(defined($opt{qg}));
	
	# read the Delta file
	while(<>)
	{	
		my @f=split;

		if(@f==2 or /^NUCMER/) { print }
		#if($.<=2) { print $_; }
		elsif(/^>/)
		{
			if($ref)
			{
				print join " ",($ref_start,$ref_end,$qry_start,$qry_end,$err,$err,0);	
				print "\n0\n";
			}
			
			print $_; 
				
			($ref,$qry,$ref_len,$qry_len)=@f;				
			$ref=~s/>//;
			
			($ref_start,$ref_end,$qry_start,$qry_end,$err,$dir)=(0,0,0,0,0,'');
		}	
		elsif(scalar(@f)==7)
		{			

			#>S.8098.12 scaffold47569 12545 13180
			#2085 2594 6640 7149 0 0 0
			#0
			#2404 2955 1 552 8 8 0
			#0

			if(!$ref_start)
			{ 
				($ref_start,$ref_end,$qry_start,$qry_end)=@f[0,1,2,3]; 
				$err=0;				
				$dir=($f[3]-$f[2]>0)?1:-1;
			}	
			elsif($f[0]>$f[1] or $f[0]<$ref_start) 
			{ 
				die "ERROR: $_" 
			}
			elsif($f[1]<=$ref_end)  {}
			elsif(($f[0]-$ref_end)<$opt{rm} or ($f[0]-$ref_end)>$opt{rx} or $dir*($f[3]-$f[2])<0 or $dir*($f[2]-$qry_start)<0 or $dir*($f[2]-$qry_end)<$opt{qm} or $dir*($f[2]-$qry_end)>$opt{qx})
			{
				print join " ",($ref_start,$ref_end,$qry_start,$qry_end,$err,$err,0);	
				print "\n0\n";
				
				($ref_start,$ref_end,$qry_start,$qry_end)=@f[0,1,2,3];
				$err=0;
				$dir=($f[3]-$f[2]>0)?1:-1;
			}
			else
			{
				($ref_end,$qry_end)=@f[1,3];
			}

			$err+=$f[4];
		}
	}
	
	if($ref)
	{
		print join " ",($ref_start,$ref_end,$qry_start,$qry_end,$err,$err,0);	
		print "\n0\n";
	}

}
