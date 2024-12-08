#!/usr/bin/perl
#
# Author : Kun Sun @ SZBL (sunkun@szbl.ac.cn)
#
use strict;
use warnings;

if( $#ARGV < 1 ) {
	print STDERR "\nUsage: $0 <bed> <output.size=stdout>\n\n";
	print STDERR "\nThis program is designed to calculate size of cfDNA.\n\n";
	exit 2;
}

if( $ARGV[0] =~ /.gz$/ ) {
	open IN, "zcat $ARGV[0] |" or die("$!");
} else {
	open IN, "$ARGV[0]" or die( "$!" );
}

my %size;
my %chrcount;

my @l;
my $all = 0;
while( <IN> ) {
	@l = split/\t/;
	my $mate=$l[2]-$l[1];
	++ $chrcount{$l[0]};

	if( $l[0] =~ /^chr\d+$/ ) {	## autosome only
		$size{$mate} ++;
		$all ++;	## all fragments
	}
}
close IN;

## size distribution
my @fraglen = sort {$a<=>$b} keys %size;
my $maxLen = $fraglen[-1];

my $o = $ARGV[1] ;
open OUT, ">$o" or die( "$!" );

print OUT "#Size\tCount\tPercent\tCumulative\n";
my $cumu = 0;
for( my $i=1; $i<=$maxLen; ++$i ) {
	my $here = $size{$i} || 0;
	$cumu += $here;
	print OUT join("\t", $i, $here, $here/$all*100, $cumu/$all), "\n";
}
close OUT;

## chr count
foreach my $chr ( sort keys %chrcount ) {
	print STDERR join("\t", $chr, $chrcount{$chr}), "\n";
}

