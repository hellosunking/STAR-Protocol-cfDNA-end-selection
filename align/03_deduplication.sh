#!/bin/bash
#
# Author: Kun Sun @ SZBL
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }
 
if [ $# -lt 1 ]	## no parameters
then
	echo -e "
\033[1;34mUsage: $0 [options] <-s samfile> <-o output.prefix> [-t thread] [-g genome=hg38]>\033[0m

This program is designed for deduplication for sam data.
"
	exit 2
fi >/dev/stderr

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`

samtools=$PRG/samtools

# default parameters
species="hg38"
cpunum=0

output=""
samfile=""

# read command line parameters
while getopts ":g:s:o:t:" OPTION
do
	case $OPTION in
		o)output="$OPTARG"
			;;
		s)samfile="$OPTARG"
			;;
		g)species="$OPTARG"
			;;
		t)cpunum="$OPTARG"
			;;
		\?)echo -e "***** ERROR: unsupported option detected. *****"
			;;
	esac
done

prgbase=$PRG
header=$PRG/$species.sam.header
info=$PRG/$species.info

## check threads
[ $cpunum -eq 0 ] && cpunum=`cat /proc/cpuinfo | grep processor | wc -l`
## remove dupliate and sam to bam conversion
$PRG/ksam_rmdup.pipe $info PE $samfile $output.rmdup > $output.rmdup.sam

cat $header $output.rmdup.sam | $samtools view --no-PG -b -@ $cpunum - | \
$samtools sort --no-PG -@ $cpunum -o $output.bam -
$samtools index -@ $cpunum $output.bam &
