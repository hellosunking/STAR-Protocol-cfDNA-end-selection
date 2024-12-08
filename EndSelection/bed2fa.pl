#!/usr/bin/perl
##
## Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
#

use strict;
use warnings;

if( $#ARGV < 1 ) {
	print STDERR "\nUsage: $0 <genome.fa> <in.bed> [in.bed ...]\n";
	print STDERR "\nThis program is designed to translate bed to fasta WITH PARALLEL ENABLED.\n\n";
	exit 2;
}

my $fasta = shift;
my $g = load_genome( $fasta );

my $index = 0;
foreach my $ifile ( @ARGV ) {
	++ $index;

	my $pid = fork();
	if( $pid < 0 ) {
		print STDERR "ERROR: fork failed!\n";
		exit( 1 );
	} elsif( $pid == 0 ) { ## sub-process
		open my $in, "<", $ifile or die( "$!" );
		my $ofile = $ifile;
		$ofile =~ s/bed$/fa/;
		open my $out, ">", $ofile or die( "$!" );
		print STDERR "\rLoading $index: $ifile => $ofile ... ";
		my $cnt = 0;
		while( <$in> ) {
			chomp;
			my @l = split /\t/;
			next unless exists $g->{$l[0]};
			my $s=$l[1]+1;
			my $e=$l[2];
			my $id = "$l[0]:$s:$e";
			print $out ">$id\n", substr($g->{$l[0]}, $l[1], $l[2]-$l[1]), "\n";
			++ $cnt;
		}
		close $in;
		close $out;
		exit(0);
	} else {	## father process, do nothing
	}
}

until(wait() == -1){}

print STDERR "\rDone: Totally $index BED files loaded successfully.\n";

sub load_genome {
	my $fasta = shift;
	my %g;
	open my $fasta_fh, '-|', "zcat $fasta" or die $!;
	my $chr = '0';
	while(<$fasta_fh>) {
	chomp;
		if( /^>(\S+)/ ) {
			$chr = $1;
			$g{$chr} = '';
		} else {
			$g{$chr} .= uc $_;
		}
	}
	close $fasta_fh;

	return \%g;
}
