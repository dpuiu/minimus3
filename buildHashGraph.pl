#!/usr/bin/env perl
 
use strict;
use warnings;
use Getopt::Long;
my %g;

# help info
my $HELPTEXT = qq~
Program that builds an cycle-free undirected graph. 


Usage: $0 -len qry.len < qry.links

~;

##############################################################################

sub path1
{
        my ($begin)=@_;
	my $path="";

        $begin=~/^(.+)\.(.)$/;
        my @begin=($1,$2);

        while($begin[0])
        {
		$path.="$begin ";
                $begin=$g{$begin};

                if($begin and $begin=~/^(.+)\.(.)$/)
                {
			$path.="$begin ";
                        @begin=($1,$2);
			$begin[1]=8-$begin[1];
			$begin="$begin[0].$begin[1]";
                }
                else
                {
                        @begin=()
                }
        }
	return $path;
}


sub path2
{
	my ($begin,$end)=@_;

	$begin=~/^(.+)\.(.)$/;
	my @begin=($1,$2);

        $end=~/^(.+)\.(.)$/;
        my @end=($1,$2);
	
	while($begin[0] and $begin[0] ne $end[0])
	{
		$begin[1]=8-$begin[1];

		$begin="$begin[0].$begin[1]";
		$begin=$g{$begin};

		if($begin and $begin=~/^(.+)\.(.)$/)
		{
        		@begin=($1,$2);
		}
		else
		{
			@begin=()
		}
	}

	if ($begin[0] and $begin[0] eq $end[0]) { return 1 }
	else                                    { return 0 }
		 
}

###############################################################################
#
# Main program
#
###############################################################################

MAIN:
{
	# define variables
	my %opt;
	my %gap;
	
	$opt{prefix}="super";

        my $result = GetOptions(
                "len=s" 	=> \$opt{len},
		"gap3"		=> \$opt{gap3},
		"prefix=s"	=> \$opt{prefix} 
	
        );
        die "ERROR: $HELPTEXT " if (!$result);

	#######################################################################

	my %len;
	open(IN,$opt{len}) or die $!;
	while(<IN>)
	{
		my @F=split;
		$len{$F[0]}=$F[1];
	}
	close(IN);

	#######################################################################
	while(<>)
	{
		next if(/^#/ or /^$/);
		/^(\S+)\s+(\S+)\s+(\S+)/ or die "ERROR: $_";

		my ($begin,$end,$gap)=($1,$2,$3);
		if($g{$begin} or $g{$end} or path2($begin,$end))	
		{
			print STDERR "#";
                }
		else 
		{
			$g{$begin}=$end;
			$g{$end}=$begin;
		
			if($opt{gap3})
			{		
				$gap{$begin}=$gap;
				$gap{$end}=$gap;
			}
                }

		print STDERR $_;
	}

	#print STDERR "#################\n";

	my $count=1;
	foreach my $begin (keys %g)
	{
		next if(!$g{$begin});

		$begin=~/^(.+)\.(\d)$/;
		my @begin=($1,$2);
		$begin[1]=8-$begin[1];

		next if($g{$begin} and $g{"$begin[0].$begin[1]"});

		my $path="$begin[0].$begin[1] ".path1($begin);
		my @path=split /\s+/,$path;
		
		my $delete=$path[-2];
		my $pos=0;
		while(@path)
		{ 
			my $next=shift @path; 
			$next=~/^(.+)\.(\d)$/;

                        my $id=$1;
                        my $dir="+";
                        $dir="-" if($2==3);

			die "ERROR $id\n" if(!defined($len{$id}));
                        print join "\t",($opt{prefix}.$count,$pos,$pos+$len{$id},$id,$len{$id},$dir);
                        print "\n";

			my $gap=20;
			$next=shift @path;
			$gap=$gap{$next} if(defined($gap{$next}));
                        $pos+=$len{$id}+$gap;
		}
		delete ($g{$delete});
		$count++;
	}

	exit 0;
}

