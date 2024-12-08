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
\033[1;34mUsage: $0 <bed.list> <end.list> <refgenome>\033[0m
This program is designed to get feature from selection.
"
	exit 2
fi >/dev/stderr

bedlist=`realpath $1`
endlist=`realpath $2`
refgenome=`realpath $3`


## modify the following path to the one containing all the programs in this repo if necessary
currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`
DIR=$PWD

## motif
mkdir -p $DIR/motif5M/feature_original $DIR/motif5M/feature_selection
cd $DIR/motif5M/feature_original
sh $PRG/profile.motif.sh $bedlist $refgenome > motif5M.log
cd $DIR/motif5M/feature_selection
sh $PRG/profile.motif.sh $endlist $refgenome >> motif5M.log
