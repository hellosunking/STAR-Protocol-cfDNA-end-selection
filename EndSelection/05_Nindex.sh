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
if [ $# -lt 1 ]	## no parameters
then
	echo -e "
\033[1;34mUsage: $0 <bed.list>\033[0m
This program calculates Nindex.
"
	exit 2
fi >/dev/stderr

bedlist=`realpath $1`

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`
DIR=$PWD

## End selection and genomewide N-index, 4 threads will be used by default
mkdir -p bed_selection && cd bed_selection
$PRG/cfDNA.end.selection $PRG/hg38.info $PRG/../hsNuc0390101.DANPOSPeak.ext73.bed.gz $bedlist > $DIR/bed_selection/Nindex.txt

## end.list
rm -f $DIR/end.list
while read sid bed
do
	echo -e "$sid\t$DIR/bed_selection/$sid.end.selected.bed" >> $DIR/end.list
done < $bedlist
