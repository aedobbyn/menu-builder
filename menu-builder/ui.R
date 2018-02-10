library(shiny)
library(DT)
library(shinythemes)
library(shinycssloaders)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  theme = shinytheme("yeti"),
  
  titlePanel("Menu Autoworkbench Prototype"),
  h5("Amanda Dobbyn"),
  
  # conditionalPanel(
  #   condition="!($('html').hasClass('shiny-busy'))",
  #   img(src="./onward.gif")
  # ),
  
  fluidRow(
    column(width = 12,
  
      br(),
      
      conditionalPanel(
        condition = "input.build_menu == 0",
        h3("All Required Nutrient Values")),
      
      conditionalPanel(
        condition = "input.build_menu != 0",
        h3("Original Menu")),
    
      withSpinner(DT::dataTableOutput("menu")),
      
      actionButton("build_menu", "Build Menu")
      
      
      )
  ),
  
  br(),
  
  fluidRow(
    column(width = 12,
           
           conditionalPanel(
             condition = "input.build_menu != 0",
             actionButton("adjust_portions", "Solve It")),
           
           conditionalPanel(
             condition = "input.build_menu != 0",
             actionButton("swap_foods", "Swap Foods"))
    )
  ),
  
  br(),

  fluidRow(
    column(width = 12,
           
           # conditionalPanel(
           #   condition = "nrow(mr_compliance > 0)",
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

      actionButton("wizard_it_from_scratch", "Wizard It from Scratch"),
      
      conditionalPanel(
        condition = "input.build_menu != 0", 
        actionButton("wizard_it_from_seeded", "Wizard It from Original"))
    )
  ),

  br(),

  conditionalPanel(
    condition = "input.wizard_it_from_scratch != 0 | input.wizard_it_from_seeded != 0",
    h3("Compliant Menu")),

  fluidRow(
    column(width = 12,

    withSpinner(DT::dataTableOutput("master_menu"))
    
    )
  ),

  br(),
  br(),

  conditionalPanel(

    condition = "input.build_menu != 0 & 
      (input.wizard_it_from_scratch != 0 | input.wizard_it_from_seeded != 0)",
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
