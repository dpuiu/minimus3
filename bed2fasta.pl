#!/usr/bin/env perl
 
use strict;
use warnings;
use Getopt::Long;

# help info
my $HELPTEXT = qq~
Program that merges FASTA sequences based on a BED file.

Usage: $0 -bed file.bed < file.fasta

~;

###############################################################################
#
# Main program
#
###############################################################################

MAIN:
{
	# define variables
	my %opt;
	my ($id,%seq);
	
        my $result = GetOptions(
                "bed=s" 	=> \$opt{bed},
        );
        die "ERROR: $HELPTEXT " if (!$result);

	########################################################################
	# reading multi-FASTA file

	while(<>)
	{
		chomp;

		if(/^>(\S+)/)
		{
			$id=$1;
			$seq{$id}="";
		}
		else
		{
			$seq{$id}.=$_;
		}
	}

	########################################################################
	
	my @P=();
	my $mergedSeq="";
	open(IN,$opt{bed}) or die "Cannot open or read file $opt{bed}";
	while(<IN>)
	{

		my @F=split;

		if(@P and $P[0] ne $F[0])
		{
			print ">$P[0]\n$mergedSeq\n";
			$mergedSeq="";
			@P=();
		}

                my $seq=$seq{$F[3]};
                if($F[5] eq "-")
                {
                        $seq=reverse($seq);
                        $seq=~tr/ACGTacgt/TGCAtgca/;
                }
	
		if(@P)
		{
			my $gapLen=0;
			$gapLen=$F[1]-$P[2] if(@P);
			if($gapLen>0)
			{
				$mergedSeq.='N'x$gapLen if($gapLen);
			}
			elsif(length($seq)>=-$gapLen)
			{
				$seq=substr($seq,-$gapLen);
			}
			else
			{
				$seq="";
			}
		}
		$mergedSeq.=$seq;

		@P=@F;
	}
	
	if(@P)
	{
		print ">$P[0]\n$mergedSeq\n";
	}
			
	exit 0;
}

