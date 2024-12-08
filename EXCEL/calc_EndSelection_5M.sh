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
\033[1;34mUsage: $0 <bed.list> <sample.info> [hg38]\033[0m
This program is designed to get feature from selection.
"
	exit 2
fi >/dev/stderr

bedlist=`realpath $1`
sampleinfo=$2
refgenome=${3:-hg38}


## modify the following path to the one containing all the programs in this repo if necessary
currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`
DIR=$PWD

mkdir -p size5M motif5M bed5M_selection
## filter bed file: keep autosome and mapQ>=30 reads

## End selection and genomewide N-index, 4 threads will be used by default
echo $bedlist
cd bed5M_selection
$PRG/cfDNA.end.selection $PRG/hg38.info $PRG/hsNuc0390101.DANPOSPeak.ext73.bed.gz $bedlist > Nindex.txt

rm -f $DIR/end5M.list
while read sid bed; do
	sample=${sid%%.*}
	mkdir -p $sample && mv $sid.end.selected.bed $sample
	echo -e "$sid\t$DIR/bed5M_selection/$sample/$sid.end.selected.bed" >> $DIR/end5M.list
done < $bedlist
cd $DIR

## size
while read sid bed; do
	sample=${sid%%.*}
	mkdir -p $DIR/size5M/feature_original/$sample $DIR/size5M/feature_selection/$sample
	perl $PRG/bed2size.pl $bed $DIR/size5M/feature_original/$sample/$sid.size &
	perl $PRG/bed2size.pl $DIR/bed5M_selection/$sample/$sid.end.selected.bed $DIR/size5M/feature_selection/$sample/$sid.size &
	wait
done < $bedlist

## motif
mkdir -p $DIR/motif5M/feature_original $DIR/motif5M/feature_selection
cd $DIR/motif5M/feature_original
sh $PRG/profile.motif.sh $bedlist $refgenome
cd $DIR/motif5M/feature_selection
sh $PRG/profile.motif.sh $DIR/end5M.list $refgenome
cd $DIR

## make stat
echo -e "SampleID\tNindex\tDeltaS\tDeltaM" > $DIR/features_5M.txt
while read sid Allreads Endselected Nindex; do
	[ ${sid:0:1} == "#" ] && continue
	sample=${sid%%.*}	

	S150=`cat $DIR/size5M/feature_original/$sample/$sid.size | awk '{if ($1 == "150")print}' | cut -f 4`
	S150_es=`cat $DIR/size5M/feature_selection/$sample/$sid.size | awk '{if ($1 == "150")print}' | cut -f 4`
	DeltaS=`perl -e "print $S150_es-$S150"`
	
	CCCA=`grep ^CCCA $DIR/motif5M/feature_original/$sample/$sid.left_right.motif | cut -f 5`
	CCCA_es=`grep ^CCCA $DIR/motif5M/feature_selection/$sample/$sid.left_right.motif | cut -f 5`
	DeltaM=`perl -e "print $CCCA_es-$CCCA"`

	echo -e "$sid\t$Nindex\t$DeltaS\t$DeltaM" >> $DIR/features_5M.txt
done < $DIR/bed5M_selection/Nindex.txt

## make matrix
python $PRG/get_matrix.py $DIR/features_5M.txt $sampleinfo
