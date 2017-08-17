

library(shiny)
library(DT)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  theme = shinytheme("spacelab"),
  
  br(),
  
  p("Original Menu"),
  
  DT::dataTableOutput("menu"),
  
  actionButton("refresh_menu", "Refresh Menu"),
  
  br(),
  
  # actionButton("adjust_portions", "Adjust Portion Sizes"),
  
  br(),
  
  textOutput("mr_compliance"),
  
  # textOutput("pos_compliance"),
  
  p("Compliant Menu"),
  
  DT::dataTableOutput("master_menu")
  
))
