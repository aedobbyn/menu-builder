
library(shiny)

source("./menu_builder_shiny.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  menu <- reactiveValues(data = NULL)
  
  # Build the menu
  observeEvent(input$refresh_menu, {
    menu$data <- build_menu(abbrev)
  })
  
  # Render data table
  output$menu <- DT::renderDataTable({
    menu$data
  })
  
  # Must restrict compliance
  output$mr_compliance <- renderText({
    test_mr_compliance(menu$data)
  })
  
  # # Positive compliance
  # output$pos_compliance <- renderText({
  #   test_pos_compliance(menu$data)
  # })
  
  # -------------- Adjust portion sizes ---------
  
  # observeEvent(input$adjust_portions, {
  #   menu$data <- smart_swap(menu$data)
  # })
  
  
  # ------------- Build master menu from original menu -----------
  
  master_menu <- reactiveValues(data = NULL)
  
  observeEvent(input$refresh_menu, {
    master_menu$data <- master_builder(menu$data)
  })
  
  output$master_menu <- DT::renderDataTable({
    master_menu$data
  })
  
  output$mr_compliance <- renderText({
    test_mr_compliance(master_menu$data)
  })
  
  output$pos_compliance <- renderText({
    test_pos_compliance(master_menu$data)
  })
  
  
})
