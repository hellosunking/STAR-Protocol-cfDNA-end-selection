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
\033[1;34mUsage: $0 <matrix> <output>\033[0m
This program is designed to build model.
"
	exit 2
fi >/dev/stderr

matrix=`realpath $1`
output=$2

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`

mkdir -p $output && cd $output

## building models
Rscript $PRG/GBM.R $matrix ./ >log
Rscript $PRG/cross.validation.AUC.R GBM.pred.txt
Rscript $PRG/ROC.R EXCEL.score.txt >>log
cd ../
