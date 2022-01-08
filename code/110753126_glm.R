########################
# Final 110753126
########################

#install.packages('devtools')

#library(devtools)
#install.packages('AUC')
#install.packages("caret", dependencies=TRUE, type="win.binary")
library(caret)
library(e1071)
library(data.table)
library(tidyr)
library(pROC)
#library(AUC)
### read parameters
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("USAGE: Rscript code\110753126_glm.R --fold 5 --report performance.csv", call.=FALSE)
}


i<-1 
while(i < length(args))
{
  if(args[i] == "--fold"){
    fnum<-args[i+1]
    i<-i+1
  }else if(args[i] == "--train"){
    train_f<-args[i+1]
    i<-i+1
  }else if(args[i] == "--test"){
    test_f<-args[i+1]
    i<-i+1
  }else if(args[i] == "--report"){
    rep_f<-args[i+1]
    i<-i+1
  }else if(args[i] == "--predict"){
    pred_f<-args[i+1]
    i<-i+1
  }else{
    stop(paste("Unknown flag", args[i]), call.=FALSE)
  }
  i<-i+1
}

fold_num <- as.integer(fnum)

# read input data
train_d <- read.csv("data/ourdata.csv", header = T)
train_d<-data.frame(train_d)

names(train_d) <- c("Date","SOX_Close","Dow.Jones_Close","NASDAQ_Close","Bitcoin_Change","S_P_500_Close","total_net_tsmc","TAIEX")


# factor label
train_d$TAIEX <-  factor(train_d$TAIEX, levels = c(0,1))
train_d <- train_d[-1]
train_d[-7] <- data.matrix(train_d[-7])

# feature scale
train_d[-7] <- scale(train_d[-7])


# split data to training, testing, validation  data
train_p <- (fold_num - 2) / fold_num
test_p <- 1 / fold_num
validate_p <- 1 / fold_num

set.seed(735)
n <- nrow(train_d)

splitn <- sample(fold_num,size = n,replace=TRUE)
fds<-c()

train_auc<-c()
valid_auc<-c()
test_auc<-c()
train_ac<-c()
valid_ac<-c()
test_ac<-c()
train_precision<-c()
valid_precision<-c()
test_precision<-c()
train_recall<-c()
valid_recall<-c()
test_recall<-c()

n.train_auc<-c()
n.valid_auc<-c()
n.test_auc<-c()
n.train_ac<-c()
n.valid_ac<-c()
n.test_ac<-c()
n.train_precision<-c()
n.valid_precision<-c()
n.test_precision<-c()
n.train_recall<-c()
n.valid_recall<-c()
n.test_recall<-c()

for(i in 1:fold_num){
  v_num = (i%%fold_num) + 1
  test_data<-train_d[splitn==i,]
  valid_data<-train_d[splitn==v_num,]
  delrows<-c(row.names(valid_data),row.names(test_data),sort=TRUE)
  numdelrows<-as.numeric(delrows[1:(length(delrows)-1)])
  train_data<-train_d[-numdelrows,]
  
  model_reg <- glm(formula = TAIEX ~ ., data=train_data, family=binomial(link="logit"))
 
  
  #Prediction of train data
  train.predict <- predict(model_reg, type = 'response', newdata = train_data)
  train.data.result <- factor(train_d[-numdelrows,7])

  #print(paste("train============000"),i)
  train.predict.new  <-  ifelse(train.predict > 0.5, 1,0)
  train.predict.new <- as.factor(train.predict.new)
  
  train_cm<-confusionMatrix(train.predict.new, train.data.result)
  train_ac[i]<-train_cm$overall[1]
  train_precision[i]<- train_cm$byClass[5]
  train_recall[i]<- train_cm$byClass[6]

  train.predict.new <- as.numeric(ifelse(train.predict.new == 0, 0, 1))
  train_auc[i] <- auc(train.data.result, train.predict.new)

  train_null <- factor(rep_len(0, length(train.predict)),levels=c(0,1))
  
 
  
  n.train_cm<-confusionMatrix(train_null, train.data.result)
  n.train_ac[i]<-n.train_cm$overall[1]
  n.train_precision[i]<- n.train_cm$byClass[5]
  n.train_recall[i]<- n.train_cm$byClass[6]

  n.train_null <- as.numeric(ifelse(train_null == 1, 1, 0))
  n.train_auc[i] <- auc(train.data.result, n.train_null)
  
  #Prediction of validation data
  valid.predict <- predict(model_reg, type = 'response', newdata = valid_data)
  valid.data.result <- factor(train_d[splitn==v_num,7])
  valid_null <- as.data.frame(rep_len(1, length(valid.predict)))
  
  valid.predict.new  <-  ifelse(valid.predict > 0.5, 1,0)
  valid.predict.new <- as.factor(valid.predict.new)
  
  valid_cm<-confusionMatrix(valid.predict.new, valid.data.result)
  valid_ac[i]<-valid_cm$overall[1]
  valid_precision[i]<- valid_cm$byClass[5]
  valid_recall[i]<- valid_cm$byClass[6]

  
  valid.predict.new <- as.numeric(ifelse(valid.predict.new == 0, 0, 1))
  valid_auc[i] <- auc(valid.data.result, valid.predict.new)
  
  valid_null <- factor(rep_len(0, length(valid.predict)),levels=c(0,1))
  n.valid_cm<-confusionMatrix(valid_null, valid.data.result)
  n.valid_ac[i]<-n.valid_cm$overall[1]
  n.valid_precision[i]<- n.valid_cm$byClass[5]
  n.valid_recall[i]<- n.valid_cm$byClass[6]
  
  n.valid_null <- as.numeric(ifelse(valid_null == 1, 1, 0))
  n.valid_auc[i] <- auc(valid.data.result, n.valid_null)
  
  #Prediction of test data
  test.predict <- predict(model_reg, type = 'response', newdata = test_data)
  test.data.result <- factor(train_d[splitn==i,7])
  test_null <- as.data.frame(rep_len(1, length(test.predict)))
  
  test.predict.new  <-  ifelse(test.predict > 0.5, 1,0)
  test.predict.new <- as.factor(test.predict.new)
  
  test_cm<-confusionMatrix(test.predict.new, test.data.result)
  test_ac[i]<-test_cm$overall[1]
  test_precision[i]<- test_cm$byClass[5]
  test_recall[i]<- test_cm$byClass[6]
  
  test.predict.new <- as.numeric(ifelse(test.predict.new == 0, 0, 1))
  test_auc[i] <- auc(test.data.result, test.predict.new)
  
  test_null <- factor(rep_len(0, length(test.predict)),levels=c(0,1))
  n.test_cm<-confusionMatrix(test_null, test.data.result)
  n.test_ac[i]<-n.test_cm$overall[1]
  n.test_precision[i]<- n.test_cm$byClass[5]
  n.test_recall[i]<- n.test_cm$byClass[6]
  
  n.test_null <- as.numeric(ifelse(test_null == 1, 1, 0))
  n.test_auc[i] <- auc(test.data.result, n.test_null)
  
  fds[i]<-paste('fold',i,sep='')
}
png(filename="results/train_predict.png")
plot(roc(train.data.result,train.predict.new), main = "train.predict")

png(filename="results/valid_predict.png")
plot(roc(valid.data.result, valid.predict.new), main = "valid.predict")
png(filename="results/test_predict.png")
plot(roc(test.data.result, test.predict.new), main = "test.predict")
dev.off()
df<-data.frame(GlmModel=c(fds,"ave"),train_auc=round(c(train_auc,mean(train_auc)),2),valid_auc=round(c(valid_auc,mean(valid_auc)),2),test_auc=round(c(test_auc,mean(test_auc)),2)
               ,train_ac=round(c(train_ac,mean(train_ac)),2),valid_auc=round(c(valid_ac,mean(valid_ac)),2),test_ac=round(c(test_ac,mean(test_ac)),2)
               ,train_precision=round(c(train_precision,mean(train_precision)),2),valid_precision=round(c(valid_precision,mean(valid_precision)),2),test_precision=round(c(test_precision,mean(test_precision)),2)
               ,train_recall=round(c(train_recall,mean(train_recall)),2),valid_recall=round(c(valid_recall,mean(valid_recall)),2),test_recall=round(c(test_recall,mean(test_recall)),2))


df_null<-data.frame(NullModel=c(fds,"ave"),train_auc=round(c(n.train_auc,mean(n.train_auc)),2),valid_auc=round(c(n.valid_auc,mean(n.valid_auc)),2),test_auc=round(c(n.test_auc,mean(n.test_auc)),2)
               ,train_ac=round(c(n.train_ac,mean(n.train_ac)),2),valid_auc=round(c(n.valid_ac,mean(n.valid_ac)),2),test_ac=round(c(n.test_ac,mean(n.test_ac)),2)
               ,train_precision=round(c(n.train_precision,mean(n.train_precision)),2),valid_precision=round(c(n.valid_precision,mean(n.valid_precision)),2),test_precision=round(c(n.test_precision,mean(n.test_precision)),2)
               ,train_recall=round(c(n.train_recall,mean(n.train_recall)),2),valid_recall=round(c(n.valid_recall,mean(n.valid_recall)),2),test_recall=round(c(n.test_recall,mean(n.test_recall)),2))
rownames(df)<-NULL
rownames(df_null)<-NULL

temp<-rep_f
dire<-gsub(basename(temp), "", temp)
if(nchar(dire)>0){
  if(!dir.exists(dire)){
    dir.create(dire, showWarnings = TRUE, recursive = TRUE)
  }
}

#temp2<-pred_f
#dire<-gsub(basename(temp2), "", temp2)
#if(nchar(dire)>0){
#  if(!dir.exists(dire)){
#    dir.create(dire, showWarnings = TRUE, recursive = TRUE)
#  }
#}

write.table(df, rep_f, sep = ",",
            append = TRUE, quote = FALSE,
            col.names = TRUE, row.names = FALSE)
write.table(df_null, rep_f, sep = ",",
            append = TRUE, quote = FALSE,
            col.names = TRUE, row.names = FALSE)



#print(predict_newTest)
#write.csv(predict_newTest,pred_f,quote=FALSE,row.names=FALSE)
