#
# Author: Kun Sun @SZBL (sunkun@szbl.ac.cn)
# Date  :
#

library(pROC);
library(dplyr);
library(ROCR)
#library(Rmisc)

args <- commandArgs(trailing=T)
af<- args[1]

a<-read.table(file = af, header=T,row.names=NULL)
auc=vector()


for (i in unique(a$fold)){
	c<-a[which(a$fold==i),]
	modelroc=roc(response=c$Type,predictor=c$pred,levels=c(0,1),direction='<')
	auc[i]=round(modelroc$auc,3)
}
write.table(auc, paste0(af,".AUC.txt"),sep="\t", quote=F, col.names=T, row.names=F)


AUC=auc
library(ggplot2)
pdf(paste0(af,".AUC.hist.pdf"))
hist(AUC,breaks=20)
dev.off()

quantile(auc,c(0.25,0.5,0.75))
