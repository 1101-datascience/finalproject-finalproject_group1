#################
#Group : G1
#ID : 110753113
#Author : Zhang-HaoBo
#################
library(MASS)
library(pROC)

args <- commandArgs(trailingOnly = TRUE)

#抓fold, train, test, report, predict的index
input_index <- -1
output_index <- -1

for (i in 1:length(args)) {
  if(args[i] == "--input")
    input_index <- i
  if(args[i] == "--ouput")
    output_index <- i
}

#確定有fold, train, test, report, predict
if( (input_index == -1) || (output_index == -1) )
  stop("Missing --input or  --ouput", call.=FALSE)


#給變數及檔案路徑
input_path <- args[input_index+1]
output_path <- args[output_index+1]

print(input_path)
#確定有無train file
if(!file.exists(input_path)) {
  stop("No such train file", call.=FALSE)
}

#df <- read.csv(input_path, header=T)
df <- read.csv('../dataset/ourdata.csv', header=T)

df <- df[,2:8]

# Cannot convert chr to dbl  
x <- df[,5]
x <- gsub(",", "", x) 
x <- as.numeric(x)  
df[,5] <- x

print(str(df))

# min-max scale
df[,1] <- df[,1]-min(df[,1])/(max(df[,1])-min(df[,1]))
df[,2] <- df[,2]-min(df[,2])/(max(df[,2])-min(df[,2]))
df[,3] <- df[,3]-min(df[,3])/(max(df[,3])-min(df[,3]))
df[,5] <- df[,5]-min(df[,5])/(max(df[,5])-min(df[,5]))

# 標準化
df[,4] <- (df[,4] - mean(df[,4])) / sd(df[,4])
df[,6] <- (df[,6] - mean(df[,6])) / sd(df[,6])


#後100
testing_set <- df[(nrow(df)-99):nrow(df),]


df <- df[1:1553,] #1553


set.seed(666)
df$V1 <- runif(dim(df)[1])
k <- 5

fold_list <- c()
# Accuracy
train_accurcy_list <- c()
validation_accurcy_list  <- c()
testing_accurcy_list  <- c()

train_null_accurcy_list <- c()
validation_null_accurcy_list  <- c()
test_null_accurcy_list  <- c()

# Recall 
train_recall_list <- c()
validation_recall_list  <- c()
testing_recall_list  <- c()

train_null_recall_list <- c()
validation_null_recall_list  <- c()
test_null_recall_list  <- c()

# Precicison
train_precision_list <- c()
validation_precision_list  <- c()
testing_precision_list  <- c()

train_null_precision_list <- c()
validation_null_precision_list  <- c()
test_null_precision_list  <- c()


for(i in 1:k){
  print(i)
  if(i == 1) {
    
    Validation_set <- subset(df, df$V1 <= (i/k))
    
    testing_set <- subset(df, df$V1 > (i/k))
    testing_set <- subset(testing_set, testing_set$V1 <= (i+1)/k)
    
    train_set <- subset(df, df$V1 > (i+1)/k)
  }
  if(i == k) {
    Validation_set <- subset(df, df$V1 > (i-1)/k)
    Validation_set <- subset(Validation_set, Validation_set$V1 <= (i/k))
    
    testing_set <- subset(df, df$V1 <= (1/k))
    
    train_set <- subset(df, df$V1 > (1/k))
    train_set <- subset(train_set, train_set$V1 <= (i-1)/k)
  }
  else {
    
    Validation_set <- subset(df, df$V1 > (i-1)/k)
    Validation_set <- subset(Validation_set, Validation_set$V1 <= (i/k))
    
    testing_set <- subset(df, df$V1 > (i/k))
    testing_set <- subset(testing_set, testing_set$V1 <= (i+1)/k)
    
    if(i == k-1)
      train_set <- subset(df, df$V1 < (k-2)/k)
    else 
      train_set_part1 <- subset(df, df$V1 > (i+1)/k)
      train_set_part2 <- subset(df, df$V1 <= (i-1)/k)
      train_set <- rbind(train_set_part1,train_set_part2)
  }
  
  
  ##################### Train
  # NaiveBayes No date
  train_x <-  train_set[,1:6]
  train_y <-  train_set[,7]
  qda_model <- qda(train_x, train_y)
  model_Pred <- predict(qda_model, train_x)
  res <- model_Pred$class
  res <- as.numeric(as.character(res))
  train_Matrix <- table(res, train_y)
  
  #Plot ROC curve and AUC Value 
  plot(roc(train_set[,7],res), print.auc=TRUE)
  
  # Train_nullmodel
  #train_nullmodel <- factor(rep_len(0, dim(train_set)[1]),levels=c(0,1))
  train_nullmodel <- rbinom(dim(train_set)[1], 1, 0.5)
  train_label <- train_set$TAIEX
  train_null_Matrix <- table(train_label,train_nullmodel)
  #print(null_Matrix)
  
  # Train_accuracy
  single_train_accuracy = ((train_Matrix[1,1]+train_Matrix[2,2])/dim(train_set)[1])
  train_accurcy_list <- c(train_accurcy_list, round(single_train_accuracy, 2))
  # Train_Null_accuracy
  single_null_train_accuracy = ((train_null_Matrix[1,1]+train_null_Matrix[2,2])/dim(train_set)[1])
  train_null_accurcy_list <- c(train_null_accurcy_list, round(single_null_train_accuracy, 2))
  
  # Train_recall
  single_train_recall <- (train_Matrix[2,2]/(train_Matrix[2,1]+train_Matrix[2,2]))
  train_recall_list <- c(train_recall_list, round(single_train_recall, 2))
  # Train_null_recall
  single_null_train_recall = (train_null_Matrix[2,2]/(train_null_Matrix[2,1]+train_null_Matrix[2,2]))
  train_null_recall_list <- c(train_null_recall_list, round(single_null_train_recall, 2))
  
  # Train_precision
  single_train_precision <- (train_Matrix[2,2]/(train_Matrix[1,2]+train_Matrix[2,2]))
  train_precision_list <- c(train_precision_list, round(single_train_precision, 2))
  # Train_null_precision
  single_null_train_precision = (train_null_Matrix[2,2]/(train_null_Matrix[1,2]+train_null_Matrix[2,2]))
  train_null_precision_list <- c(train_null_precision_list, round(single_null_train_precision, 2))
  
  
  
  
  ##################### validation
  Validation_x <-  Validation_set[,1:6]
  Validation_y <-  Validation_set[,7]
  qda_model <- qda(Validation_x, Validation_y)
  model_Pred <- predict(qda_model, Validation_x)
  res <- model_Pred$class
  res <- as.numeric(as.character(res))
  validation_Matrix <- table(res, Validation_y)
  # validation_nullmodel
  #validation_nullmodel <- factor(rep_len(0, dim(Validation_set)[1]),levels=c(0,1))
  validation_nullmodel <- rbinom(dim(Validation_set)[1], 1, 0.5)
  validation_label <- Validation_set$TAIEX
  validtion_null_Matrix <- table(validation_label,validation_nullmodel)
  
  # Validation_accuracy
  single_validation_accuracy <- ((validation_Matrix[1,1]+validation_Matrix[2,2])/dim(Validation_set)[1])
  validation_accurcy_list <- c(validation_accurcy_list, round(single_validation_accuracy, 2))
  # Validation_Null_accuracy
  single_null_validation_accuracy = ((validtion_null_Matrix[1,1]+validtion_null_Matrix[2,2])/dim(Validation_set)[1])
  validation_null_accurcy_list <- c(validation_null_accurcy_list, round(single_null_validation_accuracy, 2))
  
  # Validation_recall
  single_validation_recall <- (validation_Matrix[2,2]/(validation_Matrix[2,1]+validation_Matrix[2,2]))
  validation_recall_list  <- c(validation_recall_list, round(single_validation_recall, 2))
  # Validation_Null_recall
  single_null_validation_recall <- (validtion_null_Matrix[2,2]/(validtion_null_Matrix[2,1]+validtion_null_Matrix[2,2]))
  validation_null_recall_list <- c(validation_null_recall_list, round(single_null_validation_recall, 2))
  
  # Validation_precision
  single_validation_precision <- (validation_Matrix[2,2]/(validation_Matrix[1,2]+validation_Matrix[2,2]))
  validation_precision_list  <- c(validation_precision_list, round(single_validation_precision, 2))
  # Validation_Null_precision
  single_null_validation_precision <- (validtion_null_Matrix[2,2]/(validtion_null_Matrix[1,2]+validtion_null_Matrix[2,2]))
  validation_null_precision_list <- c(validation_null_precision_list, round(single_null_validation_precision, 2))
  
  
  ##################### Test
  testing_x <-  testing_set[,1:6]
  testing_y <-  testing_set[,7]
  qda_model <- qda(testing_x, testing_y)
  model_Pred <- predict(qda_model, testing_x)
  res <- model_Pred$class
  res <- as.numeric(as.character(res))
  test_Matrix <- table(res, testing_y)
  
  # test_nullmodel
  test_nullmodel <- rbinom(dim(testing_set)[1], 1, 0.5)
  test_label <- testing_set$TAIEX
  test_null_Matrix <- table(test_label,test_nullmodel)
  
  
  # Test_accuracy
  single_test_accuracy = ((test_Matrix[1,1]+test_Matrix[2,2])/dim(testing_set)[1])
  testing_accurcy_list <- c(testing_accurcy_list, round(single_test_accuracy, 2))
  

  # Test_Null_accuracy
  single_null_test_accuracy = ((test_null_Matrix[1,1]+test_null_Matrix[2,2])/dim(testing_set)[1])
  test_null_accurcy_list <- c(test_null_accurcy_list, round(single_null_test_accuracy, 2))
  
  # Test_recall
  single_testing_recall <- (test_Matrix[2,2]/(test_Matrix[2,1]+test_Matrix[2,2]))
  testing_recall_list  <- c(testing_recall_list, round(single_testing_recall, 2))
  # Test_Null_recall
  single_null_test_recall <- (test_null_Matrix[2,2]/(test_null_Matrix[2,1]+test_null_Matrix[2,2]))
  test_null_recall_list <- c(test_null_recall_list, round(single_null_test_recall, 2))
  
  # Test_precision
  single_testing_precision <- (test_Matrix[2,2]/(test_Matrix[1,2]+test_Matrix[2,2]))
  testing_precision_list  <- c(testing_precision_list, round(single_testing_precision, 2))
  # Validation_Null_precision
  single_null_test_precision <- (test_null_Matrix[2,2]/(test_null_Matrix[1,2]+test_null_Matrix[2,2]))
  test_null_precision_list <- c(test_null_precision_list, round(single_null_test_precision, 2))
  
  
  fold_list <- c(fold_list, paste("fold",i))
}


#Naive Bayes Model
output_train_accuracy_list <- c(train_accurcy_list, round(mean(train_accurcy_list),2 ), " ")
output_validation_accurcy_list <- c(validation_accurcy_list, round(mean(validation_accurcy_list), 2), " ")
output_testing_accurcy_list <- c(testing_accurcy_list, round(mean(testing_accurcy_list), 2), " ")
output_fold_list <- c(fold_list,'ave.', " ")

output_train_recall_list <- c(train_recall_list, round(mean(train_recall_list),2 ), " ")
output_validation_recall_list <- c(validation_recall_list, round(mean(validation_recall_list),2 ), " ")
output_testing_recall_list <- c(testing_recall_list, round(mean(testing_recall_list),2 ), " ")

output_train_precision_list <- c(train_precision_list, round(mean(train_precision_list),2 ), " ")
output_validation_precision_list <- c(validation_precision_list, round(mean(validation_precision_list),2 ), " ")
output_testing_precision_list <- c(testing_precision_list, round(mean(testing_precision_list),2 ), " ")

output <- data.frame(Accuracy= output_fold_list, training_accuracy= output_train_accuracy_list, validation_accuracy= output_validation_accurcy_list	, test_accuracy= output_testing_accurcy_list,Precision = output_fold_list, train_precision = output_train_precision_list, validation_precision = output_validation_precision_list, test_precision = output_testing_precision_list, Recall = output_fold_list, train_recall = output_train_recall_list, validation_recall = output_validation_recall_list, test_recall = output_testing_recall_list)
#print(output)

#Null Model
output_null_train_accuracy_list <- c(train_null_accurcy_list, round(mean(train_null_accurcy_list),2 ), " ")
output_null_validation_accurcy_list <- c(validation_null_accurcy_list, round(mean(validation_null_accurcy_list), 2), " ")
output_null_testing_accurcy_list <- c(test_null_accurcy_list, round(mean(test_null_accurcy_list), 2), " ")

output_null_train_recall_list <- c(train_null_recall_list, round(mean(train_null_recall_list),2 ), " ")
output_null_validation_recall_list <- c(validation_null_recall_list, round(mean(validation_null_recall_list),2 ), " ")
output_null_test_recall_list <- c(test_null_recall_list, round(mean(test_null_recall_list),2 ), " ")

output_null_train_precision_list <- c(train_null_precision_list, round(mean(train_null_precision_list),2 ), " ")
output_null_validation_precision_list <- c(validation_null_precision_list, round(mean(validation_null_precision_list),2 ), " ")
output_null_test_precision_list <- c(test_null_precision_list, round(mean(test_null_precision_list),2 ), " ")

null_output <- data.frame(Accuracy= output_fold_list, training_accuracy= output_null_train_accuracy_list, validation_accuracy= output_null_validation_accurcy_list, test_accuracy= output_null_testing_accurcy_list,
                          Precision = output_fold_list, train_precision = output_null_train_precision_list, validation_precision = output_null_validation_precision_list, test_precision = output_null_test_precision_list, 
                          Recall = output_fold_list, train_recall = output_null_train_recall_list, validation_recall = output_null_validation_recall_list, test_recall = output_null_test_recall_list)

final_QDA <- rbind(output,null_output)



split_predict_output_path <- strsplit(output_path,split='/', fixed=TRUE)
predice_output_With_no_filename <- sapply(split_predict_output_path, head, -1)
output_performance_filename <- sapply(split_predict_output_path, tail, 1)

#輸出路徑是否存在，不存在則開資料夾
if(is.character(predice_output_With_no_filename)) {
  for(i in 1:length(predice_output_With_no_filename)) {
    if(dir.exists(predice_output_With_no_filename[i])) {
      setwd(file.path(getwd(),predice_output_With_no_filename[i]))
    }
    else {
      dir.create(predice_output_With_no_filename[i])
      setwd(file.path(getwd(),predice_output_With_no_filename[i]))
    }
  }
}

#write.csv(final_QDA, file = output_path, row.names = F, quote = F)

write.csv(final_QDA, file = 'G1_QDA.csv', row.names = F, quote = F)
