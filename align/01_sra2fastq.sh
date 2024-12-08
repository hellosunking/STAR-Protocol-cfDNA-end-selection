#!/bin/bash
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

## input paramater:
## 1. a file with 2 columns: sid and sample.info
if [ $# -lt 1 ]	
then
	echo -e "
\033[1;34mUsage: $0 <sample.info>\033[0m
This program convert the sra file to FASTQ file.
"
	exit 2
fi >/dev/stderr

sampleinfo=`realpath $1`

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`
PROJECT_DIR=$PWD

mkdir -p fasterq_dump && cd fasterq_dump
while read sample info; do
	$PRG/fasterq-dump $PROJECT_DIR/$sample.sra
done < $sampleinfo
