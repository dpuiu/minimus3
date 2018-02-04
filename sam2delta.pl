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
	my (%ref_len,%qry_len);
	my ($pref,$pqry);

        my $result = GetOptions(
                "rf|ref_file=s"     =>      \$options{ref_file},
                "qf|qry_file=s"     =>      \$options{qry_file},		
 		"rl|ref_len=s"      =>      \$options{ref_len},
		"ql|qry_len=s"      =>      \$options{qry_len},	
		"ni"		    =>	    \$options{ni},	# skip ref=qry
		"i|min_identity=i"  =>      \$options{min_identity},
                "q|min_mapQuality"  =>	    \$options{min_mapQuality},
		"offset"	    =>      \$options{offset}	
	);
	die "ERROR: $! " if (!$result);
	die "ERROR: $! " if (defined($options{identity}) and ($options{identity}<0 or $options{identity}>100));
	$options{min_identity}=1-$options{min_identity}/100 if(defined($options{min_identity}));

	####################################

	if($options{ref_file})
	{
		print $options{ref_file}," ",$options{qry_file},"\n","NUCMER","\n";

		open(IN,$options{ref_len}) or die $!;
		while(<IN>)
		{
			my @f=split;
			$ref_len{$f[0]}=$f[1];
		}
		close(IN);

	        open(IN,$options{qry_len}) or die $!;
        	while(<IN>)
	        {
        	        my @f=split;
                	$qry_len{$f[0]}=$f[1];
	        }
        	close(IN);
	}

	####################################
	while(<>)
	{

		if(/^\[/)   { next }
		elsif(/\[/) { die "ERROR: $_"}
		elsif(/^@/)
		{
			if(/^\@PG/ and /(\S+.fa\S*)/ and !$options{ref_file})
			{
				print $1," ",$1,"\n","NUCMER","\n";
				$options{ref_file}=1;
			}
			elsif(/^\@SQ\s+SN:(\S+)\s+LN:(\d+)/)
			{
				$ref_len{$1}=$2 if(!$ref_len{$1});
				$qry_len{$1}=$2 if(!$qry_len{$1});
        		}
			next;
		}

                my @f=split;
                my ($ref,$ref_begin,$ref_end);
                my ($qry,$qry_begin,$qry_end,$qry_dir);
		my $cigar;
                my $snps=0;
		my $snpsDetail="";
		my $snpsMatch="";

                next if($f[1] &  0x4 );
                next if($f[2] eq "*");
		#next if($f[1] and $f[1] & 0x100);       # secondary alignment: meeded mby minmap all vs all
                next if(defined($options{min_mapQuality}) and $f[4]<$options{min_mapQuality});

                $qry=$f[0];
		$ref=$f[2];

		next if($options{ni} and $qry eq $ref);

                $qry_dir=($f[1] & 0x10 )?"-":"+";       # $f[1]: 0x10 SEQ being reverse complemented
                $ref_begin=$ref_end=$f[3]-1;            # $f[3]: 1-based leftmost mapping POSition
                $cigar=$f[5];

		if($qry_dir eq "-")
		{
			my $newCigar="";
			while($cigar and $cigar=~/(\d+)(\w)(.*)/)
			{
				$newCigar=$1.$2.$newCigar;
				$cigar=$3;
			}
			$cigar=$newCigar;
		}

                $qry_begin=$qry_end=0;
                if($cigar=~/^(\d+)([SH])(.+)/)
                {
                        $qry_begin=$qry_end=$1;
			$cigar=$3;
                }

                while($cigar and $cigar=~/(\d+)(\w)(.*)/)
                {
			#10M4I64M	# insert in query
			#-11
                        #-1
                        #-1
                        #0

			#10M2D62M	# del from query
			#11
			#1
			#0

			if($2 eq "M")
			{
				$qry_end+=$1;
				$ref_end+=$1;
				$snpsMatch=$1+1;
			}
                        elsif($2 eq "I")
                       	{
                                $qry_end+=$1;
                               	$snps+=$1;
				$snpsDetail.="-$snpsMatch\n" if($snpsMatch); 
				$snpsDetail.="-1\n"x($1-1); 
                        }
                      	elsif($2 eq "D")   
                       	{
                                $ref_end+=$1;
				$snps+=$1;
				$snpsDetail.="$snpsMatch\n" if($snpsMatch);
                                $snpsDetail.="1\n"x($1-1); 
                       	}
                        elsif($2 eq "N")   
                        {
                                $ref_end+=$1;
			}

                        $cigar=$3;
		}

		$snps=$1 if(/NM:i:(\d+)/);
		next if($options{min_identity} and ($snps/($ref_end-$ref_begin)>$options{min_identity} or $snps/($qry_end-$qry_begin)>$options{min_identity})); 

		$ref_begin++; $qry_begin++;
		($qry_begin,$qry_end)=($qry_end,$qry_begin) if($qry_dir eq "-");
		($qry_begin,$qry_end,$qry)=($qry_begin+$2,$qry_end+$2,$1) if($options{offset} and $qry=~/(.+):(\d+)-(\d+)$/);

		if($ref_begin>=0 and $ref_end<=$ref_len{$ref} and $qry_begin>=0 and $qry_end>=0 and $qry_begin<=$qry_len{$qry} and $qry_end<=$qry_len{$qry})
		{
			if(!defined($pref) or $pref ne $ref or $pqry ne $qry)
			{
				print join " ",(">".$ref,$qry,$ref_len{$ref},$qry_len{$qry}); print "\n";
				($pref,$pqry)=($ref,$qry);
			}
			print join " ",($ref_begin,$ref_end,$qry_begin,$qry_end,$snps,$snps,0); print "\n";
			print $snpsDetail;
			print "0\n";
		}
		else
		{
			warn $_;
		}
	}
	exit 0;
}
