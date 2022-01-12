########################
# Final 110753126
########################

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

#split train/test data
train_d <- train_d[1:(nrow(train_d)-100),]
test_d <- train_d[(nrow(train_d)-99):nrow(train_d),]


# factor label
train_d$TAIEX <-  factor(train_d$TAIEX, levels = c(0,1))
train_d <- train_d[-1]
train_d[-7] <- data.matrix(train_d[-7])

test_d$TAIEX <-  factor(test_d$TAIEX, levels = c(0,1))
test_d <- test_d[-1]
test_d[-7] <- data.matrix(test_d[-7])

# feature scale
train_d[-7] <- scale(train_d[-7])
test_d[-7] <- scale(test_d[-7])

# split data to training, testing, validation  data
train_p <- (fold_num - 1) / fold_num
#test_p <- 1 / fold_num
validate_p <- 1 / fold_num

set.seed(2022)
n <- nrow(train_d)

splitn <- sample(fold_num,size = n,replace=TRUE)
fds<-c()

train_auc<-c()
valid_auc<-c()
train_ac<-c()
valid_ac<-c()
train_precision<-c()
valid_precision<-c()
train_recall<-c()
valid_recall<-c()

for(i in 1:fold_num){
  v_num = 1
  #test_data<-train_d[splitn==i,]
  valid_data<-train_d[splitn==i,]
  delrows<-c(row.names(valid_data),sort=TRUE)
  numdelrows<-as.numeric(delrows[1:(length(delrows)-1)])
  train_data<-train_d[-numdelrows,]
  
  model_reg <- glm(formula = TAIEX ~ ., data=train_data, family=binomial(link="logit"))

  #Prediction of train data
  train.predict <- predict(model_reg, type = 'response', newdata = train_data)
  train.data.result <- factor(train_d[-numdelrows,7])

  train.predict.new <- ifelse(train.predict > 0.5, 1,0)
  train.predict.new <- as.factor(train.predict.new)
  
  train_cm<-confusionMatrix(train.predict.new, train.data.result)
  train_ac[i]<-train_cm$overall[1]
  train_precision[i]<- train_cm$byClass[5]
  train_recall[i]<- train_cm$byClass[6]

  train.predict.new <- as.numeric(ifelse(train.predict.new == 0, 0, 1))
  train_auc[i] <- auc(train.data.result, train.predict.new)

  #Prediction of validation data
  valid.predict <- predict(model_reg, type = 'response', newdata = valid_data)
  valid.data.result <- factor(train_d[splitn==i,7])
  
  valid.predict.new  <-  ifelse(valid.predict > 0.5, 1,0)
  valid.predict.new <- as.factor(valid.predict.new)
  
  valid_cm<-confusionMatrix(valid.predict.new, valid.data.result)
  valid_ac[i]<-valid_cm$overall[1]
  valid_precision[i]<- valid_cm$byClass[5]
  valid_recall[i]<- valid_cm$byClass[6]

  
  valid.predict.new <- as.numeric(ifelse(valid.predict.new == 0, 0, 1))
  valid_auc[i] <- auc(valid.data.result, valid.predict.new)
  
  
  fds[i]<-paste('fold',i,sep='')
}


df<-data.frame(GlmModel=c(fds,"ave"),train_auc=round(c(train_auc,mean(train_auc)),2),valid_auc=round(c(valid_auc,mean(valid_auc)),2)
               ,train_ac=round(c(train_ac,mean(train_ac)),2),valid_ac=round(c(valid_ac,mean(valid_ac)),2)
               ,train_precision=round(c(train_precision,mean(train_precision)),2),valid_precision=round(c(valid_precision,mean(valid_precision)),2)
               ,train_recall=round(c(train_recall,mean(train_recall)),2),valid_recall=round(c(valid_recall,mean(valid_recall)),2))

rownames(df)<-NULL


temp<-rep_f
dire<-gsub(basename(temp), "", temp)
if(nchar(dire)>0){
  if(!dir.exists(dire)){
    dir.create(dire, showWarnings = TRUE, recursive = TRUE)
  }
}

write.table(df, rep_f, sep = ",",
            append = TRUE, quote = FALSE,
            col.names = TRUE, row.names = FALSE)

model_reg <- glm(formula = TAIEX ~ ., data=train_d, family=binomial(link="logit"))

#Prediction of train data
train.pred02 <- predict(model_reg, type = 'response', newdata = train_d)
train.data02 <- factor(train_d[,7])

train.pred02 <- ifelse(train.pred02 > 0.5, 1,0)
train.pred02 <- as.factor(train.pred02)

train_cm02<-confusionMatrix(train.pred02, train.data02)
train_ac02<-train_cm02$overall[1]
train_precision02<- train_cm02$byClass[5]
train_recall02<- train_cm02$byClass[6]

train.pred02 <- as.numeric(ifelse(train.pred02 == 0, 0, 1))
train_auc02 <- auc(train.data02, train.pred02)

#Prediction of test data
test.pred02 <- predict(model_reg, type = 'response', newdata = test_d)
test.data02 <- factor(test_d[,7])

test.pred02  <-  ifelse(test.pred02 > 0.5, 1,0)
test.pred02 <- as.factor(test.pred02)

test_cm02<-confusionMatrix(test.pred02, test.data02)
test_ac02<-test_cm02$overall[1]
test_precision02<- test_cm02$byClass[5]
test_recall02<- test_cm02$byClass[6]

test.pred02 <- as.numeric(ifelse(test.pred02 == 0, 0, 1))
test_auc02 <- auc(test.data02, test.pred02)

df_02<-data.frame(GlmModel="result",train_auc02=round(train_auc02,2),test_auc02=round(test_auc02,2)
               ,train_ac02=round(train_ac02,2),test_ac02=round(test_ac02,2)
               ,train_precision02=round(train_precision02,2),test_precision02=round(test_precision02,2)
               ,train_recall02=round(train_recall02,2),test_recall02=round(test_recall02,2))

rownames(df_02)<-NULL

write.table(df_02, rep_f, sep = ",",
            append = TRUE, quote = FALSE,
            col.names = TRUE, row.names = FALSE)

png(filename="image/G1_LogisRegre_AUC_Model.jpg")
plot(roc(test.data02, test.pred02), main = "Logistic Regression Testing Prediction",col="red",plot=TRUE, grid=TRUE,
     print.auc=TRUE)

dev.off()
