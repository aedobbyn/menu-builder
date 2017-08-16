
library(shiny)

source("./menu_builder_shiny.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  
  output$menu <- DT::renderDataTable({
    menu
  })
  
  output$mr_compliance <- renderText({
    test_mr_compliance(menu)
  })
  
  output$pos_compliance <- renderText({
    test_mr_compliance(menu)
  })
  
  output$master_menu <- DT::renderDataTable({
    master_menu
  })
  
})
