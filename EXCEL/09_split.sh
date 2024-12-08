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
\033[1;34mUsage: bash $0 <bedlist>\033[0m
This program is designed for splitting a BED file into 5-Mb segments.
"
	exit 2
fi >/dev/stderr

## input parameter: 1 bed.list file with 2 columns: sid /path/to/bed

bedlist=$1
currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`
DIR=$PWD

rm -f $DIR/bed5M.list
while read sid bed extra
do
	[ -d $DIR/bed5M_original/$sid ] || mkdir -p $DIR/bed5M_original/$sid
	
	while read chr spos epos extra
	do
		echo -e "$chr\t$spos\t$epos" > $DIR/hg38.$chr.$spos.$epos.bed
		$PRG/bedtools intersect -a $bed -b $DIR/hg38.$chr.$spos.$epos.bed -wa | gzip > $DIR/bed5M_original/$sid/$sid.$chr.$spos.$epos.bed.gz
		echo -e "$sid.$chr.$spos.$epos\t$DIR/bed5M_original/$sid/$sid.$chr.$spos.$epos.bed.gz" >> $DIR/bed5M.list
		rm -f $DIR/hg38.$chr.$spos.$epos.bed
	done < $PRG/hg38.bin5M.bed
done < $bedlist

echo "The 5M-BED file has been generated, and you can proceed with the subsequent analysis."
