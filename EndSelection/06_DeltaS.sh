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
\033[1;34mUsage: $0 <bed.list> \033[0m
This program is designed to calculate Delta-S.
"
	exit 2
fi >/dev/stderr

bedlist=`realpath $1`

## modify the following path to the one containing all the programs in this repo if necessary
currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`
DIR=$PWD

mkdir -p feature_original feature_selection
## size
while read sid bed
do
	perl $PRG/bed2size.pl $bed $DIR/feature_original/$sid.size &
	perl $PRG/bed2size.pl $DIR/bed_selection/$sid.end.selected.bed $DIR/feature_selection/$sid.size &
	wait
done < $bedlist
