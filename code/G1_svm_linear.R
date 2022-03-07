#package

# requrie_packages <- c("e1071","ROCR")
# new_packages <- requrie_packages[!(requrie_packages %in% row.names(installed.packages()))]
# if(length(new_packages)>0){
#   print("install require packages")
#   install.packages(new_packages)
#   print("finish install require packages")}

library(ROCR)
library(e1071)
library(caret)
#param
args = commandArgs(trailingOnly=TRUE)
# k <- as.numeric(args[2])
train_path <- args[2]
report_path <- args[4]
# predict_path<-args[10]
# 

seed<-10
set.seed(seed)

#
# train_path<-"data/only_diff.csv"
# report_path <-"results/G1_SVM_Metrics_L_diff.csv"
# # report_end_path <-"results/G1_SVM_Mestrics_alltrain_L.csv"
ROC_train_jpg_path<-"image/G1_SVM_ROCR_train_L.jpg"
ROC_test_jpg_path<-"image/G1_SVM_ROCR_test_L.jpg"

k<-5



train_data <- read.csv(train_path)

# train_data$TAIEX..t.<-as.factor(train_data$TAIEX..t.)
test_set <- train_data[(nrow(train_data)-99):nrow(train_data),1:ncol(train_data)]
train_data <-  train_data[1:(nrow(train_data)-100),1:ncol(train_data)]
# train_data<-train_data[,2:ncol(train_data)]
# str(train_data)
max_class<-1
group_index<-sample(rep(1:k,nrow(train_data)/5+1,replace=F)[1:nrow(train_data)])
set <- c()
training_AUC <- c()
validation_AUC <- c()
test_AUC<-c()
# nu_training_AUC <- c()
# nu_validation_AUC <- c()
# nu_test_AUC<-c()

training_ACC <- c()
validation_ACC <- c()
test_ACC<-c()
# nu_training_ACC <- c()
# nu_validation_ACC <- c()
# nu_test_ACC<-c()

training_recall <- c()
validation_recall <- c()
test_recall<-c()
# nu_training_recall <- c()
# nu_validation_recall <- c()
# nu_test_recall<-c()


training_p <- c()
validation_p <- c()
test_p<-c()
# nu_training_p <- c()
# nu_validation_p <- c()
# nu_test_p<-c()




threshold<-0.5


for (i in 1:k){
  print(paste(paste("=======iteration:",as.character(i)),"=======")) #直接取出平軍分配後的rownames
  vali_set<- train_data[which(group_index==i),]
  train_set<-train_data[-(which(group_index==i)),]

  model <- svm(TAIEX..t.~.,
               data=train_set,
               probability=TRUE,
               scale = TRUE,
               kernel='linear',
               cost=1,
               epsilon=0.1,tolerance=0.01
  )
  # #0.55
  
  # model <- svm(TAIEX..t.~.,
  #              data=train_set,
  #              probability=TRUE,
  #              scale = TRUE,
  #              kernel='radial',
  #              cost=1,
  #              sigma = 0.0003013302 ,
  #              # epsilon=0.1,tolerance=0.01
  # )
  
  # AUC
  
  train_auc<-performance(prediction(predict(model, probability=TRUE),train_set$TAIEX..t.),"auc")@y.values[[1]]
  vali_pred<-predict(model, newdata=vali_set, probability=TRUE )
  vali_auc<-performance(prediction(vali_pred,vali_set$TAIEX..t.),"auc")@y.values[[1]]
  
  set<-c(set,paste0("fold",as.character(i)))
  training_AUC<-c(training_AUC,train_auc)
  validation_AUC <- c(validation_AUC,vali_auc)
  # CM
  train_CM <- table(data.frame(truth=train_set$TAIEX..t.,pred=factor(ifelse(predict(model, type="class")>threshold,1,0),levels=0:1)))
  vali_CM <- table(data.frame(truth=vali_set$TAIEX..t.,pred=factor(ifelse(predict(model, newdata=vali_set, type="class")>threshold,1,0),levels=0:1)))
  
  training_ACC<-c(training_ACC,sum(diag(train_CM))/sum(train_CM))
  validation_ACC <- c(validation_ACC,sum(diag(vali_CM))/sum(vali_CM))
  
  training_recall<-c(training_recall,train_CM[2,2]/(train_CM[2,2]+train_CM[2,1]))
  validation_recall<-c(validation_recall,vali_CM[2,2]/(vali_CM[2,2]+vali_CM[2,1]))                 
  
  training_p<-c(training_p,train_CM[2,2]/(train_CM[2,2]+train_CM[1,2]))
  validation_p<-c(validation_p,vali_CM[2,2]/(vali_CM[2,2]+vali_CM[1,2]))   
  
  
  
  
}



round_avg<-function(x){
  return(c(round(x,2),round(sum(x)/length(x),2)))
}

set<-c(set,"ave.")
training_AUC<-round_avg(training_AUC)
validation_AUC<-round_avg(validation_AUC)
validation_AUC
training_AUC



training_ACC <- round_avg(training_ACC)
validation_ACC <- round_avg(validation_ACC)
training_ACC
validation_ACC
training_recall <-round_avg(training_recall)
validation_recall <- round_avg(validation_recall)
training_recall
validation_recall
training_p <- round_avg(training_p)
validation_p <- round_avg(validation_p)
training_p
validation_p



out_data<-data.frame( ACC=set,
                      train_ACC =	training_ACC ,
                      validation_ACC =	validation_ACC ,
                      
                      recall =set,
                      train_recall =	training_recall ,
                      validation_recall =
                        validation_recall ,
                      
                      percion=set,
                      training_p =	training_p ,
                      validation_p =	validation_p ,
                      
                      AUC=set,
                      train_AUC =	training_AUC,
                      validation_AUC =	validation_AUC,
                      
                      stringsAsFactors = F)
# out_data1<-data.frame(ACC=set,
#                       nu_train_ACC =	nu_training_ACC ,
#                       nu_validation_ACC =	nu_validation_ACC ,
#                       
#                       recall =set,
#                       nu_train_recall =	nu_training_recall ,
#                       nu_validation_recall =	nu_validation_recall ,
#                       
#                       percion=set,
#                       nu_training_p =	nu_training_p ,
#                       nu_validation_p =	nu_validation_p ,
#                       
#                       AUC=set,
#                       nu_train_AUC =	nu_training_AUC,
#                       nu_validation_AUC =	nu_validation_AUC,
#                       
#                       stringsAsFactors = F)

write.table(out_data,file=report_path,quote=FALSE,sep=",",row.names=FALSE, na = "NA",append = TRUE)

# write.table(out_data1,file=report_path,quote=FALSE,sep=",",row.names=FALSE, na = "NA",append = TRUE)

# train :AUC ACC P Recall ROC
model <- svm(TAIEX..t.~.,
             data=train_data,
             probability=TRUE,
             scale = TRUE,
             kernel='linear',
             cost=1,
             epsilon=0.1,tolerance=0.01
)


# CM
train_CM <- table(data.frame(truth=train_data$TAIEX..t.,pred=factor(ifelse(predict(model, type="class")>threshold,1,0),levels=0:1)))
test_CM <- table(data.frame(truth=test_set$TAIEX..t.,pred=factor(ifelse(predict(model, newdata=test_set, type="class")>threshold,1,0),levels=0:1)))
# # write.table(as.data.frame.matrix(train_CM),file=report_path,quote=FALSE,sep=",",row.names=FALSE, na = "NA",append = TRUE)
# # write.table(as.data.frame.matrix(train_CM),file=report_path,quote=FALSE,sep=",",row.names=FALSE, na = "NA",append = TRUE)

# write.table(data.frame(as.data.frame.matrix(train_CM),data=cbind("train")),file=report_path,quote=FALSE,sep=",",row.names=FALSE, na = "NA",append = TRUE)
# write.table(data.frame(as.data.frame.matrix(test_CM),data=cbind("test")),file=report_path,quote=FALSE,sep=",",row.names=FALSE, na = "NA",append = TRUE)

train_auc<-performance(prediction(predict(model, probability=TRUE),train_data$TAIEX..t.),"auc")@y.values[[1]]
test_pred<-predict(model, newdata=test_set, probability=TRUE)
test_auc<-performance(prediction(test_pred,test_set$TAIEX..t.),"auc")@y.values[[1]]


training_ACC<-sum(diag(train_CM))/sum(train_CM)
test_ACC<-sum(diag(test_CM))/sum(test_CM)

training_recall<-train_CM[2,2]/(train_CM[2,2]+train_CM[2,1])
test_recall<-test_CM[2,2]/(test_CM[2,2]+test_CM[2,1])

training_p<-train_CM[2,2]/(train_CM[2,2]+train_CM[1.2])
test_p<-test_CM[2,2]/(test_CM[2,2]+test_CM[1,2])


write.table(data.frame(Mectrics=c('ACC','Percision','Recall','AUC'),
                       train=c(training_ACC,training_p,test_recall,train_auc),
                       test=c(test_ACC,test_p,test_recall,test_auc),stringsAsFactors = F)
            ,file=report_path,quote=FALSE,sep=",",row.names=FALSE, na = "NA",append = TRUE)

# # test:AUC ACC P Recall ROC
# jpeg(file=ROC_train_jpg_path)
# plot(performance(prediction(predict(model, probability=TRUE),train_data$TAIEX..t.), "tpr","fpr"),lwd= 3,col='red',main= "SVM ROC Curve on Test Data")
# grid(nx = NULL, ny = NULL,
#      lty = 2,      # Grid line type
#      col = "gray", # Grid line color
#      lwd = 0.2)
# abline(a=0, b=1, lty=2, lwd=3, col="black")
# dev.off()
# 
# # 
# 
# jpeg(file=ROC_test_jpg_path)
# 
# plot(performance(prediction(test_pred,test_set$TAIEX..t.), "tpr","fpr"),lwd= 3,col='red',main= "SVM ROC Curve on Test Data")
# grid(nx = NULL, ny = NULL,
#      lty = 2,      # Grid line type
#      col = "gray", # Grid line color
#      lwd = 0.2)
# abline(a=0, b=1, lty=2, lwd=3, col="black")
# dev.off()


