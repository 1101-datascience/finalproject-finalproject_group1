requrie_packages <- c("e1071")
new_packages <- requrie_packages[!(requrie_packages %in% row.names(installed.packages()))]
if(length(new_packages)>0){
  print("install require packages")
  install.packages(new_packages)
  print("finish install require packages")}

library(e1071)
library(caret)
library(gridExtra)

args = commandArgs(trailingOnly=TRUE)

train_path <- args[2]
report_path<- args[4]

seed<-10
set.seed(seed)

# 
train_path<-"data/ourdata.csv"
report_path <-"results/svm_best_param.csv"
k<-5

train_data <- read.csv(train_path)

train_data$TAIEX..t.<-as.factor(train_data$TAIEX..t.)
train_data <- train_data[1:(nrow(train_data)-98),]

str(train_data)

train_control <- trainControl(method="repeatedcv", number=5, repeats=1)
svm2 <- train(TAIEX..t. ~., data = train_data[,2:ncol(train_data)], method = "svmLinear", trControl = train_control,  preProcess = c("scale"), tuneGrid = expand.grid(C = seq(0, 10, length =21) ))
svm3 <- train(TAIEX..t. ~., data = train_data[,2:ncol(train_data)], method = "svmRadial", trControl = train_control, preProcess = c("scale"), tuneLength = 10)
svm4 <- train(TAIEX..t. ~., data = train_data[,2:ncol(train_data)], method = "svmPoly", trControl = train_control, preProcess = c("scale"), tuneLength = 5)


jpeg(file='image/SVM_linear_tune.jpg')
plot(svm2)
dev.off()

jpeg(file='image/SVM_RDF_tune.jpg')
plot(svm3)
dev.off()

jpeg(file='image/SVM_poly_tune.jpg')
plot(svm4)
dev.off()

svm2$bestTune
svm3$bestTune
svm4$bestTune


res2<-svm2$results[which.min(svm2$results[,2]),]
res3<-svm3$results[which.min(svm3$results[,2]),]
res4<-svm4$results[which.min(svm4$results[,2]),]


svm2$results[which.min(svm2$results[,2]),]
svm3$results[which.min(svm3$results[,2]),]
svm4$results[which.min(svm4$results[,2]),]


df<-data.frame(Model=c('SVM Linear t','SVM Radial','SVM Poly'),Accuracy=c(res2$Accuracy,res3$Accuracy,res4$Accuracy))



write.table(svm2$results,file='results/SVM_linear.csv',quote=FALSE,sep=",",row.names=FALSE, na = "NA")
write.table(svm3$results,file='results/SVM_rbf.csv',quote=FALSE,sep=",",row.names=FALSE, na = "NA")
write.table(svm4$results,file='results/SVM_ploy.csv',quote=FALSE,sep=",",row.names=FALSE, na = "NA")





svmtune <-  tune(svm,TAIEX..t.~., data=train_data,probability=TRUE,scale = TRUE, kernel="linear",cost=1,
                 range=list(epsilon=10^c(-1,-2,-3),tolerance=10^c(-1,-2,-3)),
                 tunecontrol=tune.control(sampling = "cross",cross = k,performances=TRUE))
write.table(data.frame(svmtune$performances),file='results/SVM_tune_kernal_e1071.csv',quote=FALSE,sep=",",row.names=FALSE, na = "NA")
plot(svmtune)
print('best.parameters')
print(svmtune$best.parameters)



