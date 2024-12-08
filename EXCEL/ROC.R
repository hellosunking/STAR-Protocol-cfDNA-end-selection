#
# Author: Kun Sun @SZBL (sunkun@szbl.ac.cn)
# Date  :
#

args <- commandArgs(trailing=T)
        aa<- args[1]

a=read.table(file = aa,header =TRUE)
name=paste0(aa,".average.roc.pdf")

pdf(name,h=4,w=4)

library(pROC);library(dplyr)
library(verification)
library(ROCR)


auc=vector()
pvalue=vector()

c<-a

modelroc=roc(c$Type,c$pred,levels=c(0,1),direction='<')

auc[1]=round(modelroc$auc,3)
print(modelroc)
ci.auc(modelroc)
ci.se(modelroc,specificities=c(0.95,0.98))


plot(modelroc,col="black")
abline(v=0.95,col="gray60",lty=2)
roc=roc.area(as.numeric(as.vector(c$Type)),c$pred)
print(roc$p.value)

se=sqrt(var(modelroc))
bb=modelroc$auc-0.5
z <- (bb / se)
p=2 * pt(-abs(z), df=Inf)
print(p)
pvalue[1]=round(p,4)

pred <- prediction( c$pred,c$Type)
perf <- performance(pred,"tpr","fpr")

cutoffs <- data.frame(cut=perf@alpha.values[[1]], fpr=perf@x.values[[1]], tpr=perf@y.values[[1]])
cutoffs <- cutoffs[order(cutoffs$tpr, decreasing=TRUE),]
print(subset(cutoffs, fpr <= 0.05))

l=vector()
l[1]="EXCEL"

legend("bottomright",legend=paste0(l[1],"(AUC=",auc[1],",P=",pvalue[1],")"),col=c("black"),lty=1,bty="n",cex=0.8)
dev.off()
