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
This program is designed to get feature from selection.
"
	exit 2
fi >/dev/stderr

bedlist=`realpath $1`

## modify the following path to the one containing all the programs in this repo if necessary
currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`
DIR=$PWD

mkdir -p size5M 
## End selection and genomewide N-index, 4 threads will be used by default

## size
while read sid bed; do
	sample=${sid%%.*}
	mkdir -p $DIR/size5M/feature_original/$sample $DIR/size5M/feature_selection/$sample
	perl $PRG/bed2size.pl $bed $DIR/size5M/feature_original/$sample/$sid.size &
	perl $PRG/bed2size.pl $DIR/bed5M_selection/$sample/$sid.end.selected.bed $DIR/size5M/feature_selection/$sample/$sid.size &
	wait
done < $bedlist
