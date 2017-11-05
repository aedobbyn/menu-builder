
library(shiny)

source("./menu_builder_shiny.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  menu <- reactiveValues(data = NULL)
  
  # Build the menu
  observeEvent(input$build_menu, {
    menu$data <- build_menu(abbrev)
  })
  
  # Render data table
  output$menu <- DT::renderDataTable({
    menu$data %>% 
      select(GmWt_1, everything())
  })


  # -------------- Adjust portion sizes ---------


  observeEvent(input$adjust_portions, {
    menu$data <- adjust_portion_sizes(menu$data)
  })

  # -------------- Swap Foods ---------

  swapped <- reactiveValues(data = NULL)

  observeEvent(input$swap_foods, {
    swapped$data <- smart_swap(menu$data)
  })
  
  # Render data table
  output$swapped <- DT::renderDataTable({
    swapped$data %>% 
      select(GmWt_1, everything())
  })


  # ------------- Build master menu from original menu -----------

  master_menu <- reactiveValues(data = NULL)

  observeEvent(input$wizard_it, {
    master_menu$data <- master_builder(menu$data)
  })

  output$master_menu <- DT::renderDataTable({
    master_menu$data %>% 
      select(GmWt_1, everything())# return the full menu
  })
  
  
  # ------------ Compliance -----------
  
  mr_compliance <- reactiveValues(data = NULL)
  pos_compliance <- reactiveValues(data = NULL)
  
  # Must restrict compliance
  output$mr_compliance <- renderText({
    test_mr_compliance(menu$data)
  })
  
  # Positive compliance
  output$pos_compliance <- renderText({
    test_pos_compliance(menu$data)
  })
  
  
})
