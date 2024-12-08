#!/usr/bin/perl
#
# Author: Kun Sun @ SZBL
#

use strict;
use warnings;

if( $#ARGV < 0 ) {
	print STDERR "\nUsage: $0 <in.fa> [motif.size=4] [fragment length=all] [discard.N=y|n] \n";
	print STDERR "\nThis program is designed to \n\n";
	exit 2;
}

my $size = $ARGV[1] || 4;
my $frag_len = $ARGV[2] || "all";
my ($min,$max)=(0,1000);
unless($frag_len eq "all"){
	($min,$max)=split(/,/,$frag_len);
}
my $discardN = 1;
if( $#ARGV >= 4 ) {
	$discardN = 0 if $ARGV[3] =~ /^no?$/i;
}

my $all = 0;
my (%left, %right);
open IN, "$ARGV[0]" or die( "$!: $ARGV[0]" );
while( my $id=<IN> ) {
	my $seq = <IN>;
	next if $seq =~ /N/;
	chomp( $id );   ##>chr1:10058:10064
        my @l = split /:/, $id;
        my $length = $l[2] - $l[1];
	next if($length<$min ||$length> $max);
	chomp( $seq );
	my $a = uc substr( $seq, 0, $size );
	$left{$a} ++;
	my $b = uc substr( $seq, length($seq)-$size );
	$right{$b} ++;

	++ $all;
}
close IN;

print "#Motif\tBreakpoint\t%Breakpoint\tEnd\t%End\n";
my @k1=keys %left;
my @k2=keys %right;
my %k;
++$k{$_} foreach ( @k1, @k2 );

foreach my $m (sort keys %k) {
	my $l = $left{$m}  || 0;
	my $r = $right{$m} || 0;
	next if $discardN && $m=~/N/i;
	print join("\t", $m, $l, $l/$all*100, $r, $r/$all*100), "\n";
}

