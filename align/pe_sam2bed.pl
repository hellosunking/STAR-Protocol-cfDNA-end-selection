#!/usr/bin/perl
#
# Author : Ahfyth (sunkun@szbl.ac.cn)
# Version: Dec 2019
#

use strict;
use warnings;
use FindBin;


if( $#ARGV < 2 ) {
	print STDERR "\nUsage: $0 <input.pe.[bs]am> <output.bed[.gz]> <out.size> [min.qual=0] [autosomal.only=0]\n\n",
				 "This program is designed to translate the Paired-End DNA-Seq SAM file to bed file.\n",
				 "Note that the SAM/BAM file donot need to be pos-sorted but MUST contain the mate information.\n\n";
	exit 2;
}

my $minqual  = $ARGV[3] || 0;
my $autoONLY = $ARGV[4] || 0;

if( $ARGV[0] =~ /bam$/ ) {
	open IN, "$FindBin::Bin/samtools view -@ 4 $ARGV[0] |" or die("$!");
} else {
	open IN, "$ARGV[0]" or die( "$!" );
}

my $outbed = $ARGV[1];
if( $outbed =~ /\.gz$/ ) {
	open OUT, "| gzip >$outbed" or die( "$!" );
} else {
	open OUT, ">$outbed" or die( "$!" );
}

my %size;
my %chrcount;
my ($chr, $pos, $strand);
my @l;
my $all = 0;
while( <IN> ) {
	next if /^@/;
	@l = split /\t/;
	my $mate = $l[8];	## QNAME FLAG RNAME POS MAPQ CIGAR RNEXT PNEXT TLEN SEQ QUAL EXTRA-MARKS
	next if $mate<=0 || $l[4]<$minqual;	## we only analyze the left-hand read
#	next if $l[2]=~/^chrM/;	## always discard chrM; BUT keep HBV, Lambda, EBV/E.coli
	next if $autoONLY && $l[2]!~/^chr\d+$/;

	## For BWA result
#	next unless $l[1] & 0x02;       ## the fragment is propoerly mapped to the reference genome
#	next if     $l[1] & 0x100;      ## discard secondary alignment
#	next unless $l[4] >= $minqual;  ## high quality mapping
#	next unless $l[6] eq '=';		## properly mapped pair
#	my $mate = $l[8];
#	next if $mate <= 0;

	++ $chrcount{$l[2]};

	$chr = $l[2];
	$pos = $l[3]-1;
	$strand = ($l[1] & 0x40) ? '+' : '-';	## the left-hand read is the first-segment, so it MUST be Forward strand; 0x10 should also work
	## for read-through fragments, using 0x40 is better?
#	$strand = ($l[1] & 0x10) ? '-' : '+';
	## for the left-most read:
	## if it is the first template, then it is read1 and the fragment should be on watson chain
	## otherwise it is read2 and the fragment should be on crick chain
	## for sorted BAM files, you cannot ensure the order of READ1 and READ2,
	## therefore need to check this flag while NOT 0x10 for strand
	print OUT "$chr\t$pos\t", $pos+$mate, "\t$l[0]\t$l[4]\t$strand\n";

	if( $chr =~ /\d$/ ) {	## size pattern: always autosome only
		$size{$mate} ++;
		++ $all;
	}
}
close IN;

close OUT;

## chr count
foreach my $chr ( sort keys %chrcount ) {
	print STDERR join("\t", $chr, $chrcount{$chr}), "\n";
}

if( $all == 0 ) {
#	print STDERR "ERROR: No valid reads for size distribution!\n";
	exit 0;
}

## size distribution
my $outsize = $ARGV[2];
exit 0 if $outsize eq "/dev/null";
my @fraglen = sort {$a<=>$b} keys %size;
my $maxLen = $fraglen[-1];

open OUT, ">$outsize" or die( "$!" );
print OUT "#Size\tCount\tPercent%\tCumulative\n";
my $cumu = 0;
for( my $i=1; $i<=$maxLen; ++$i ) {
	my $here = $size{$i} || 0;
	$cumu += $here;
	print OUT join("\t", $i, $here, $here/$all*100, $cumu/$all), "\n";
}
close OUT;

