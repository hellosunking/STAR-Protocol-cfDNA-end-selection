library(caret)

args <- commandArgs(trailing=T)
    modelfile<- args[1]
	newdatafile<-args[2]
	output <- args[3]


model <- readRDS(modelfile)
new_data<-read.table(file = newdatafile,header =TRUE,row.names=1)

new_data[,-ncol(new_data)]=scale(new_data[,-ncol(new_data)])
new_data$Type=ifelse(new_data$Type=="Control","Control","Cancer")
data_train=as.matrix(new_data[,-ncol(new_data)])

preProcValues <- preProcess(data_train, method = c("corr", "nzv"))
new_data_processed <- predict(preProcValues, data_train)

predictions_prob <- predict(model, newdata = new_data_processed, type = "prob")

Cancer_Probability <- predictions_prob[, "Cancer"]
Control_Probability <- predictions_prob[, "Control"]

output_df <- data.frame(
					SampleName = rownames(new_data),  # 
					Cancer_Probability = Cancer_Probability,  # Cancer 
					Control_Probability = Control_Probability,  # Control 
					Tag = ifelse(Cancer_Probability > Control_Probability, "Cancer", "Control")  #
					)

print(output_df)
write.table(output_df, file=output, row.names = FALSE,quote=FALSE,sep="\t",col.names = TRUE)
