#################
#Group : G1
#ID : 110753113
#Author : Zhang-HaoBo
#################

args <- commandArgs(trailingOnly = TRUE)

input_index <- -1

for (i in 1:length(args)) {
  if(args[i] == "--input")
    input_index <- i
}


if( (input_index == -1))
  stop("Missing --input", call.=FALSE)


input_path <- args[input_index+1]


if(!file.exists(input_path)) {
  stop("No such train file", call.=FALSE)
}

df <- read.csv(input_path, header=T)
#df <- read.csv('ourdata.csv', header=T)

library(pROC)
library(keras)
library(tensorflow)
library(ggplot2)
library(tidyr)
library(keras) 
library(caret)
library(pROC)

# read in ourdata and drop date
df <- read.csv("ourdata.csv", header=T, stringsAsFactors = FALSE)
df <- df[,2:8]

# Cannot convert chr to dbl  
x <- df[,5]
x <- gsub(",", "", x) 
x <- as.numeric(x)  

df[,5] <- x

# min-max scale
df[,1] <- df[,1]-min(df[,1])/(max(df[,1])-min(df[,1]))
df[,2] <- df[,2]-min(df[,2])/(max(df[,2])-min(df[,2]))
df[,3] <- df[,3]-min(df[,3])/(max(df[,3])-min(df[,3]))
df[,5] <- df[,5]-min(df[,5])/(max(df[,5])-min(df[,5]))

head(df[,4])
# 標準化
df[,4] <- (df[,4] - mean(df[,4])) / sd(df[,4])
df[,6] <- (df[,6] - mean(df[,6])) / sd(df[,6])
#head(df)
head(df[,4])
#print(nrow(df)) 1653
#print(ncol(df)) 7

testing_set <- df[(nrow(df)-99):nrow(df),]

df <- df[1:1553,] #1553

# trian 1553  #test 100
train_set_X <- df[1:1553, 1:6] # 1553 * 6
train_set_Y <- df[1:1553, 7]  # 1553* 1

test_set_X <- testing_set[1:100, 1:6] # 100 * 6
test_set_Y <- testing_set[1:100, 7] # 100 * 1


train_set_X <- data.matrix(train_set_X, rownames.force = NA)
test_set_X <- data.matrix(test_set_X, rownames.force = NA)

table(test_set_Y)


train_set_X <- data.matrix(train_set_X, rownames.force = NA)
test_set_X <- data.matrix(test_set_X, rownames.force = NA)


# Train 

# Sol 2.
x <- rbind(train_set_X[1:1549,], train_set_X[2:1550,], train_set_X[3:1551,], train_set_X[4:1552,])
train_array_x <- array(x,dim=c(1549, 4, 6))

print(dim(train_array_x)) # 1321 4 6


# train_y
trainy <- data.matrix(train_set_Y, rownames.force = NA)
train_array_y <- array(trainy[4:1552],dim=c(1549, 1))
print(dim(train_array_y))

# Test

# Test_x
test_array_X <- array(test_set_X[c(1:97, 2:98, 3:99, 4:100),], c(97,4,6))
print(dim(test_array_X))
# Test_y
testy <- data.matrix(test_set_Y, rownames.force = NA)
test_array_y <- array(testy[4:100],dim=c(97, 1))
print(dim(test_array_y))


model <- keras_model_sequential()

model %>% 
  layer_lstm(units = 8, return_sequences = TRUE, stateful = TRUE,
             batch_input_shape = c(1, 4, 6)) %>% 
  layer_lstm(units = 16, return_sequences = TRUE, stateful = TRUE) %>%
  layer_dropout(rate = 0.3) %>%
  layer_lstm(units = 20, return_sequences = TRUE,stateful = TRUE) %>%
  layer_dropout(rate = 0.3) %>%
  layer_lstm(units = 15, stateful = TRUE) %>% 
  layer_dense(units = 1, activation = 'sigmoid') %>% 
  compile(
    loss = 'binary_crossentropy',
    optimizer = optimizer_adam(learning_rate= 0.01 , decay = 1e-6 ),
    metrics = c('accuracy')
  )

summary(model)
history <- model %>% fit(train_array_x, train_array_y, epochs=50, batch_size=1, shuffle=FALSE, verbose=0, validation_split = 0.1)
plot(history)
print(history)


predict_y <- model %>% predict(test_array_X, batch_size=1)
predict_y <- round(predict_y)
table(predict_y, test_array_y)
#print(predict_y)

plot(roc(test_array_y,predict_y), print.auc=TRUE)

table(test_array_y,predict_y)
