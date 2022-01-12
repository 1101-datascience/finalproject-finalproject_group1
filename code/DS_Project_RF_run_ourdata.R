########################
# DS Final Project
# Model: RandomForest
# Student ID: 109753207
########################

#library('e1071')        #svm
library('lattice')
library('ggplot2')
library('caret')
library('randomForest', warn.conflicts = FALSE)
#library('rpart')
#library('Rcpp')
#library('Amelia')
library('pROC')          #AUC
library('ROCR')

myInputDirFileCheck <- function(InputFile){
  if (!file.exists(InputFile)){
    stop("Warning: no such directory or file", call.=FALSE)
  }
}

myDirectory <- function(myOutputFile){
  myOutputPiece <- strsplit(myOutputFile, "/")
  myOutputFileName_ <- myOutputPiece[[1]][length(myOutputPiece[[1]])]
  
  myOutputDirectory_ <- "."
  for (x in c(1:length(myOutputPiece[[1]])-1)){
    myOutputDirectory_ <- paste0(myOutputDirectory_, paste0(myOutputPiece[[1]][x], "/"))
    if (dir.exists(myOutputDirectory_)){
      
    } else {
      dir.create(myOutputDirectory_, showWarnings = FALSE)
    }
  }
}

# read parameters
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("USAGE: Rscript DS_Project_RF.R --fold 5 --train Data/train.csv --test Data/test.csv --report performance.csv --predict predict.csv", call.=FALSE)
}

# parse parameters
i<-1 
while(i < length(args))
{
  if(args[i] == "--fold"){
    k <- args[i+1]                                      #fold-->k
    i<-i+1
  }else if(args[i] == "--train"){                       #train File
    TrainFile <- args[i+1]                                 
    i<-i+1
  }else if(args[i] == "--test"){                        #test File
    TestFile <- args[i+1]                                 
    i<-i+1
  }else if(args[i] == "--report"){                      #report File
    ReportFile <- args[i+1]
    i<-i+1
  }else if(args[i] == "--predict"){                     #predict File
    PredictFile <- args[i+1]
    i<-i+1
  }else{
    stop(paste("Unknown flag", args[i]), call.=FALSE)
  }
  i<-i+1
}

# Defining performance
loglikelihood <- function(y, py) {
  pysmooth <- ifelse(py==0, 1e-12,
                     ifelse(py==1, 1-1e-12, py))
  sum(y * log(pysmooth) + (1-y)*log(1 - pysmooth))
}

accuracyMeasures <- function(pred, truth, name="model") {
  dev.norm <- -2*loglikelihood(as.numeric(truth), pred)/length(pred)
  ctable <- table(truth=truth,
                  pred=(pred>0.5))
  accuracy <- sum(diag(ctable))/sum(ctable)
  precision <- ctable[2,2]/sum(ctable[,2])
  recall <- ctable[2,2]/sum(ctable[2,])
  f1 <- precision*recall
  data.frame(model=name, accuracy=accuracy, f1=f1, dev.norm)
}

MostFreq <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

k <- as.numeric(k)

########################################
#k <- 5
#TrainFile <- c('dataset/ourdata.csv')
#TestFile <- c('dataset/ourdata.csv')
#ReportFile <- c('performance.csv')
#PredictFile <- c('predict.csv')
########################################


myInputDirFileCheck(TrainFile)
#myInputDirFileCheck(TestFile)
myDirectory(ReportFile)
#myDirectory(PredictFile)

# read training data
myTrain <- read.csv(TrainFile, 
              header = T,
              sep=',',
              na.strings=c('NA',''),
              stringsAsFactors = FALSE)

myTrain <- data.frame(myTrain)
myTrainNo <- dim(myTrain)[1]    #size of training data: 1652

#head(myTrain)
#summary(myTrain)
#str(myTrain)

#myTrain <- myTrain[,2:20]       # get rid of date

#Check NaN
#apply(myTrain, 2, function(x) any(is.na(x)))

set.seed(10)

# normalization
norm <- function(x) {
  (x - mean(x)) / sd(x)
}

myData_norm <- as.data.frame(lapply(myTrain[2:7], norm))
myData_norm <- cbind(myData_norm,myTrain[8])

myTest_norm <- myData_norm[(dim(myData_norm)[1]-99):dim(myData_norm)[1],]
myTrain_norm <- myData_norm[1:(dim(myData_norm)[1]-100),]

Random_List <- sample(1:dim(myTrain_norm)[1], dim(myTrain_norm)[1], replace=FALSE)
myTrain_Random <- myTrain_norm[Random_List,]


d_ <- myTrain_Random
max_class <- MostFreq(d_$TAIEX..t.)
#list <- c(16, 9, 10, 11, 2, 18, 19)
#d_ <- d_[list]

split <- sample(k, nrow(d_), replace=TRUE)

myAccuracy_Training <- c()
myAccuracy_Validating <- c()
myAccuracy_Testing <- c()
myAUC_Training <- c()
myAUC_Validating <- c()
myAUC_Testing <- c()
myPrecision_Training <- c()
myPrecision_Validating <- c()
myPrecision_Testing <- c()
myRecall_Training <- c()
myRecall_Validating <- c()
myRecall_Testing <- c()

null_Accuracy_Training <- c()
null_Accuracy_Validating <- c()
null_Accuracy_Testing <- c()
null_AUC_Training <- c()
null_AUC_Validating <- c()
null_AUC_Testing <- c()
null_Precision_Training <- c()
null_Precision_Validating <- c()
null_Precision_Testing <- c()
null_Recall_Training <- c()
null_Recall_Validating <- c()
null_Recall_Testing <- c()

myFolds <- c()

for(i in 1:k){
  #print(i)
  #i <- 3
  myTestingData <- d_[split==i,]
  myValidatingData <- d_[split==((i%%k)+1),]
  delrows <- c(row.names(myTestingData),row.names(myValidatingData),sort=TRUE)
  numdelrows <- as.numeric(delrows[1:(length(delrows)-1)])
  myTrainingData <- d_[-numdelrows,]

  ##### build random forest model
  rf_model <- randomForest(factor(TAIEX..t.) ~ ., data = myTrainingData,mtry=2, importance=TRUE, ntree=100, nodesize=7)
  
  ##### AUC
    #training data
  pre_training <- predict(rf_model, myTrainingData, 'prob')
  output <- pre_training[,2]
  modelroc_training <- roc(myTrainingData$TAIEX..t.,output)
  myAUC_Training[i] <- modelroc_training$auc[1]
  null_AUC_Training[i] <- performance(prediction(rep(max_class,nrow(myTrainingData)),myTrainingData$TAIEX..t.),"auc")@y.values[[1]]
  
    #validating data
  pre_validating <- predict(rf_model, myValidatingData, 'prob')
  output <- pre_validating[,2]
  modelroc_validating <- roc(myValidatingData$TAIEX..t.,output)
  myAUC_Validating[i] <- modelroc_validating$auc[1]
  null_AUC_Validating[i] <- performance(prediction(rep(max_class,nrow(myValidatingData)),myValidatingData$TAIEX..t.),"auc")@y.values[[1]]
  
    #testing
  pre_testinging <- predict(rf_model, myTestingData, 'prob')
  output <- pre_testinging[,2]
  modelroc_testingting <- roc(myTestingData$TAIEX..t.,output)
  myAUC_Testing[i] <- modelroc_testingting$auc[1]
  null_AUC_Testing[i] <- performance(prediction(rep(max_class,nrow(myTestingData)),myTestingData$TAIEX..t.),"auc")@y.values[[1]]
  
  ##### Accuracy, Precision, Recall
    #training data
  myPrediction_training <- predict(rf_model, myTrainingData)
  myTable <- table(as.factor(myPrediction_training), as.factor(myTrainingData$TAIEX..t.))
  myAccuracy_Training[i] <- sum(diag(myTable))/sum(myTable)
  myRecall_Training[i] <- myTable[2,2]/sum(myTable[,2])
  myPrecision_Training[i] <- myTable[2,2]/sum(myTable[2,])
  
    #null model
  null_myTable <- table(as.factor(factor(rep(max_class,nrow(myTrainingData)),levels=0:1)), as.factor(myTrainingData$TAIEX..t.))
  null_Accuracy_Training[i] <- sum(diag(null_myTable))/sum(null_myTable)
  null_Recall_Training[i] <- null_myTable[2,2]/sum(null_myTable[,2])
  null_Precision_Training[i] <- null_myTable[2,2]/sum(null_myTable[2,])
  
    #validating data
  myPrediction_Validating <- predict(rf_model, myValidatingData)
  myTable <- table(as.factor(myPrediction_Validating), as.factor(myValidatingData$TAIEX..t.))
  myAccuracy_Validating[i] <- sum(diag(myTable))/sum(myTable)
  myRecall_Validating[i] <- myTable[2,2]/sum(myTable[,2])
  myPrecision_Validating[i] <- myTable[2,2]/sum(myTable[2,])
  
   #null model
  null_myTable <- table(as.factor(factor(rep(max_class,nrow(myValidatingData)),levels=0:1)), as.factor(myValidatingData$TAIEX..t.))
  null_Accuracy_Validating[i] <- sum(diag(null_myTable))/sum(null_myTable)
  null_Recall_Validating[i] <- null_myTable[2,2]/sum(null_myTable[,2])
  null_Precision_Validating[i] <- null_myTable[2,2]/sum(null_myTable[2,])
  
    #testing data
  myPrediction_Testing <- predict(rf_model, myTestingData)
  myTable <- table(as.factor(myPrediction_Testing), as.factor(myTestingData$TAIEX..t.))
  myAccuracy_Testing[i] <- sum(diag(myTable))/sum(myTable)
  myRecall_Testing[i] <- myTable[2,2]/sum(myTable[,2])
  myPrecision_Testing[i] <- myTable[2,2]/sum(myTable[2,])
  
    #null model
  null_myTable <- table(as.factor(factor(rep(max_class,nrow(myTestingData)),levels=0:1)), as.factor(myTestingData$TAIEX..t.))
  null_Accuracy_Testing[i] <- sum(diag(null_myTable))/sum(null_myTable)
  null_Recall_Testing[i] <- null_myTable[2,2]/sum(null_myTable[,2])
  null_Precision_Testing[i] <- null_myTable[2,2]/sum(null_myTable[2,])
  
  myFolds[i]<-paste('fold',i,sep='')
}

rf_model <- randomForest(factor(TAIEX..t.) ~ ., data = d_, mtry=2, importance=TRUE, ntree=100, nodesize=7)

#training data
myPrediction_rf <- predict(rf_model, newdata = d_, 'prob')
accuracyMeasures(myPrediction_rf[,2], d_$TAIEX..t., name="random forest, test")

myPrediction_rf2 <- predict(rf_model, myTrainingData)
myTable <- table(as.factor(myPrediction_rf2), as.factor(myTrainingData$TAIEX..t.))
myAccuracy_rf2 <- sum(diag(myTable))/sum(myTable)


#testing data
myPrediction_rf <- predict(rf_model, newdata = myTest_norm, 'prob')
accuracyMeasures(myPrediction_rf[,2], myTest_norm$TAIEX..t., name="random forest, test")

myPrediction_test_rf2 <- predict(rf_model, myTest_norm)
myTable <- table(as.factor(myPrediction_test_rf2), as.factor(myTest_norm$TAIEX..t.))
myAccuracy_test_rf2 <- sum(diag(myTable))/sum(myTable)

#directly use the result of S_P_500_Close..t.1.up
#accuracyMeasures(d_$S_P_500_Close..t.1.up, d_$TAIEX..t., name="random forest, test")


## EXAMINING VARIABLE IMPORTANCE
png(filename="varImp_rf.png")
varImp <- importance(rf_model)
head(varImp)
varImpPlot(rf_model, type=1)
dev.off()

# reduce the number of variables
selVars <- names(sort(varImp[,1], decreasing=T))[1:5]
myData_varImp_ <- d_[,selVars]
myData_varImp_ <- cbind(myData_varImp_,d_[7])

myTest_varImp_ <- myTest_norm[,selVars]
myTest_varImp_ <- cbind(myTest_varImp_,myTest_norm[7])

rf_model_varImp <- randomForest(factor(TAIEX..t.) ~ ., data = myData_varImp_, importance=TRUE, ntree=1000, nodesize=7)
myPrediction_rf <- predict(rf_model_varImp, newdata = myData_varImp_, 'prob')
accuracyMeasures(myPrediction_rf[,2], myData_varImp_$TAIEX..t., name="random forest, test")

#myPrediction_rf_testing <- predict(rf_model_varImp, newdata = myTest_varImp_, 'prob')
myPrediction_rf_testing <- predict(rf_model_varImp, newdata = myTest_varImp_)
myTable <- table(as.factor(myPrediction_rf_testing), as.factor(myTest_varImp_$TAIEX..t.))
myAccuracy_testing <- sum(diag(myTable))/sum(myTable)
myRecall_testing <- myTable[2,2]/sum(myTable[,2])
myPrecision_testing <- myTable[2,2]/sum(myTable[2,])

#####myTest Outcome
df_test_rf <- data.frame(myTest_varImp_$TAIEX..t.)
#df_test_rf$probability <- c(myPrediction_rf_testing[,2])
df_test_rf$prediction <- factor(myPrediction_rf_testing,levels=0:1)
colnames(df_test_rf)[1] <- "byDate"
rownames(df_test_rf)<-NULL

##########
df_rf <- data.frame(AUC=c(myFolds,"ave."),
                    Training=round(c(myAUC_Training,mean(myAUC_Training)),2),
                    Validation=round(c(myAUC_Validating,mean(myAUC_Validating)),2),
                    Testing=round(c(myAUC_Testing,mean(myAUC_Testing)),2),
                    Accuracy=c(myFolds,"ave."),
                    Training=round(c(myAccuracy_Training,mean(myAccuracy_Training)),2),
                    Validation=round(c(myAccuracy_Validating,mean(myAccuracy_Validating)),2),
                    Testing=round(c(myAccuracy_Testing,mean(myAccuracy_Testing)),2),
                    Precision=c(myFolds,"ave."),
                    Training=round(c(myPrecision_Training,mean(myPrecision_Training)),2),
                    Validation=round(c(myPrecision_Validating,mean(myPrecision_Validating)),2),
                    Testing=round(c(myPrecision_Testing,mean(myPrecision_Testing)),2),
                    Recall=c(myFolds,"ave."),
                    Training=round(c(myRecall_Training,mean(myRecall_Training)),2),
                    Validation=round(c(myRecall_Validating,mean(myRecall_Validating)),2),
                    Testing=round(c(myRecall_Testing,mean(myRecall_Testing)),2))

df_null <- data.frame(AUC=c(myFolds,"ave."),
                    null_Training=round(c(null_AUC_Training,mean(null_AUC_Training)),2),
                    null_Validation=round(c(null_AUC_Validating,mean(null_AUC_Validating)),2),
                    null_Testing=round(c(null_AUC_Testing,mean(null_AUC_Testing)),2),
                    Accuracy=c(myFolds,"ave."),
                    null_Training=round(c(null_Accuracy_Training,mean(null_Accuracy_Training)),2),
                    null_Validation=round(c(null_Accuracy_Validating,mean(null_Accuracy_Validating)),2),
                    null_Testing=round(c(null_Accuracy_Testing,mean(null_Accuracy_Testing)),2),
                    Precision=c(myFolds,"ave."),
                    null_Training=round(c(null_Precision_Training,mean(null_Precision_Training)),2),
                    null_Validation=round(c(null_Precision_Validating,mean(null_Precision_Validating)),2),
                    null_Testing=round(c(null_Precision_Testing,mean(null_Precision_Testing)),2),
                    Recall=c(myFolds,"ave."),
                    null_Training=round(c(null_Recall_Training,mean(null_Recall_Training)),2),
                    null_Validation=round(c(null_Recall_Validating,mean(null_Recall_Validating)),2),
                    null_Testing=round(c(null_Recall_Testing,mean(null_Recall_Testing)),2))

rownames(df_rf)<-NULL
rownames(df_null)<-NULL

write.table(df_rf, ReportFile, quote=FALSE,row.names=FALSE, sep=",")
write.table(df_null, ReportFile, quote=FALSE,row.names=FALSE, append=TRUE, sep=",")
write.csv(df_test_rf,PredictFile,quote=FALSE,row.names=FALSE)

