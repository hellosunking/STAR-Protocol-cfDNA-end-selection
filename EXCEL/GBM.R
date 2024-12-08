#
# Author: Kun Sun @SZBL (sunkun@szbl.ac.cn)
# Date  :
#

library(pROC)
library(caret)
library(tidyverse)

args <- commandArgs(trailing=T)
        aa<- args[1]
	bb<-args[2]

setwd(bb)	
train<-read.table(file = aa,header =TRUE,row.names=1)
train[,-ncol(train)]=scale(train[,-ncol(train)])
train$Type=ifelse(train$Type=="Control","Control","Cancer")
data_train=as.matrix(train[,-ncol(train)])

# pack the training control parameters
set.seed(123)
seeds <- vector(mode = "list", length = 101)
for(i in 1:100) seeds[[i]] <- sample.int(1000, 1)
seeds[[101]] <- sample.int(1000,1)

ctrl <- trainControl(method="repeatedcv",number=10,repeats=10,savePredictions=TRUE,classProbs=TRUE,search = "random",summaryFunction = twoClassSummary,verboseIter=TRUE,seeds=seeds)

# train the model for each parameter combination in the grid, using CV to evaluate
param_grid <-expand.grid(
        n.trees= c(200),
        interaction.depth = c(3),
        shrinkage=c(0.3),
        n.minobsinnode = c(15)
)


set.seed(123)
model<-train(
  x=data_train,
  y=train$Type,
  method="gbm",
  trControl=ctrl,
  preProcess = c("corr", "nzv"),
  tuneGrid=param_grid,
metric="ROC"
)
print(model)


name="GBM.models.rds"
saveRDS(model, name)

name="GBM.pred.txt"
Type=ifelse(model$pred$obs=="Control",0,1)
p=data.frame(rowIndex=model$pred$rowIndex,pred=model$pred$Cancer,Type=Type,fold=as.numeric(as.factor(model$pred$Resample)))
write.table(p,file=name,row.names = FALSE,quote=FALSE,sep="\t",col.names = TRUE)

pred.tbl=model$pred %>% group_by(rowIndex) %>% dplyr::summarize(Type=obs[1], Pred=mean(Cancer))
name="EXCEL.score.txt"
Type=ifelse(train$Type=="Control",0,1)
p=data.frame(Sid=rownames(train),Type=Type,pred=pred.tbl$Pred)
write.table(p,file=name,row.names = FALSE,quote=FALSE,sep="\t",col.names = TRUE)

modelroc=roc(Type,pred.tbl$Pred,levels=c(0,1),direction='<')
modelroc

