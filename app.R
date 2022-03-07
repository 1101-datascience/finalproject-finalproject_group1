
library(shiny)
library(DT)
library("corrplot")
library(ggplot2)
library(reactable)
data <- read.csv("data/ourdata.csv", header = T)
data<-data.frame(data)

diff_data <- read.csv("data/only_diff.csv", header = T)
diff_data<-data.frame(diff_data)

add_features_data <- read.csv("data/ourdata_addFeatures5.csv", header = T)
add_features_data<-data.frame(add_features_data)

overview_cros_train <- read.csv("results/overview_cros_train.csv", header = T)
overview_cros_valid <- read.csv("results/overview_cros_vaild.csv", header = T)
overview_final_train <- read.csv("results/overview_final_train.csv", header = T)
overview_final_test <- read.csv("results/overview_final_test.csv", header = T)

cros_overview <- read.csv("results/cros_overview.csv", header = T)
final_overview <- read.csv("results/final_overview.csv", header = T)
rownames(cros_overview) <- as.matrix(cros_overview[1])
rownames(final_overview ) <- as.matrix(final_overview [1])
cros_overview <- cros_overview[-1]
final_overview <- final_overview[-1]

lr.crosview <- cros_overview[-2:-7,]
svm.crosview <- cros_overview[-1,]
svm.crosview <- svm.crosview[-2:-6,]
rf.crosview <- cros_overview[-1:-2,]
rf.crosview <- rf.crosview[-2:-5,]
dt.crosview <- cros_overview[-1:-3,]
dt.crosview <- dt.crosview[-2:-4,]
nb.crosview <- cros_overview[-1:-4,]
nb.crosview <- nb.crosview[-2:-3,]
qda.crosview <- cros_overview[-1:-5,]
qda.crosview <- qda.crosview[-2,]
null.crosview <- cros_overview[-1:-6,]

rownames(lr.crosview) <- "Evaluation"
rownames(svm.crosview) <- "Evaluation"
rownames(rf.crosview) <- "Evaluation"
rownames(dt.crosview) <- "Evaluation"
rownames(nb.crosview) <- "Evaluation"
rownames(qda.crosview) <- "Evaluation"
rownames(null.crosview) <- "Evaluation"

lr.finalview <- final_overview[-2:-7,]
svm.finalview <- final_overview[-1,]
svm.finalview <- svm.finalview[-2:-6,]
rf.finalview <- final_overview[-1:-2,]
rf.finalview <- rf.finalview[-2:-5,]
dt.finalview <- final_overview[-1:-3,]
dt.finalview <- dt.finalview[-2:-4,]
nb.finalview <- final_overview[-1:-4,]
nb.finalview <- nb.finalview[-2:-3,]
qda.finalview <- final_overview[-1:-5,]
qda.finalview <- qda.finalview[-2,]
null.finalview <- final_overview[-1:-6,]

rownames(lr.finalview) <- "Evaluation"
rownames(svm.finalview) <- "Evaluation"
rownames(rf.finalview) <- "Evaluation"
rownames(dt.finalview) <- "Evaluation"
rownames(nb.finalview) <- "Evaluation"
rownames(qda.finalview) <- "Evaluation"
rownames(null.finalview) <- "Evaluation"



ui <- fluidPage(
  title = "Data Science Final Project - Group 1",
  tags$head(
    tags$style(HTML("
    .navbar-nav > li > a, .navbar-brand {
                   padding-top:10px !important; 
                   padding-bottom:10px !important;
                   height: 40px;
                 }
                 .navbar {min-height:25px !important;}
      body {
        background-color: #F2EDE8;
      }
      h1 {
        color:#415692;
        font-size: 30px;
        font-family: Century Gothic, sans-serif;
        font-weight: bold
      }
       h2 {
        font-family: Century Gothic, 
        sans-serif;
        color:#856A6A;
        font-size: 18px;
        font-weight: bold
       }
      h3 {
        font-family: Century Gothic, 
        sans-serif;
        color:#856A6A;
        font-size: 15px;
        font-weight: bold
      }
      .shiny-input-container {
        color: #403B3B;
      }
      #sidebar {
             background-color: #D2E8EE;
             }
             body, label, input, button, select {
             color: #856A6A;
             font-family: Century Gothic, sans-serif;
             font-weight: bold;
             font-size: 15px;}
                    "))
  ),
  navbarPage(p("Stock Prediction", style = "color:#6A3E3E;font-size: 25px;font-family: Century Gothic, sans-serif;font-weight: bold"),
             tabPanel(p("Dataset", style = "color:#6A3E3E;font-size: 25px;font-family: Century Gothic, sans-serif;font-weight: bold"),
                      #titlePanel(h1("Data: Iris dataset")),
                    #  mainPanel(datatable(data)),
                      mainPanel(
                        tabsetPanel(
                          tabPanel(h2("RAW Data"),
                                   #plotOutput("pcaPlot", width = "100%")
                                   br(),
                                   datatable(data),
                                   br(),
                                   br(),
                                   div("Data Correlations", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   plotOutput('cor'),
                                   br(),
                                   br(),
                                   div("Data Boxplot", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   plotOutput('boxplot_data'),
                                   br(),
                                   br(),
                                   div("Summary", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   verbatimTextOutput('summary_data')
                          ),
                          tabPanel(h2("Only Diff"),
                                   br(),
                                   datatable(diff_data),
                                   br(),
                                   br(),br(),
                                   br(),br(),
                                   br(),br(),
                                  hr(),hr(),
                                   br(),
                                   div("Data Correlations", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   plotOutput('cor_diff'), 
                                   br(),
                                   br(),
                                   div("Data Boxplot", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   plotOutput('boxplot_diff'),
                                   br(),
                                   br(),
                                   div("Summary", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   verbatimTextOutput('summary_diff')
                                   # verbatimTextOutput("pcaResult")
                          ),
                          tabPanel(h2("Data add Feature"),
                                   br(),
                                   datatable(add_features_data),
                                   br(),
                                   br(),
                                   div("Data Correlations", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   plotOutput('cor_add'),
                                   br(),
                                   br(),
                                   div("Data Boxplot", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   plotOutput('boxplot_add'),
                                   br(),
                                   br(),
                                   div("Summary", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   verbatimTextOutput('summary_add')
  
                          )
                          
                        )
                      )
             ),
             tabPanel(p("Result", style = "color:#6A3E3E;font-size: 25px;font-family: Century Gothic, sans-serif;font-weight: bold"),
                      tags$style(type='text/css', '#pcaResult,#pcaSummary,#caData{background-color: white; color: #756767;font-family: Consolas;font-weight: bold;font-size: 12px}'),
                      mainPanel(
                        tabsetPanel(
                          tabPanel(h2("Overview"),
                                   br(),
                                   div("5-fold Cross validation for train data", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   plotOutput("cros_train", width = "100%"),
                                   br(),
                                   div("5-fold Cross validation for valid data", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   plotOutput("cros_valid", width = "100%"),
                                   br(),
                                   br(),
                                   br(),
                                   div("Final Prediction for train data", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   plotOutput("final_train", width = "100%"),
                                   br(),
                                   div("Final Prediction for test data", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   plotOutput("final_test", width = "100%")
                          ),
                          tabPanel(h2("Naive Bayes"),
  
                                   br(),
                                   div("Average Cross validation", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   reactableOutput("nb_crview"),
                                   br(),
                                   div("Final Prediction", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   reactableOutput("nb_fiview"),
                                   br(),
                                   div("ROC Curve", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   htmlOutput("AUC_nb")
                                   
                          ),
                          tabPanel(h2("SVM"),
                                   br(),
                                   div("Average Cross validation", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   reactableOutput("svm_crview"),
                                   br(),
                                   div("Final Prediction", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   reactableOutput("svm_fiview"),
                                   br(),
                                   div("ROC Curve", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   htmlOutput("AUC_svm")
                                   
                          ),
                          tabPanel(h2("Decision Tree"),
                                   br(),
                                   div("Average Cross validation", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   reactableOutput("dt_crview"),
                                   br(),
                                   div("Final Prediction", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   reactableOutput("dt_fiview"),
                                   br(),
                                   div("ROC Curve", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   htmlOutput("AUC_dt")
                                   
                          ),
                          tabPanel(h2("Logistic Regression"),
                                   br(),
                                   div("Average Cross validation", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   reactableOutput("lr_crview"),
                                   br(),
                                   div("Final Prediction", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   reactableOutput("lr_fiview"),
                                   br(),
                                   div("ROC Curve", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   htmlOutput("AUC_lr")

                          ),
                          tabPanel(h2("Random Forest"),
                                   br(),
                                   div("Average Cross validation", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   reactableOutput("rf_crview"),
                                   br(),
                                   div("Final Prediction", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   reactableOutput("rf_fiview"),
                                   br(),
                                   div("ROC Curve", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:100%"),
                                   htmlOutput("AUC_Rf"),
                          ),
                          tabPanel(h2("LSTM"),
                                   br(),
                                   div("Result", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   htmlOutput("tloss_lstm"),
                                   br(),
                                   div("Loss", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   htmlOutput("floss_lstm"),
  
                          ),
                          tabPanel(h2("CNN"),
                                   br(),
                                   div("Result", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   htmlOutput("tloss_cnn"),
                                   br(),
                                   div("Loss", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   htmlOutput("floss_cnn"),

                          ),
                          tabPanel(h2("TCN"),
                                   br(),
                                   div("Result", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   htmlOutput("tloss_tcn"),
                                   br(),
                                   div("Loss", style = "text-align: center; 
                  background-color: #31A0D9; color:#FDEFC7; font-size:140%"),
                                   htmlOutput("floss_tcn"),
    
                          )
                          
                        )
                      )
             )
  )
)

server <- function(input, output) {

  
  output$cor<-renderPlot({
    names(data) <- c("Date","SOX_Close","Dow.Jones_Close","NASDAQ_Close","Bitcoin_Change","S_P_500_Close","total_net_tsmc","TAIEX")
    data1 <- data[-6]
    data1<- data1[-1]
    corrplot(abs(cor(data1[1:nrow(data1),1:(ncol(data1)-1)]))
             ,method='color',type='full'
             ,bg='black'
             ,addgrid.col='black',tl.cex=0.6,tl.col='grey')})
  
  output$cor_diff<-renderPlot({
    names(diff_data) <- c("Date","SOX_Close","Dow.Jones_Close","NASDAQ_Close","Bitcoin_Change","S_P_500_Close","total_net_tsmc","TAIEX")
    diff_data1 <- diff_data[-6]
    diff_data1 <- diff_data1[-1]
    corrplot(abs(cor(diff_data1[1:nrow(diff_data1),1:(ncol(diff_data1)-1)]))
             ,method='color',type='full'
             ,bg='black'
             ,addgrid.col='black',tl.cex=0.6,tl.col='grey')})
  
  output$cor_add<-renderPlot({
    
    names(add_features_data)<-c(
                                "Date"               ,  "SOX_Close"          ,"SOX_Close_log"       ,"Jones_Close"    ,"Dow.Jones_Close_log",
                                "NASDAQ_Close"       ,"NASDAQ_Close_log"    ,"S_P_500_Close."     , "S_P_500_Close_log"   ,"total_net_tsmc"    ,
                               "Bitcoin_Change" ,   "up_sum"           ,        "SOX_Close_up"        ,"Dow.Jones_Close_up","NASDAQ_Close_up","Bitcoin_Change_up","S_P_500_Close_up","total_net_tsmc_.up","TAIEX_before"  ,"TAIEX"               
                                )
    add_features_data1<-add_features_data[,2:12]
    corrplot(abs(cor(add_features_data1[1:nrow(add_features_data1),1:(ncol(add_features_data1))]))
             ,method='color',type='full'
             ,bg='black'
             ,addgrid.col='black',tl.cex=0.6,tl.col='grey')})
  
  output$boxplot_data<-renderPlot({
    # names(data) <- c("Date","SOX_Close","Dow.Jones_Close","NASDAQ_Close","Bitcoin_Change","S_P_500_Close","total_net_tsmc","TAIEX")
  names(data) <- c("Date","SOX_Close","Dow.Jones_Close","NASDAQ_Close","Bitcoin_Change","S_P_500_Close","total_net_tsmc","TAIEX")
    
    data1 <- data[-6]
    data1<- data1[-1]
    boxplot(data[1:nrow(data),1:(ncol(data)-1)])
    
  })
  output$boxplot_diff<-renderPlot({
    names(diff_data) <- c("Date","SOX_Close","Dow.Jones_Close","NASDAQ_Close","Bitcoin_Change","S_P_500_Close","total_net_tsmc","TAIEX")
    diff_data1 <- diff_data[-6]
    diff_data1 <- diff_data1[-1]
    boxplot(diff_data1[1:nrow(diff_data1),1:(ncol(diff_data1)-1)])
    })
  output$boxplot_add<-renderPlot({
    
    names(add_features_data)<-c(
      "Date"               ,  "SOX_Close"          ,"SOX_Close_log"       ,"Jones_Close"    ,"Dow.Jones_Close_log",
      "NASDAQ_Close"       ,"NASDAQ_Close_log"    ,"S_P_500_Close."     , "S_P_500_Close_log"   ,"total_net_tsmc"    ,
      "Bitcoin_Change" ,   "up_sum"           ,        "SOX_Close_up"        ,"Dow.Jones_Close_up","NASDAQ_Close_up","Bitcoin_Change_up","S_P_500_Close_up","total_net_tsmc_.up","TAIEX_before"  ,"TAIEX"               
    )
    add_features_data1<-add_features_data[,2:12]
    boxplot(add_features_data1[1:nrow(add_features_data1),1:(ncol(add_features_data1))])
    })
  
  output$summary_data<-renderPrint({ summary(data)})
  output$summary_diff<-renderPrint({ summary(diff_data)})
  output$summary_add<-renderPrint({ summary(add_features_data)})
  
  output$cros_train <- renderPlot({
    ggplot(overview_cros_train, aes(fill=Evaluation, y=value, x=Model)) + geom_bar(position="dodge", stat="identity",colour="black")+ scale_fill_hue(c = 40) 
    
    
  })
  output$cros_valid <- renderPlot({
    ggplot(overview_cros_valid, aes(fill=Evaluation, y=value, x=Model)) + geom_bar(position="dodge", stat="identity",colour="black")+ scale_fill_hue(c = 40) 
    
  })
  
  output$final_train <- renderPlot({
    ggplot(overview_final_train, aes(fill=Evaluation, y=value, x=Model)) + geom_bar(position="dodge", stat="identity",colour="black")+ scale_fill_hue(c = 40) 
    
    
  })
  output$final_test <- renderPlot({
    ggplot(overview_final_test, aes(fill=Evaluation, y=value, x=Model)) + geom_bar(position="dodge", stat="identity",colour="black")+ scale_fill_hue(c = 40) 
    
    
  })
  output$lr_crview <- renderReactable({
    reactable(lr.crosview)
  })
  output$lr_fiview <- renderReactable({
    reactable(lr.finalview)
  })
  
  output$svm_crview <- renderReactable({
    reactable(svm.crosview)
  })
  output$svm_fiview <- renderReactable({
    reactable(svm.finalview)
  })
  
  output$rf_crview <- renderReactable({
    reactable(rf.crosview)
  })
  output$rf_fiview <- renderReactable({
    reactable(rf.finalview)
  })
  
  output$dt_crview <- renderReactable({
    reactable(dt.crosview)
  })
  output$dt_fiview <- renderReactable({
    reactable(dt.finalview)
  })
  
  output$nb_crview <- renderReactable({
    reactable(nb.crosview)
  })
  output$nb_fiview <- renderReactable({
    reactable(nb.finalview)
  })
  output$qda_crview <- renderReactable({
    reactable(qda.crosview)
  })
  output$qda_fiview <- renderReactable({
    reactable(qda.finalview)
  })
  
  output$null_crview <- renderReactable({
    reactable(null.crosview)
  })
  output$null_fiview <- renderReactable({
    reactable(null.finalview)
  })
  
   output$AUC_nb <-
    renderText({
      c('<img src="',
        "https://github.com/evaneversaydie/rep/blob/master/nccu_ds_image/NaiveBayes_AUC.png?raw=true",
        '">')
    })
  output$AUC_svm <-
    renderText({
      c('<img src="',
        "https://github.com/evaneversaydie/rep/blob/master/nccu_ds_image/G1_SVM_ROCR_test.jpg?raw=true",
        '">')
    })
  output$AUC_dt <-
    renderText({
      c('<img src="',
        "https://github.com/evaneversaydie/rep/blob/master/nccu_ds_image/G1_Decision%20tree_test.jpeg?raw=true",
        '">')
    })
  output$AUC_lr <-
    renderText({
      c('<img src="',
        "https://github.com/evaneversaydie/rep/blob/master/nccu_ds_image/G1_LogisRegre_AUC_test.jpg?raw=true",
        '">')
         })
  output$AUC_Rf <-
    renderText({
      c('<img src="',
        "https://github.com/YungRuJeng/data_science_template/blob/9eb7f9862f9768a80598e8c8bd8d31f4a9854623/G1_RF_AUC_testing.png?raw=true",
        '">')
    })
  

  output$tloss_lstm <-
    renderText({
      c('<img src="',
        "https://github.com/evaneversaydie/rep/blob/master/nccu_ds_image/G1_LSTM_Training_Loss.png?raw=true",
        '">')
    })
  output$floss_lstm <-
    renderText({
      c('<img src="',
        "https://github.com/evaneversaydie/rep/blob/master/nccu_ds_image/G1_LSTM_Final_Epoch_Loss.png?raw=true",
        '">')
    })
  
  output$tloss_cnn <-
    renderText({
      c('<img src="',
        "https://github.com/evaneversaydie/rep/blob/master/nccu_ds_image/G1_CNN_Training_Loss.png?raw=true",
        '">')
    })
  output$floss_cnn <-
    renderText({
      c('<img src="',
        "https://github.com/evaneversaydie/rep/blob/master/nccu_ds_image/G1_CNN_Final_Epoch_Loss.png?raw=true",
        '">')
    })
  output$tloss_tcn <-
    renderText({
      c('<img src="',
        "https://github.com/evaneversaydie/rep/blob/master/nccu_ds_image/G1_TCN_Training_Loss.png?raw=true",
        '">')
    })
  output$floss_tcn <-
    renderText({
      c('<img src="',
        "https://github.com/evaneversaydie/rep/blob/master/nccu_ds_image/G1_TCN_Final_Epoch_Loss.png?raw=true",
        '">')
    })
}

# Create Shiny app ----
shinyApp(ui, server)
