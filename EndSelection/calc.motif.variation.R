#
# Author: Kun Sun @ SZBL
#
# R script for 
#

argv = commandArgs(T);
if( length(argv) != 1 ) {
	print( 'usage: R --slave --args <sample.list> < plot.R' );
	q();
}

bed = read.table( argv[1] );
ofile="motif.variation";

header=paste( "#Sid", "Entropy.5'-NNNN", "Entropy.NN-5'-NN", sep="\t" );
write.table( header, file=ofile, append=F, quote=F, sep="\t",
				eol="\n", row.names=F, col.names=F);

index=1;
for( sid in bed[,1] ) {
	motif = read.table( paste0( sid, ".left_right.motif"), row.names=1 );
#Motif	#Left	%Left	#Right	%Right
#AAAA	513466	0.6562	721032	0.9215
#AAAC	373986	0.4779	275197	0.3517
#AAAG	415954	0.5316	448894	0.5737
#AAAT	253846	0.3244	465682	0.5951
	motif = motif[ grepl( "^[ACGT]+$", row.names(motif)), ];

	m3 = motif[,2] / 100;	## extended mode
	m3.zero = which( m3 < 1e-16 );
	if( length(m3.zero) != 0  ) {
		m3 = m3[ - m3.zero ];
	}

	m5 = motif[,4] / 100;	## original mode
	m5.zero = which( m5 < 1e-16 );
	if( length(m5.zero) != 0  ) {
		m5 = m5[ - m5.zero ];
	}

	info = paste( sid, -sum(m5*log2(m5)), -sum(m3*log2(m3)), sep="\t" );
	write.table( info, file=ofile, append=T, quote=F, sep="\t",
					eol="\n", row.names=F, col.names=F);
}

