#!/usr/bin/perl
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :

use strict;
use warnings;

if( $#ARGV < 0 ) {
	print STDERR "\nUsage: $0 <in.sid>\n\n";
#	print STDERR "\nThis program is designed to \n\n";
	exit 2;
}

my $sid = shift;

## ktrim
my %ktrim;
open IN, "$sid.ktrim.trim.log" or die( "$!" );
while( <IN> ) {
	chomp;
	/^(\S+)/;	##Total	249352679
	my $k = $1;
	$k =~ s/://;
	/(\d+)$/;
	my $v = $1;
	$ktrim{$k} = $v;
}
close IN;

my $pass = $ktrim{Total}-$ktrim{Dropped};
print "Sid\t$sid",
		"\nOverall\t", digitalize( $ktrim{Total} ),
		"\nKtrim\t", digitalize( $pass ),
		"\n%\t", sprintf("%.1f", $pass/$ktrim{Total}*100), "\n";

my %botwie2;
open IN, "$sid.bowtie2.log" or die( "$!" );
while( <IN> ) {
	if( /^\s*(\d+).*aligned (concordantly )?exactly 1 time/ ) {
		$botwie2{uniq} = $1;
	} elsif( /^\s*(\d+).*aligned (concordantly )?>1 times/ ) {
		$botwie2{amb} = $1;
	}
}
close IN;

my $mapped = $botwie2{uniq}+$botwie2{amb};
print "Mappable\t", digitalize($mapped),
		"\n%\t", sprintf("%.1f", $mapped/$pass*100),
		"\n";
$pass = $botwie2{uniq}+$botwie2{amb};

exit unless -s "$sid.rmdup.log";	## in case rmdup is omitted

my $uniq;
open IN, "$sid.rmdup.log" or die( "$!" );
while( <IN> ) {
	if( /Unique\t(\d+)/ ) {
		$uniq = $1;
	}
}
close IN;

print "Unique\t", digitalize( $uniq ),
		"\nDup%\t", sprintf("%.1f", 100-$uniq/$pass*100), "\n";

if( -s "$sid.spikein.raw.chr.count" ) {
	open IN, "$sid.spikein.raw.chr.count" or die( "$!" );
	my $i = <IN>;
	close IN;
	chomp($i);
	my @l = split /\t/, $i;
	print "SpikeIn\t", digitalize( $l[1] ), "\n";
}

sub digitalize {
	my $v = shift;
	while($v =~ s/(\d)(\d{3})((:?,\d\d\d)*)$/$1,$2$3/){};
	return $v;
}

