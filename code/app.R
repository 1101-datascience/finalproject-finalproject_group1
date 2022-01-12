
library(shiny)
library(ggbiplot)
library(ca)
library(DT)
library("FactoMineR")
library("corrplot")
library("factoextra")

data <- read.csv("../data/ourdata.csv", header = T)
data<-data.frame(data)

overview_cros <- read.csv("../results/CROSS_OVERVIEW.csv", header = T)

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
                          tabPanel(h2("RAW data"),
                                   #plotOutput("pcaPlot", width = "100%")
                                   datatable(data),
                                   plotOutput('cor')
                          ),
                          tabPanel(h2("Data01"),
                                   # verbatimTextOutput("pcaResult")
                          ),
                          tabPanel(h2("Data02"),
                                   # verbatimTextOutput("pcaSummary"))
                          )
                          
                        )
                      )
             ),
             tabPanel(p("Result", style = "color:#6A3E3E;font-size: 25px;font-family: Century Gothic, sans-serif;font-weight: bold"),
                      tags$style(type='text/css', '#pcaResult,#pcaSummary,#caData{background-color: white; color: #756767;font-family: Consolas;font-weight: bold;font-size: 12px}'),
                      #titlePanel(h1("Stock Prediction Evaluation")),
                      # sidebarPanel(
                      #   selectInput("selectdata","Select Data Set:",c("Raw Data" = 1,"Only Diff" = 2),selected = 1)
                      # ),
                      mainPanel(
                        tabsetPanel(
                          tabPanel(h2("Overview"),
                                   # verbatimTextOutput("pcaSummary"))
                          ),
                          tabPanel(h2("Naive Bayes"),
                                   #plotOutput("pcaPlot", width = "100%")
                          ),
                          tabPanel(h2("SVM"),
                                   # verbatimTextOutput("pcaResult")
                          ),
                          tabPanel(h2("Decision Tree"),
                                   # verbatimTextOutput("pcaResult")
                          ),
                          tabPanel(h2("Logistic Regression"),
                                   # verbatimTextOutput("pcaResult")
                          ),
                          tabPanel(h2("Random Forest"),
                                   # verbatimTextOutput("pcaResult")
                          ),
                          tabPanel(h2("LSTM"),
                                   # verbatimTextOutput("pcaResult")
                          ),
                          tabPanel(h2("CNN"),
                                   # verbatimTextOutput("pcaResult")
                          ),
                          tabPanel(h2("TCN"),
                                   # verbatimTextOutput("pcaSummary"))
                          )
                          
                          
                        )
                      )
                      #tabPanel(p("CA", style = "color:#6A3E3E;font-size: 25px;font-family: Century Gothic, sans-serif;font-weight: bold"),
                      #titlePanel(h1("Correspondence Analysis")),
                      # sidebarPanel(
                      #   sliderInput("rangeCA", "Range of Input Data:",min = 1, max = 150,value = c(1,150)),
                      #   selectInput("Dstart","Choose Start Dimension of Contribution :",c("Dim 1" = 1,
                      #                                                                     "Dim 2" = 2,
                      #                                                                     "Dim 3" = 3),selected = 1),
                      #   selectInput("Dend","Choose Last Dimension of Contribution :",c("Dim 1" = 1,
                      #                                                                  "Dim 2" = 2,
                      #                                                                  "Dim 3" = 3),selected = 1)
                      # ),
                      # mainPanel(
                      #   tabsetPanel(
                      #     tabPanel(h2("CA Biplot"),
                      #              plotOutput("caPlot")
                      #     ),
                      #     tabPanel(h2("CA Summary"),
                      #              verbatimTextOutput("caData")
                      #     ),
                      #     tabPanel(h2("CA Row Contribution Plot"),
                      #              plotOutput("caRowContribPlot")
                      #     ),
                      #     tabPanel(h2("CA Column Contribution Plot"),
                      #              plotOutput("caColContribPlot")
                      #     ),
                      #     tabPanel(h2("CA Sree Plot"),
                      #              plotOutput("caScreeplot")
                      #     )
                      #   )
                      # )
             )
             
  )
)

server <- function(input, output) {
  # data(iris)
  #data <- read.csv("../data/ourdata.csv", header = T)
 # data<-data.frame(data)
  
  
  
  output$cor<-renderPlot({
    names(data) <- c("Date","SOX_Close","Dow.Jones_Close","NASDAQ_Close","Bitcoin_Change","S_P_500_Close","total_net_tsmc","TAIEX")
    data <- data[-6]
    data <- data[-1]
    corrplot(abs(cor(data[1:nrow(data),1:(ncol(data)-1)]))
             ,method='color',type='full'
             ,bg='black'
             ,addgrid.col='black',tl.cex=0.6,tl.col='grey')})
  
  # log.ir <- log(iris[, 1:4])
  # ir.species <- iris[, 5]
  # ir.pca <- prcomp(log.ir,center = TRUE, scale. = TRUE)
  # ir.ca = ca(iris[, 1:4])
  log.ir <- reactive(log(iris[input$rangePCA[1]:input$rangePCA[2], 1:4]))
  ir.species <- reactive(iris[input$rangePCA[1]:input$rangePCA[2],5])
  ir.pca <- reactive(prcomp(log.ir(),center = TRUE, scale. = TRUE))
  ir.ca  <- reactive(CA(iris[input$rangeCA[1]:input$rangeCA[2], 1:4], graph = FALSE))
  
  output$pcaData <- renderPrint(
    iris
  )
  output$pcaResult <- renderPrint({
    ir.pca()
  })
  output$pcaSummary <- renderPrint(
    summary(ir.pca())
  )
  output$pcaPlot <- renderPlot({
    g <- ggbiplot(ir.pca(), choices = c(as.numeric(input$x),as.numeric(input$y)),obs.scale = 1, var.scale = 1, groups = ir.species()) 
    g <- g + scale_color_discrete(name = '') 
    g <- g + theme(legend.direction = 'horizontal', legend.position = 'top')
    print(g)
  })
  output$caData <- renderPrint(
    summary(ir.ca())
  )
  output$caPlot <- renderPlot(
    fviz_ca_biplot(ir.ca(),title = "")
  )
  output$caScreeplot <- renderPlot(
    fviz_screeplot(ir.ca(), addlabels = TRUE,barfill = "#9A8E8E", barcolor = "black",title = "") +geom_hline(yintercept=33.33, linetype=2, color="red")
  )
  output$caRowContribPlot <- renderPlot(
    fviz_contrib(ir.ca(), choice = "row", axes = input$Dstart:input$Dend,fill = "#9A8E8E",color = "black")
  )
  output$caColContribPlot <- renderPlot(
    fviz_contrib(ir.ca(), choice = "col", axes = input$Dstart:input$Dend,fill = "#9A8E8E",color = "black")
  )
}

# Create Shiny app ----
shinyApp(ui, server)
