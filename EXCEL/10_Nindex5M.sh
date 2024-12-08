#!/bin/bash
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

## input paramater:
## 1. a file with 2 columns: sid and /path/to/bed
## 2. path to hg38 genome in fasta format
if [ $# -lt 1 ]	## no parameters
then
	echo -e "
\033[1;34mUsage: $0 <bed.list>\033[0m
This program is designed to calculate N-index from 5M-BED file.
"
	exit 2
fi >/dev/stderr

bedlist=`realpath $1`

## modify the following path to the one containing all the programs in this repo if necessary
currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`
DIR=$PWD

mkdir -p bed5M_selection && cd bed5M_selection
## End selection and genomewide N-index, 4 threads will be used by default
echo $bedlist
$PRG/cfDNA.end.selection $PRG/hg38.info $PRG/../hsNuc0390101.DANPOSPeak.ext73.bed.gz $bedlist > Nindex5M.txt

rm -f $DIR/end5M.list
while read sid bed; do
	sample=${sid%%.*}
	mkdir -p $sample && mv $sid.end.selected.bed $sample
	echo -e "$sid\t$DIR/bed5M_selection/$sample/$sid.end.selected.bed" >> $DIR/end5M.list
done < $bedlist
