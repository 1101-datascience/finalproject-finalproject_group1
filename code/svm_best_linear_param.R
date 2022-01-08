requrie_packages <- c("e1071")
new_packages <- requrie_packages[!(requrie_packages %in% row.names(installed.packages()))]
if(length(new_packages)>0){
  print("install require packages")
  install.packages(new_packages)
  print("finish install require packages")}

library(e1071)

args = commandArgs(trailingOnly=TRUE)

train_path <- args[2]
report_path<- args[4]

seed<-10
set.seed(seed)

# 
# train_path<-"data/ourdata.csv"
# report_path <-"results/svm_best_param.csv"
k<-5

train_data <- read.csv(train_path)
str(train_data)



svmtune <-  tune(svm,TAIEX..t.~., data=train_data,probability=TRUE,scale = TRUE, kernel="linear",cost=1,
                 range=list(epsilon=10^c(-1,-2,-3),tolerance=10^c(-1,-2,-3)),
                 tunecontrol=tune.control(sampling = "cross",cross = k,performances=TRUE))
write.table(data.frame(svmtune$performances),file=report_path,quote=FALSE,sep=",",row.names=FALSE, na = "NA")
print('best.parameters')
print(svmtune$best.parameters)
