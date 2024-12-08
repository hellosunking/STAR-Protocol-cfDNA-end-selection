set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

if [ $# -lt 1 ]	## no parameters
then
	echo -e "
\033[1;34mUsage: $0 [options] <bedlist> <genome> [layout=pe|se] [sizeRange=all]\033[0m
This program is designed for calculating motifs in cfDNA data.
"
	exit 2
fi >/dev/stderr

bedlist=`readlink -m $1`
refgenome=`readlink -m $2`
layout=${3:-PE}
sizeRange=${4:-all}

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`

left=""
right=""
while read sid bedfile
do
	echo -en "\rLoading $sid ... "	
	perl $PRG/grab.end.with.extension.pl $bedfile $sid $layout $sizeRange y 2 4 &

	left="$left $sid.left.outer2.inner4.bed"
	right="$right $sid.right.outer2.inner4.bed"
done < $bedlist
wait

echo -e "\rExtracting sequence ... "
perl $PRG/bed2fa.pl $refgenome $left
perl $PRG/bed2fa_right.pl $refgenome $right

length='all'
while read sid extra
do
	echo -en "\rLoading $sid ... "
	perl $PRG/extract.motif.with.extension.pl $sid.left.outer2.inner4.fa 4 $length> $sid.left.motif &
	perl $PRG/extract.motif.with.extension.pl $sid.right.outer2.inner4.fa 4 $length> $sid.right.motif &
	cat $sid.right.outer2.inner4.fa $sid.left.outer2.inner4.fa | \
	perl $PRG/extract.motif.with.extension.pl - 4 $length> $sid.left_right.motif &
done < $bedlist
wait

R --slave --args $bedlist < $PRG/calc.motif.variation.R
rm -f *.bed *.fa
