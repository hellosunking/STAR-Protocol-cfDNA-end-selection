#!/bin/bash
#
# Author: Kun Sun @ SZBL
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

if [ $# -lt 1 ]	## no parameters
then
	echo -e "
\033[1;34mUsage: $0 [options] <output.bam> \033[0m

This program is designed for converting BAM to BED  .
"
	exit 2
fi >/dev/stderr

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`

# default parameters
bamfile=$1
output=${bamfile%%.*}
echo $output"\t"$bamfile

## sam to bed
echo "sam to bed"
perl $PRG/pe_sam2bed.pl $bamfile /dev/stdout $output.size 0 2>$output.chr.count | \
	perl -lane 'print if $F[4]>=30' | sort -k1,1 -k2,2n -k3,3n | $PRG/gzip - > $output.Q30.bed.gz

## make statistics
perl $PRG/make.stat.pl $output > $output.align.stat

## clean up
rm -rf $output.sam $output.rmdup.sam
echo "Done: the output files are '$output.bam' ,'$output.bed.gz' and '$output.Q30.bed.gz'."
