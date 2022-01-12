[TOC]

# Group1. 以股為鏡--台股上漲預測

### Menbers

| Name |  Dep. |  StudentID |
| -------- | -------- | -------- |
|趙啟宏|統計三|108304010|
|謝政彥|資科碩二|109753207|
|張皓博|資科碩一|110753113|
|鄭詠儒|資科碩一|110753126|
|林依樺|資科碩一|110753207|


### Our Goal
以美股四大指數和比特幣匯率等變數預測台股上市指數加權的漲或跌。(假設每天的股價沒有關聯)

### Demo
You should provide an example commend to reproduce your result
- 使用G1_DecisionTree.R，採以下指令執行
```R
Rscript code/G1_DecisionTree.R --input data/ourdata.csv --output results/G1_Decision_tree.csv
```
Running this script will output 1 csv file(G1_Decision_tree.csv) and 1 pdf file(Rplots).


#### <span style="color:#ff595e">**on-line visualization**</span>
Shiny

## Folder organization and its related information

### docs
* our presentation: [DS_FinalProject_G1.pptx](https://docs.google.com/presentation/d/1IE9MhMOmIkNQ0jkG6rfE23GG3aa0-ba_AdzETKb8PmM/edit#slide=id.g10acf957bb0_0_40)

* related document for the final project
  *  final paper


### data

* Source
* Any preprocessing?
  * Scale value
  * Creating new features

Describe every features in the final paper.

### code

* Which method do you use?
    * Decision Tree
    * RandomForest
    * Support Vector Machine
    * Naice Bayes
    * Logistic Regression
    * Quadratic Discriminant Analysis
    * CNN & TNN
* What is a null model for comparison?
    * Random Binomial Distribution
* evaluation
    * 5-fold cross validation

### results

* Which metric do you use
  * Precision
  * Accuracy
  * Recall
  * R-square
  * Area under curve
  * ROC Curve
<span style="color:red">**result/G1_Modelname.csv**</span>
<span style="color:red">**image/G1_Modelname(AUC).jpg (AUC)**</span>
* Is your improvement significant?
A little bit, but not for all kinds of models
* What is the challenge part of your project?
1.Data is not enough
2.Don't how to deal with time series
3.Aren't that familiar with financial data
### future
1.Increase the amount of data
2.Learn how to manage time series
3.Watch more financial news in daily life



## Model

### Logistic Regression

#### import
````R=
library(caret)
library(e1071)
library(data.table)
library(tidyr)
library(pROC)
````
#### Data pre-processing
:::info
對data做scale正規化
:::
#### Model 參數
````R=
model_reg <- glm(formula = TAIEX ~ .,
                data=train_data,
                family=binomial(link="logit"))
````
#### Rscript command
- 使用`G1_LogisticRegression.R`，按照以下方式執行:
```` R
Rscript G1_LogisticRegression.R --fold 5 --input [dataset_path]  --report [report_path]
````
#### 步驟

- Step1: 將資料最後100筆切為test data
- Step2: 剩下的train data 拿去訓練以及5-fold cross validation(train/validation比例0.8: 0.2)
- Step3: cross validation 結果

|GlmModel|train_auc|valid_auc|train_ac|valid_ac|train_precision|valid_precision|train_recall|valid_recall|
|:----|:----|:----|:----|:----|:----|:----|:----|:----|
|fold1|0.55|0.48|0.57|0.51|0.56|0.39|0.31|0.24|
|fold2|0.53|0.55|0.57|0.56|0.56|0.66|0.18|0.18|
|fold3|0.54|0.5|0.56|0.52|0.53|0.44|0.32|0.27|
|fold4|0.53|0.55|0.56|0.57|0.54|0.58|0.21|0.23|
|fold5|0.54|0.54|0.57|0.56|0.54|0.53|0.3|0.27|
|ave|0.54|0.52|0.57|0.55|0.55|0.52|0.27|0.24|

- Step4: 對整筆train data做訓練
- Step5: 最終結果

|TrainData|value|TestData|value|
|:----|:----|:----|:----|
|Accuracy|0.56|Accuracy|0.54|
|Precision|0.53|Precision|0.5|
|Recall|0.26|Recall|0.37|
|AUC|0.53|AUC|0.53|

#### AUC
![train data](https://i.imgur.com/OG3QcDv.png)
![test data](https://i.imgur.com/5cBUIgK.png)



### QDA

### NaiveBayes

### Decision Tree
請使用以下Rscript 執行:
```R
Rscript code/G1_DecisionTree.R --input data/ourdata.csv --output results/G1_Decision_tree.csv
```
- step 1:先使用ourdata.csv作為訓練資料，將最後100筆切為最終測試資料
- strp 2:剩下的資料進行three-way split



### Random forest

### SVM

#### import
````R=
library(ROCR)
library(e1071)
library(caret)
library(gridExtra)
````
#### Data pre-processing
:::info
使用model 自己的scale進行正規化
主要使用原始的dataset以及轉換為'漲跌比例的欄位。
:::
#### 參數選擇
:::info
這次主要嘗試使用`e1071`、`caret`的<span style="color:red">網格搜尋</span>方式進行調整參數。
:::
#####  參數選擇1:e107調整參數以及其訓練結果
````R=
# in svm_best_linear_param.R
# 調整kernal
svmtune <-  tune(svm,TAIEX..t.~., data=train_data,probability=TRUE,scale = TRUE,
                 range=list(kernel=c("linear", "polynomial","radial"),cost=seq(0.2,1,0.2)),
                 tunecontrol=tune.control(sampling = "cross",cross = k,performances=TRUE))
write.table(data.frame(svmtune$performances),file='results/SVM_tune_kernal_e1071.csv',quote=FALSE,sep=",",row.names=FALSE, na = "NA")
print('best.parameters')
print(svmtune$best.parameters)

# 調整linear
svmtune <-  tune(svm,TAIEX..t.~., data=train_data,probability=TRUE,scale = TRUE, kernel="linear",cost=0.4,
                 range=list(epsilon=10^c(-1,-2,-3),tolerance=10^c(-1,-2,-3)),
                 tunecontrol=tune.control(sampling = "cross",cross = k,performances=TRUE))
write.table(data.frame(svmtune$performances),file='results/SVM_tune_linear_kernal_e1071.csv',quote=FALSE,sep=",",row.names=FALSE, na = "NA")
plot(svmtune)
print('best.parameters')
print(svmtune$best.parameters)
````
######  **Step1:先比較kernal的差異**
- 先取`kernal`="linear", "polynomial","radial"，"sigmoid"以及cost=0.2、0.4、0.6 、0.8、1.0的參數組合，對`our_data.csv`進行5-fold交叉驗證。
- 最佳結果(loss最小)為kernal=linear,cost=1。        
######  **Step2:針對linear進行調參**
- linear沒有特別的讀有參數，因此選擇最次針對epsilon=10^c(-1,-2,-3) 、tolerance=10^c(-1,-2,-3)這兩個進行調整，結果如下:
- ![](https://i.imgur.com/V6fG87E.png)
- 最終結果為預設的參表現`tolerance=0.1`、`epsilon=0.01`最好(loss最小)。

> 上述的調參可由執行svm_best_linear_param.R而得，可以產生調參的紀錄檔案。
> - 檔案`SVM_tune_kernal_e1071.csv`為step1。
> - 檔案`SVM_tune_linear_kernal_e1071.csv`為Step2。
> 重複執行會發現每次進行之結果kernal接固定在'linear'，但Cost的選擇因為loss差距十分小因此不一定能重現。
##### **Step3: 將這組參數進行訊鍊與預測，產生結果**:
:::info
分為 ourdata,csv、only_diff.csv進行比較。
:::
- 使用`G1_svm_linear.R`，按照以下方式執行:
```` R
Rscript G1_svm_linear.R --train_path [dataset_path]  --report_path [report_path]
````
##### 在ourdata上表現的結果如下:
- 交叉驗證

| ACC   | train_ACC | validation_ACC | recall | train_recall | validation_recall | percion | training_p | validation_p | AUC   | train_AUC | validation_AUC |
|-------|-----------|----------------|--------|--------------|-------------------|---------|------------|--------------|-------|-----------|----------------|
| fold1 | 1         | 0.54           | fold1  | 1            | 0.89              | fold1   | 1          | 0.54         | fold1 | 1         | 0.51           |
| fold2 | 1         | 0.54           | fold2  | 1            | 0.86              | fold2   | 1          | 0.54         | fold2 | 1         | 0.49           |
| fold3 | 1         | 0.59           | fold3  | 1            | 0.93              | fold3   | 1          | 0.59         | fold3 | 1         | 0.55           |
| fold4 | 1         | 0.52           | fold4  | 1            | 0.94              | fold4   | 1          | 0.52         | fold4 | 1         | 0.48           |
| fold5 | 1         | 0.58           | fold5  | 1            | 0.93              | fold5   | 1          | 0.59         | fold5 | 1         | 0.55           |
| ave.  | 1         | 0.55           | ave.   | 1            | 0.91              | ave.    | 1          | 0.56         | ave.  | 1         | 0.52           |

- 最終在train 、test上之表現

| Mectrics  | train   | test     |
|-----------|---------|----------|
| ACC       | 1       | 0.49     |
| Percision | 0.54604 | 0.494949 |
| Recall    | 0.98    | 0.98     |
| AUC       | 1       | 0.482    |
|ROC Curve|![](https://i.imgur.com/jNyDl80.png)|![](https://i.imgur.com/08uM2P7.png)|

##### 在only_diff.csv上表現的結果如下:
- 交叉驗證:

| ACC   | train\_ACC | validation\_ACC | recall | train\_recall | validation\_recall | percion | training\_p | validation\_p | AUC   | train\_AUC | validation\_AUC |
| ----- | ---------- | --------------- | ------ | ------------- | ------------------ | ------- | ----------- | ------------- | ----- | ---------- | --------------- |
| fold1 | 1          | 0.61            | fold1  | 0.99          | 0.78               | fold1   | 1           | 0.61          | fold1 | 1          | 0.68            |  |
| fold2 | 0.99       | 0.61            | fold2  | 0.99          | 0.8                | fold2   | 0.99        | 0.6           | fold2 | 1          | 0.65            |  |
| fold3 | 1          | 0.67            | fold3  | 0.99          | 0.81               | fold3   | 1           | 0.67          | fold3 | 1          | 0.71            |  |
| fold4 | 1          | 0.59            | fold4  | 1             | 0.84               | fold4   | 1           | 0.57          | fold4 | 1          | 0.69            |  |
| fold5 | 0.99       | 0.61            | fold5  | 0.99          | 0.79               | fold5   | 1           | 0.63          | fold5 | 1          | 0.65            |  |
| ave.  | 0.99       | 0.62            | ave.   | 0.99          | 0.8                | ave.    | 1           | 0.62          | ave.  | 1          | 0.68            |  |

- 最終在train 、test上之表現

| Mectrics  | train    | test     |
|-----------|----------|----------|
| ACC       | 0.995493 | 0.51     |
| Percision | 0.545925 | 0.507246 |
| Recall    | 0.7      | 0.7      |
| AUC       | 0.998667 | 0.6008   |
|ROC Curve|![](https://i.imgur.com/R7Cv43g.jpg)|![](https://i.imgur.com/VoBYpNP.jpg)|



> 使用漲跌幅的話，準確率顯著提升且超過Null model。

#### 參數選擇:使用carte
:::info
上述的調參順序使先使用預設的結果進行，由於在ourdata.csv中的AUC成效較差。因此嘗是分別針對各個kernal的參數進行網格搜尋。進而比較彼此的結果。
:::



######  **Step1:針對各種kernal 進行調參**

```` R=
train_control <- trainControl(method="repeatedcv", number=5, repeats=1)
svm_linear <- train(TAIEX..t. ~., data = train_data[,2:ncol(train_data)], method = "svmLinear", trControl = train_control,  preProcess = c("scale"), tuneGrid = expand.grid(C = seq(0, 10, length =21) ))
svm_Radial <- train(TAIEX..t. ~., data = train_data[,2:ncol(train_data)], method = "svmRadial", trControl = train_control, preProcess = c("scale"), tuneLength = 10)
svm_ploy <- train(TAIEX..t. ~., data = train_data[,2:ncol(train_data)], method = "svmPoly", trControl = train_control, preProcess = c("scale"), tuneLength = 5)
````
###### **Step2: 各kenarl結果**
|kernal|linear|polynomial|radial|
|---|---|---|---|
||![](https://i.imgur.com/SVOzuDZ.jpg)|![](https://i.imgur.com/MlkDY37.jpg)|![](https://i.imgur.com/M0NXQKV.jpg)|
|最佳結果|C=9.5|(degree=1，scale=0.001，C=0.25)	|(sigma=0.00030133,C=1)|
|準確率|0.49|0.543253685|0.543253685|
|備註|這次針對C的搜尋範圍有擴增，因此找到了與上次不同的參數。|可以看見最穩定預測的模型仍是以degree=1為主，加入polynomial的正則化後表現更好比單純linear更好|因為polynomail的選擇接近線性的kernal，radial是目前找到唯依表現較佳的由非線性kernal的參數組合|
> 套件會依照Accuracy之SD大小排序，選擇其中Accuracy之SD最小、Accuracy 表現最佳者當首選模型。
> 本次實驗選擇radial的組合進行與測與分析。

- 詳細每個調參獲得之Acc可在以下檔案得到資訊
    - results/SVM_linear.csv
    - results/SVM_rbf.csv
    - results/SVM_ploy.csv
    - 檔案可以藉由執行svm_best_linear_param.產生

###### **Step 3 :該參數組合在資料及上的表現結果**
- 使用`G1_svm_linear.R`，按照以下方式執行:
```` R=
Rscript G1_SVM.R --train_path [dataset_path]  --report_path [report_path]
````
##### 在ourdata上表現的結果如下:
- 交叉驗證

| ACC   | train\_ACC | validation\_ACC | recall | train\_recall | validation\_recall | percion | training\_p | validation\_p | AUC   | train\_AUC | validation\_AUC |
| ----- | ---------- | --------------- | ------ | ------------- | ------------------ | ------- | ----------- | ------------- | ----- | ---------- | --------------- |
| fold1 | 0.55       | 0.54            | fold1  | 1             | 1                  | fold1   | 0.55        | 0.54          | fold1 | 1          | 0.48            |
| fold2 | 0.55       | 0.54            | fold2  | 1             | 1                  | fold2   | 0.55        | 0.54          | fold2 | 1          | 0.5             |
| fold3 | 0.54       | 0.57            | fold3  | 1             | 1                  | fold3   | 0.54        | 0.57          | fold3 | 1          | 0.52            |
| fold4 | 0.56       | 0.51            | fold4  | 1             | 1                  | fold4   | 0.56        | 0.51          | fold4 | 1          | 0.48            |
| fold5 | 0.54       | 0.57            | fold5  | 1             | 1                  | fold5   | 0.54        | 0.57          | fold5 | 1          | 0.53            |
| ave.  | 0.55       | 0.55            | ave.   | 1             | 1                  | ave.    | 0.55        | 0.55          | ave.  | 1          | 0.5             |

- 最終在train 、test上之表現

| Mectrics  | train   | test   |
|-----------|---------|--------|
| ACC       | 0.54604 | 0.5    |
| Percision | 1       | 0.5    |
| Recall    | 1       | 1      |
| AUC       | 1       | 0.5072 |
|ROC Curve|![](https://i.imgur.com/ME2WUtR.jpg)|![](https://i.imgur.com/i4hoype.jpg)|

###### 在only_diff.csv之表現:
- 交叉驗證

| ACC   | train\_ACC | validation\_ACC | recall | train\_recall | validation\_recall | percion | training\_p | validation\_p | AUC   | train\_AUC | validation\_AUC |
| ----- | ---------- | --------------- | ------ | ------------- | ------------------ | ------- | ----------- | ------------- | ----- | ---------- | --------------- |
| fold1 | 0.55       | 0.54            | fold1  | 1             | 1                  | fold1   | 0.55        | 0.54          | fold1 | 0.69       | 0.68            |
| fold2 | 0.55       | 0.54            | fold2  | 1             | 0.99               | fold2   | 0.55        | 0.54          | fold2 | 0.7        | 0.65            |
| fold3 | 0.54       | 0.57            | fold3  | 1             | 1                  | fold3   | 0.54        | 0.57          | fold3 | 0.68       | 0.72            |
| fold4 | 0.56       | 0.51            | fold4  | 1             | 1                  | fold4   | 0.56        | 0.51          | fold4 | 0.69       | 0.68            |
| fold5 | 0.54       | 0.57            | fold5  | 1             | 0.99               | fold5   | 0.54        | 0.57          | fold5 | 0.7        | 0.66            |
| ave.  | 0.55       | 0.55            | ave.   | 1             | 1                  | ave.    | 0.55        | 0.55          | ave.  | 0.69       | 0.68            |

- 最終在train 、test上之表現

| Mectrics  | train    | test   |
|-----------|----------|--------|
| ACC       | 0.549259 | 0.5    |
| Percision | 0.991794 | 0.5    |
| Recall    | 1        | 1      |
| AUC       | 0.687559 | 0.5764 |
|ROC Curve|![](https://i.imgur.com/ABzeyA4.jpg)|![](https://i.imgur.com/BNsEStl.jpg)|


> 整體而言，只有linear SVM 搭配漲跌幅可以提升模型預測之的表現結果。其餘實驗和null model表現較將近。



### **CNN & TCN**

#### **Import**
```r=
library(keras)
library(tensorflow)
library(caret)
library(pROC)
```


#### **Data pre-processing**
:::info
有正負的用標準化，數值較大的用Min Max做處理
:::

```r=
#Drop date column
df <- df[,2:8]

# min-max scale
df[,1] <- df[,1]-min(df[,1])/(max(df[,1])-min(df[,1]))
df[,2] <- df[,2]-min(df[,2])/(max(df[,2])-min(df[,2]))
df[,3] <- df[,3]-min(df[,3])/(max(df[,3])-min(df[,3]))
df[,5] <- df[,5]-min(df[,5])/(max(df[,5])-min(df[,5]))

# z-scale
df[,4] <- (df[,4] - mean(df[,4])) / sd(df[,4])
df[,6] <- (df[,6] - mean(df[,6])) / sd(df[,6])
```

#### **Data Reshape**
```r=
######################### Train
x <- rbind(train_set_X[1:1541,], train_set_X[2:1542,], train_set_X[3:1543,], train_set_X[4:1544,], train_set_X[5:1545,], train_set_X[6:1546,], train_set_X[7:1547,], train_set_X[8:1548,], train_set_X[9:1549,], train_set_X[10:1550,], train_set_X[11:1551,], train_set_X[12:1552,])
train_array_x <- array(x,dim=c(1541, 12, 6))

# train_y
trainy <- data.matrix(train_set_Y, rownames.force = NA)
train_array_y <- array(trainy[12:1552],dim=c(1541, 1))


################## Test
# Test_x
test_array_X <- array(test_set_X[c(1:89, 2:90, 3:91, 4:92, 5:93, 6:94, 7:95, 8:96, 9:97, 10:98, 11:99, 12:100),], c(89,12,6))
print(dim(test_array_X))
# Test_y
testy <- data.matrix(test_set_Y, rownames.force = NA)
test_array_y <- array(testy[12:100],dim=c(89, 1))
```

#### **Build CNN and TCN Model**

#### **TCN**
```r=
model <- keras_model_sequential()

# TCN
model %>%
  layer_conv_1d(filters = 32, kernel_size = 2, activation = "relu",
                input_shape = c(12,6)) %>%
  layer_conv_1d(filters = 64, kernel_size = 2, dilation_rate=2, activation = "relu") %>%
  layer_conv_1d(filters = 64, kernel_size = 2, dilation_rate=4, activation = "relu") %>%
  layer_flatten() %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 1, activation = "sigmoid")

summary(model)
```
![](https://i.imgur.com/RvbXefH.png)

#### **CNN**

```r=
#CNN
model <- keras_model_sequential()

model %>%
  layer_conv_1d(filters = 32, kernel_size = 2, activation = "relu",
                input_shape = c(12,6)) %>%
  layer_conv_1d(filters = 64, kernel_size = 2, activation = "relu") %>%
  layer_conv_1d(filters = 64, kernel_size = 2, activation = "relu") %>%
  layer_flatten() %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 1, activation = "sigmoid")

summary(model)
```
![](https://i.imgur.com/JqtSFET.png)

---

#### **Train Model**
:::info
<span style="color:red">**Hyperparameters**</span>
**Optimizer** : Adam
**Loss** : binary_crossentropy
**metrics** = accuracy
**epochs**= 50
:::
```r=
history <- model %>% fit(train_array_x, train_array_y, epochs=50, batch_size=1, shuffle=FALSE, verbose=0, validation_split = 0.1)
```
#### **Predict**
```r=
predict_y <- model %>% predict(test_array_X, batch_size=1)
predict_y <- round(predict_y)

print(predict_y)
#print(predict_y)
```

#### **Performance**

```r=
plot(history)
print(history)
plot(roc(test_array_y,predict_y), print.auc=TRUE)
```

#### **TCN**

![](https://i.imgur.com/71HTxW6.png)

![](https://i.imgur.com/fVjwHUK.png)


![](https://i.imgur.com/bI7xbQ9.png)



#### **CNN**

![](https://i.imgur.com/TDqmDfQ.png)

![](https://i.imgur.com/QmR6tuN.png)


![](https://i.imgur.com/cgLtArS.png)


### **LSTM**

:::info
資料前處理與LSTM一樣差別在Reshape
:::

#### **Import**
```r=
library(keras)
library(tensorflow)
library(caret)
library(pROC)
```



#### **Split train and test data**
:::info
Train 80% Test 20% 因為是RNN因此不能用上面隨機切順序會影響
:::

```r=
testing_set <- df[(nrow(df)-99):nrow(df),]

df <- df[1:1553,] #1553

# trian 1553  #test 100
train_set_X <- df[1:1553, 1:6] # 1553 * 6
train_set_Y <- df[1:1553, 7]  # 1553* 1

test_set_X <- testing_set[1:100, 1:6] # 100 * 6
test_set_Y <- testing_set[1:100, 7] # 100 * 1


train_set_X <- data.matrix(train_set_X, rownames.force = NA)
test_set_X <- data.matrix(test_set_X, rownames.force = NA)
```

#### **Convert data type and reshape**
```r=

####################Train
x <- rbind(train_set_X[1:1549,], train_set_X[2:1550,], train_set_X[3:1551,], train_set_X[4:1552,])
train_array_x <- array(x,dim=c(1549, 4, 6))

# train_y
trainy <- data.matrix(train_set_Y, rownames.force = NA)
train_array_y <- array(trainy[4:1552],dim=c(1549, 1))
print(dim(train_array_y))

####################Test
# Test_x
test_array_X <- array(test_set_X[c(1:97, 2:98, 3:99, 4:100),], c(97,4,6))
print(dim(test_array_X))
# Test_y
testy <- data.matrix(test_set_Y, rownames.force = NA)
test_array_y <- array(testy[4:100],dim=c(97, 1))
print(dim(test_array_y))
```

#### **Build LSTM Model**
```r=
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
![](https://i.imgur.com/lrj93Ba.png)

summary(model)
```
![](https://i.imgur.com/126xICC.png)

---

#### **Train Model**
:::info
<span style="color:red">**Hyperparameters**</span>
**Optimizer** : Adam
**Loss** : binary_crossentropy
**metrics** = accuracy
**epochs**=50
:::
```r=
 history <- model %>% fit(train_array_x, train_array_y, epochs=50, batch_size=1, shuffle=FALSE, verbose=0, validation_split = 0.1)
```
#### **Predict**
```r=
predict_y <- model %>% predict(test_array_X, batch_size=1)

predict_y <- round(predict_y)
table(predict_y, test_array_y)
#print(predict_y)
```

#### **Performance**

```r=
plot(history)
print(history)
plot(roc(test_array_y,predict_y), print.auc=TRUE)
```

![](https://i.imgur.com/7k11XZW.png)

![](https://i.imgur.com/PY9T1vG.png)


![](https://i.imgur.com/jlQjKlN.png)



## **References**
* Code/implementation which you include/reference (__You should indicate in your presentation if you use code for others. Otherwise, cheating will result in 0 score for final project.__)
    * [Finmind api for total net of TSMC](https://finmind.github.io/tutor/TaiwanMarket/DataList/)
    *    [雅虎財經 for 美股四大指數](https://hk.finance.yahoo.com/)
    *    [比特幣](https://hk.investing.com/crypto/)
    *    [台灣指數公司 for TAIEX](https://www.taiwanindex.com.tw/)
    * [R tensorflow](https://tensorflow.rstudio.com/)
    * [R Docs](https://www.rdocumentation.org/)
### Packages you use

```r=
library(tensorflow)
library(ggplot2)
library(keras)
library(caret)
library(pROC)
library(ROCR)
library(rpart)
library(randomForest)
library(e1071)
library(lattice)
library(gridExtra)
```

### Related publications
Tsmc.api.R (in code dictionary), this api was download from (https://finmind.github.io/), which is an open source, more details will show in final paper.
