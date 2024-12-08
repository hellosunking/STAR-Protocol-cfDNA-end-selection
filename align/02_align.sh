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
\033[1;34mUsage: $0 [options] <-o output.prefix> <-1 read1.fq> <-2 read2.fq>\033[0m

This program is designed for Bowtie2 alignment for DNA-seq data.

Options:
  -k kit     Set kit for trimming adaptors. Supports illumina, nextera, bgi.
  -g genome  Set genome. Supports hg38

  -s size    Set minimum read size. Default: 36
  -t thread  Set running threads. Default: auto
"
	exit 2
fi >/dev/stderr

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`

bowtie2=$PRG/bowtie2
samtools=$PRG/samtools

# default parameters
species="hg38"
seqKit="illumina"
minSize=36
cpunum=0
output=""
read1=""
read2=""

# read command line parameters
while getopts ":g:s:o:1:2:t:k:" OPTION
do
	case $OPTION in
		o)output="$OPTARG"
			;;
		1)read1="$OPTARG"
			;;
		2)read2="$OPTARG"
			;;
		g)species="$OPTARG"
			;;
		s)minSize="$OPTARG"
			;;
		t)cpunum="$OPTARG"
			;;
		k)seqKit="$OPTARG"
			;;
		\?)echo -e "***** ERROR: unsupported option detected. *****"
			;;
	esac
done

if [ -z "$output" ] || [ -z "$read1" ] || [ -z "$read2" ]
then
	echo "ERROR: Input/Output parameter is missing!"
	exit 1
fi


indexBase=$PRG/../bowtie2.index
index=$indexBase/$species
header=$index.sam.header
info=$index.info
info_no_chrM=$index.info.no.chrM
[ $cpunum -eq 0 ] && cpunum=`cat /proc/cpuinfo | grep processor | wc -l`

PHRED=33
param="--score-min L,0,-0.2 --ignore-quals --no-unal --no-head -p $cpunum"
PEspc="--minins 0 --maxins 1000 --no-mixed --no-discordant"	

## align main
$PRG/ktrim -1 $read1 -2 $read2 -t 8 -p $PHRED -o $output.ktrim -s $minSize -k $seqKit -c 2>$output.ktrim.log | \
$bowtie2 $param $PEspc -x $index --interleaved /dev/stdin -S $output.sam 2>$output.bowtie2.log

