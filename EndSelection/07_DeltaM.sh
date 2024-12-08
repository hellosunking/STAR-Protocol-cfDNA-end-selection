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
\033[1;34mUsage: $0 <bed.list> <end.list> [genome=hg38]\033[0m
This program is designed to calculate the values of Delta-M.
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

mkdir -p feature_original feature_selection bed_selection
## motif
cd feature_original
sh $PRG/profile.motif.sh $bedlist $refgenome
cd $DIR/feature_selection
sh $PRG/profile.motif.sh $endlist $refgenome
cd $DIR
