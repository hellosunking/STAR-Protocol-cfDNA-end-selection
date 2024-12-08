#!/bin/bash
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

if [ $# -lt 1 ]	## no parameters
then
	echo -e "
\033[1;34mUsage: $0 <bed.list> \033[0m
This program is designed to statistics for N-index, Delta-S, Delta-M.
"
	exit 2
fi >/dev/stderr

bedlist=`realpath $1`

## modify the following path to the one containing all the programs in this repo if necessary
currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`
DIR=$PWD

## make stat
echo -e "SampleID\tNindex\tDeltaS\tDeltaM" > $DIR/features.txt
while read sid bed; do
	Nindex=`grep $sid $DIR/bed_selection/Nindex.txt | cut -f 4`
	S150=`cat $DIR/feature_original/$sid.size | awk '{if ($1 == "150")print}' | cut -f 4`
	S150_es=`cat $DIR/feature_selection/$sid.size | awk '{if ($1 == "150")print}' | cut -f 4`
	DeltaS=`perl -e "print $S150_es-$S150"`
	
	CCCA=`grep ^CCCA $DIR/feature_original/$sid.left_right.motif | cut -f 5`
	CCCA_es=`grep ^CCCA $DIR/feature_selection/$sid.left_right.motif | cut -f 5`
	DeltaM=`perl -e "print $CCCA_es-$CCCA"`

	echo -e "$sid\t$Nindex\t$DeltaS\t$DeltaM" >> $DIR/features.txt
done < $bedlist
