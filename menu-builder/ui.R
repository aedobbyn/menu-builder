

library(shiny)
library(DT)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  theme = shinytheme("yeti"),
  
  titlePanel("Menu Autoworkbench Prototype"),
  
  fluidRow(
    column(width = 12,
  
      br(),
    
      h3("Original Menu"),
      
      DT::dataTableOutput("menu"),
      
      actionButton("build_menu", "Build Menu"),
      
      actionButton("adjust_portions", "Adjust Portion Sizes"),
      
      actionButton("swap_foods", "Swap Foods")
      
      )
  ),
  
  br(),
  
  fluidRow(
    column(width = 12,
           
           textOutput("mr_compliance")
           
           # br(),
           # 
           # textOutput("pos_compliance")
           
    )
  ),
  
  fluidRow(
    column(width = 12,
           
           # textOutput("pos_compliance")
           
           # br(),
           # 
           textOutput("pos_compliance")
           
    )
  ),
  
  br(),
  br(),
  
  # fluidRow(
  #   column(width = 12,
  #          
  #      br(),
  #      
  #      h3("Swapped Menu"),
  #      
  #      actionButton("swap_foods", "Swap Foods"),
  # 
  #     DT::dataTableOutput("swapped")
  #   )
  # ),
  
  fluidRow(
    column(width = 12,
    
      actionButton("wizard_it", "Wizard It")
  
    )
  ),
  
  br(),
  
  
  fluidRow(
    column(width = 12,
  
    h3("Compliant Menu"),
    
    DT::dataTableOutput("master_menu")
    )
  ),
  
  br(), 
  br(),
  
  fluidRow(
    column(width = 12,
           
           actionButton("see_diffs", "See Differences"),
           
           h3("Differences"),
           
           DT::dataTableOutput("diffs")
    )
  )
))
