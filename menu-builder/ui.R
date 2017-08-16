

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  br(),
  
  p("Original Menu"),
  
  DT::dataTableOutput("menu"),
  
  br(),
  
  textOutput("mr_compliance"),
  
  textOutput("pos_compliance"),
  
  p("Compliant Menu"),
  
  DT::dataTableOutput("master_menu")
  
))
