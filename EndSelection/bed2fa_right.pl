#!/usr/bin/perl
#
# Author: Ahfyth
#

use strict;
use warnings;

if( $#ARGV < 1 ) {
    print STDERR "\nUsage: $0 <genome.fasta> <in.bed> [in.bed ...]\n";
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
        open IN, "$ifile" or die( "$!" );
        my $ofile = $ifile;
        $ofile =~ s/bed$/fa/;
        open OUT, ">$ofile" or die( "$!" );
        my $cnt = 0;
        while( <IN> ) {
            chomp;
            my @l = split /\t/;  ## chr start(0-base) end(1-base) id score strand
            next unless exists $g->{$l[0]};  ## Check if chromosome exists in genome
            my ($s, $e) = split (/\-/, $l[3]);  ## Extract start and end coordinates
            my $id = "$l[0]:$s:$e";  ## Generate the sequence ID
            $id .= ":$l[5]" if $#l >= 5;  ## If strand info is available, add it to ID
            my $seq = substr($g->{$l[0]}, $l[1], $l[2] - $l[1]);  ## Extract sequence using 0-based start, 1-based end
            $seq = revcom($seq);  ## Reverse complement if strand is negative
            print OUT ">$id\n", $seq , "\n";
            ++ $cnt;
        }
        close IN;
        close OUT;
        exit(0);
    } else {  ## father process, do nothing
    }
}

until(wait() == -1){}
print STDERR "\rDone: Totally $index BED files loaded successfully.\n";

# Load genome sequence from FASTA file
sub load_genome {
    my $fasta = shift;
    my %g;
#    open FASTA, "$fasta" or die $!;
    open my $fasta_fh, '-|', "zcat $fasta" or die $!;
    my $chr = '0';
    while(<$fasta_fh>) {
	chomp;
        if( /^>(\S+)/ ) {
            $chr = $1;
            $g{$chr} = '';
        } else {
            chomp;
            $g{$chr} .= uc $_;
        }
    }
    close $fasta_fh;
    return \%g;
}

# Function to reverse complement a DNA sequence
sub revcom {
    my ($tmp) = @_;
    my @dna = split //, $tmp;
    my @revcom = reverse(@dna);
    my $rev = join("", @revcom);
    $rev =~ tr/ACGTacgt/TGCAtgca/;
    return $rev;
}
