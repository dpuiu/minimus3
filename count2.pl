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
	my %options;
	my %count;
	my $count;
	my ($i,$j)=(0,1);
	
        my $result = GetOptions(
		"percentage=s"	=>	\$options{percentage},		
		"i=s"	=> 	\$i,
		"j=s"   =>      \$j,
		"min=s"		=> 	\$options{min},
		"Max=s"	   	=>      \$options{max},
	);
        die "ERROR: $! " if (!$result);

	######################################################
	
	while(<>)
	{
		chomp;
		next if(/^$/) ;

		my @f=split;

		$count{$f[$i]}+=$f[$j];
		$count+=$f[$j];
	}

	##########################################################

	foreach my $key (sort {$count{$b}<=>$count{$a}} keys %count)
	{
		next if (defined($options{min}) and $count{$key}<$options{min});
		next if (defined($options{max}) and $count{$key}>$options{max});

                print $key,"\t", $count{$key};
                printf("\t%.4f",$count{$key}/$count) if($options{percentage});
                print "\n";
	}

	exit 0;
}
