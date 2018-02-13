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
	# define variables
	my %options;
	my ($pref,$pqry);
        my $result = GetOptions(
                "rf|ref_file=s"     =>      \$options{ref_file},
                "qf|qry_file=s"     =>      \$options{qry_file},
		"ni"		    =>	    \$options{ni},	# skip ref=qry
	);
	die "ERROR: $! " if (!$result or !defined($options{ref_file}) or !defined($options{qry_file}) );

	####################################

	print $options{ref_file}," ",$options{qry_file},"\n","NUCMER","\n";
	while(<>)
	{
		#0		1	2	3	4	5		6	7	8	9	10	11
		#A05_Co_1005	3312	3	3302	+	A21_Co_1328	3302	2	3301	3299	3299	255	cm:i:1129
		#A06_Co_4683	4303	3	4299	-	C25_Ca_10121	4162	28	4151	3462	4296	255	cm:i:890
		###############################

		exit 1 if(/\[/ or /\]/);

                my @f=split;
                my ($ref,$ref_len,$ref_begin,$ref_end)=@f[5,6,7,8];
                my ($qry,$qry_len,$qry_begin,$qry_end,$qry_dir)=@f[0,1,2,3,4];
                my $snps=$f[10]-$f[9];

		next if($options{ni} and $qry eq $ref);

		$ref_begin++;
		$qry_begin++;
		($qry_begin,$qry_end)=($qry_end,$qry_begin) if($qry_dir eq "-");

		if(!defined($pref) or $pref ne $ref or $pqry ne $qry)
		{
			print join " ",(">".$ref,$qry,$ref_len,$qry_len); print "\n";
		}
		print join " ",($ref_begin,$ref_end,$qry_begin,$qry_end,$snps,$snps,0); print "\n";
		print "0\n";

		($pref,$pqry)=($ref,$qry);
	}
	exit 0;
}
