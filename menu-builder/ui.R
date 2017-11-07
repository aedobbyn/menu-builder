

library(shiny)
library(DT)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  theme = shinytheme("yeti"),
  
  titlePanel("Menu Autoworkbench Prototype"),
  
  # conditionalPanel(
  #   condition = "input.wizard_it == 2",
  #   h3("Compliant Menu"),
  # 
  #   condition_diffs = "input.see_diffs == 2",
  #   h3("Differences")),
  
  # DT::dataTableOutput("all_nut_and_mr_df"),
  
  fluidRow(
    column(width = 12,
  
      br(),
      
      conditionalPanel(
        condition = "input.build_menu == 0",
        h3("All Nutrients")),
      
      conditionalPanel(
        condition = "input.build_menu != 0",
        h3("Original Menu")),
    
      DT::dataTableOutput("menu"),
      
      actionButton("build_menu", "Build Menu")
      
      
      )
  ),
  
  br(),
  
  fluidRow(
    column(width = 12,
           
           conditionalPanel(
             condition = "input.build_menu != 0",
             actionButton("adjust_portions", "Adjust Portion Sizes")),
           
           conditionalPanel(
             condition = "input.build_menu != 0",
             actionButton("swap_foods", "Swap Foods"))
    )
  ),
  
  br(),

  fluidRow(
    column(width = 12,
           
           # conditionalPanel(
           #   condition = "nrow(mr_compliance()) > 0",
           #   dataTableOutput("mr_compliance")),
           
           dataTableOutput("mr_compliance"),

           br(),

           dataTableOutput("pos_compliance")

    )
  ),

  br(),
  br(),


  fluidRow(
    column(width = 12,

      actionButton("wizard_it", "Wizard It")

    )
  ),

  br(),

  conditionalPanel(
    condition = "input.wizard_it != 0",
    h3("Compliant Menu")),

  fluidRow(
    column(width = 12,

    DT::dataTableOutput("master_menu")
    
    )
  ),

  br(),
  br(),

  conditionalPanel(

    condition = "input.build_menu != 0 & input.wizard_it != 0",
    actionButton("see_diffs", "See Differences")),

  conditionalPanel(
    condition = "input.see_diffs != 0",
    h3("Differences"),
    helpText("Differences between the original menu and compliant menu.")),




  fluidRow(
    column(width = 12,

           DT::dataTableOutput("diffs")
    )
  ),


  
  br(),
  br(),
  br()
))
