

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
  
  conditionalPanel(
    condition = "input$wizard_it != 0",
    h3("Compliant Menu")),
  
  fluidRow(
    column(width = 12,
     
    
    DT::dataTableOutput("master_menu")
    )
  ),
  
  br(), 
  br(),
  
  conditionalPanel(
    condition_diffs = "input$see_diffs != 0",
    h3("Differences")),
  
  fluidRow(
    column(width = 12,
           
           actionButton("see_diffs", "See Differences"),
           
           
           DT::dataTableOutput("diffs")
    )
  ),
  
  br(),
  br(),
  br()
))
