#################
#Group : G1
#ID : 110753113
#Author : Zhang-HaoBo
#################

#library(pROC)

args <- commandArgs(trailingOnly = TRUE)

#抓fold, train, test, report, predict的index
input_index <- -1
output_index <- -1

for (i in 1:length(args)) {
  if(args[i] == "--input")
    input_index <- i
  if(args[i] == "--output")
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

df <- read.csv(input_path, header=T)
#df <- read.csv('ourdata.csv', header=T)


#後100
testing_set <- df[(nrow(df)-99):nrow(df),]


df <- df[1:1553,] #1553


set.seed(2022)
df$V1 <- runif(dim(df)[1])
k <- 5

fold_list <- c()
# Accuracy
train_null_accurcy_list <- c()
validation_null_accurcy_list  <- c()
test_null_accurcy_list  <- c()

# Recall 
train_null_recall_list <- c()
validation_null_recall_list  <- c()
test_null_recall_list  <- c()

# Precicison
train_null_precision_list <- c()
validation_null_precision_list  <- c()
test_null_precision_list  <- c()



for(i in 1:k){
  if(i == 1) {
    # 用機率切資料
    Validation_set <- subset(df, df$V1 <= (i/k))
    train_set <- subset(df, df$V1 > (i/k) )
  }
  if(i == k) {
    Validation_set <- subset(df, df$V1 > (i-1)/k)
    train_set <- subset(df, df$V1 <= (i-1)/k)
  }
  else {
    
    Validation_set <- subset(df, df$V1 > (i-1)/k)
    Validation_set <- subset(Validation_set, Validation_set$V1 <= (i/k))
    
    train_set_part1 <- subset(df, df$V1 <= (i-1)/k)
    train_set_part2 <- subset(df, df$V1 > (i/k))
    train_set <- rbind(train_set_part1,train_set_part2)
  }
  
  ##################### Train
  # Train_nullmodel
  train_nullmodel <- rbinom(dim(train_set)[1], 1, 0.5)
  train_label <- train_set$TAIEX
  train_null_Matrix <- table(train_label,train_nullmodel)
  #print(null_Matrix)
  
  # Train_Null_accuracy
  single_null_train_accuracy = ((train_null_Matrix[1,1]+train_null_Matrix[2,2])/dim(train_set)[1])
  train_null_accurcy_list <- c(train_null_accurcy_list, round(single_null_train_accuracy, 2))

  # Train_null_recall
  single_null_train_recall = (train_null_Matrix[2,2]/(train_null_Matrix[2,1]+train_null_Matrix[2,2]))
  train_null_recall_list <- c(train_null_recall_list, round(single_null_train_recall, 2))
  
  # Train_null_precision
  single_null_train_precision = (train_null_Matrix[2,2]/(train_null_Matrix[1,2]+train_null_Matrix[2,2]))
  train_null_precision_list <- c(train_null_precision_list, round(single_null_train_precision, 2))
  
  
  ##################### validation
  # validation_nullmodel
  validation_nullmodel <- rbinom(dim(Validation_set)[1], 1, 0.5)
  validation_label <- Validation_set$TAIEX
  validtion_null_Matrix <- table(validation_label,validation_nullmodel)
  
  # Validation_Null_accuracy
  single_null_validation_accuracy = ((validtion_null_Matrix[1,1]+validtion_null_Matrix[2,2])/dim(Validation_set)[1])
  validation_null_accurcy_list <- c(validation_null_accurcy_list, round(single_null_validation_accuracy, 2))
  
  # Validation_Null_recall
  single_null_validation_recall <- (validtion_null_Matrix[2,2]/(validtion_null_Matrix[2,1]+validtion_null_Matrix[2,2]))
  validation_null_recall_list <- c(validation_null_recall_list, round(single_null_validation_recall, 2))
  
  # Validation_Null_precision
  single_null_validation_precision <- (validtion_null_Matrix[2,2]/(validtion_null_Matrix[1,2]+validtion_null_Matrix[2,2]))
  validation_null_precision_list <- c(validation_null_precision_list, round(single_null_validation_precision, 2))
  
  
  ##################### Test
  # test_nullmodel
  test_nullmodel <- rbinom(dim(testing_set)[1], 1, 0.5)
  test_label <- testing_set$TAIEX
  test_null_Matrix <- table(test_label,test_nullmodel)
  
  # Test_Null_accuracy
  single_null_test_accuracy = ((test_null_Matrix[1,1]+test_null_Matrix[2,2])/dim(testing_set)[1])
  test_null_accurcy_list <- c(test_null_accurcy_list, round(single_null_test_accuracy, 2))
  
  # Test_Null_recall
  single_null_test_recall <- (test_null_Matrix[2,2]/(test_null_Matrix[2,1]+test_null_Matrix[2,2]))
  test_null_recall_list <- c(test_null_recall_list, round(single_null_test_recall, 2))
  
  # Test_Null_precision
  single_null_test_precision <- (test_null_Matrix[2,2]/(test_null_Matrix[1,2]+test_null_Matrix[2,2]))
  test_null_precision_list <- c(test_null_precision_list, round(single_null_test_precision, 2))
  
  fold_list <- c(fold_list, paste("fold",i))
}

output_fold_list <- c(fold_list,'ave.')

#Null Model
output_null_train_accuracy_list <- c(train_null_accurcy_list, round(mean(train_null_accurcy_list),2 ))
output_null_validation_accurcy_list <- c(validation_null_accurcy_list, round(mean(validation_null_accurcy_list), 2))
output_null_testing_accurcy_list <- c(test_null_accurcy_list, round(mean(test_null_accurcy_list), 2))

output_null_train_recall_list <- c(train_null_recall_list, round(mean(train_null_recall_list),2 ))
output_null_validation_recall_list <- c(validation_null_recall_list, round(mean(validation_null_recall_list),2 ))
output_null_test_recall_list <- c(test_null_recall_list, round(mean(test_null_recall_list),2 ))

output_null_train_precision_list <- c(train_null_precision_list, round(mean(train_null_precision_list),2 ))
output_null_validation_precision_list <- c(validation_null_precision_list, round(mean(validation_null_precision_list),2 ))
output_null_test_precision_list <- c(test_null_precision_list, round(mean(test_null_precision_list),2 ))


null_output <- data.frame(Accuracy= output_fold_list, 
                          training_accuracy= output_null_train_accuracy_list, 
                          validation_accuracy= output_null_validation_accurcy_list, 
                          test_accuracy= output_null_testing_accurcy_list,
                          Precision = output_fold_list, 
                          train_precision = output_null_train_precision_list, 
                          validation_precision = output_null_validation_precision_list, 
                          test_precision = output_null_test_precision_list, 
                          Recall = output_fold_list, 
                          train_recall = output_null_train_recall_list, 
                          validation_recall = output_null_validation_recall_list, 
                          test_recall = output_null_test_recall_list)

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

write.csv(null_output, file = output_path, row.names = F, quote = F)