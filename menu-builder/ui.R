

library(shiny)
library(DT)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  theme = shinytheme("spacelab"),
  
  titlePanel("Menu Autoworkbench Prototype"),
  
  fluidRow(
    column(width = 12,
  
    br(),
  
    h3("Original Menu"),
    
    DT::dataTableOutput("menu"),
    
    actionButton("refresh_menu", "Refresh Menu")
    
    # DT::dataTableOutput("swapped")
    
    )
  ),
  
  br(),
  
  fluidRow(
    column(width = 12,
  
    actionButton("adjust_portions", "Adjust Portion Sizes"),
    
    actionButton("swap_foods", "Swap Foods")
    )
  ),
  
  br(),
  
  fluidRow(
    column(width = 12,
  
    textOutput("mr_compliance")
    
    # textOutput("pos_compliance")
  
    )
  ),
    
  br(),
  br(),
  
  fluidRow(
    column(width = 12,
  
    h3("Compliant Menu"),
    
    DT::dataTableOutput("master_menu")
    )
  )
))
