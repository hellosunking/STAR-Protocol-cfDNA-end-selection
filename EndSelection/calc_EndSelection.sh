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
\033[1;34mUsage: $0 <bed.list> [hg38]\033[0m
This program is designed to get feature from selection.
"
	exit 2
fi >/dev/stderr

bedlist=`realpath $1`
refgenome=${2:-hg38}


## modify the following path to the one containing all the programs in this repo if necessary
currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`
DIR=$PWD

mkdir -p feature_original feature_selection bed_selection
## filter bed file: keep autosome and mapQ>=30 reads
rm -f $DIR/end.list
while read sid bed
do
	echo -e "$sid\t$DIR/bed_selection/$sid.end.selected.bed" >> $DIR/end.list
done < $bedlist

## End selection and genomewide N-index, 4 threads will be used by default
echo $bedlist
cd bed_selection
$PRG/cfDNA.end.selection $PRG/hg38.info $PRG/hsNuc0390101.DANPOSPeak.ext73.bed.gz $bedlist > $DIR/bed_selection/Nindex.txt
cd $DIR

## size
while read sid bed
do
	perl $PRG/bed2size.pl $bed $DIR/feature_original/$sid.size &
	perl $PRG/bed2size.pl $DIR/bed_selection/$sid.end.selected.bed $DIR/feature_selection/$sid.size &
	wait
done < $bedlist

## motif
cd feature_original
sh $PRG/profile.motif.sh $bedlist $refgenome
cd $DIR/feature_selection
sh $PRG/profile.motif.sh $DIR/end.list $refgenome
cd $DIR

## make stat
echo -e "SampleID\tNindex\tDeltaS\tDeltaM" > $DIR/features.txt
while read sid Allreads Endselected Nindex; do
	[ ${sid:0:1} == "#" ] && continue

	S150=`cat $DIR/feature_original/$sid.size | awk '{if ($1 == "150")print}' | cut -f 4`
	S150_es=`cat $DIR/feature_selection/$sid.size | awk '{if ($1 == "150")print}' | cut -f 4`
	DeltaS=`perl -e "print $S150_es-$S150"`
	
	CCCA=`grep ^CCCA $DIR/feature_original/$sid.left_right.motif | cut -f 5`
	CCCA_es=`grep ^CCCA $DIR/feature_selection/$sid.left_right.motif | cut -f 5`
	DeltaM=`perl -e "print $CCCA_es-$CCCA"`

	echo -e "$sid\t$Nindex\t$DeltaS\t$DeltaM" >> $DIR/features.txt
done < $DIR/bed_selection/Nindex.txt
