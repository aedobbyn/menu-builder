
library(shiny)

source("./menu_builder_shiny.R")

# set.seed(9)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  menu <- reactiveValues(data = NULL)
  
  # Build the menu
  observeEvent(input$build_menu, {
    menu$data <- build_menu(abbrev)
  })
  
  # Render data table
  output$menu <- DT::renderDataTable({
    if (input$build_menu == 0)
      return(all_nut_and_mr_df %>% cap_df())
    
    else {
      menu$data %>% 
        select(GmWt_1, everything())
    }
  })


  # -------------- Adjust portion sizes ---------
  observeEvent(input$adjust_portions, {
    if (input$adjust_portions == 0)
      return()
    
    menu$data <- adjust_portion_sizes(menu$data)
  })

  
# -------------- Swap Foods -- same menu ---------
  observeEvent(input$swap_foods, {
    if (input$swap_foods == 0)
      return()
    
    menu$data <- smart_swap(menu$data)
  })
  
  # ------------- Build master menu from original menu -----------

  master_menu <- reactiveValues(data = NULL)

  observeEvent(input$wizard_it_from_scratch, {
    withProgress(message = 'Making Menu', value = 0, { master_menu$data <- master_builder() })
  })
  
  observeEvent(input$wizard_it_from_seeded, {
    master_menu$data <- master_builder(menu$data)
  })

  output$master_menu <- DT::renderDataTable({
    if (input$wizard_it_from_scratch == 0 & input$wizard_it_from_seeded == 0)
      return()
    
    master_menu$data %>% 
      select(GmWt_1, everything())# return the full menu
  })
  
  
  # ------------ Compliance -----------
  
  mr_compliance <- reactiveValues(data = NULL)
  pos_compliance <- reactiveValues(data = NULL)

  # Must restrict compliance
  output$mr_compliance <- DT::renderDataTable({
    if (input$build_menu == 0) {
      return() 
    }
    
    test_mr_compliance(menu$data)
    
    # if (input$build_menu > 0 & (nrow(test_mr_compliance(menu$data) == 0))) {
    #   return()
    # } else {
    #   return(test_mr_compliance(menu$data))
    # }
  })
  
  # Positive compliance
  output$pos_compliance <- DT::renderDataTable({
    if (input$build_menu == 0)
      return()
    
    test_pos_compliance(menu$data)
    
    # if (nrow(test_pos_compliance(menu$data) == 0)) {
    #   return()
    # }
  })
  
  output$diffs <- DT::renderDataTable({
    diffs$data 
  })
  
  # ------------- Diffs ---------------
  
  diffs <- reactiveValues(data = NULL)

  observeEvent(input$see_diffs, {
    diffs$data <- see_diffs(menu$data, master_menu$data)
  })

  # Render data table
  output$diffs <- DT::renderDataTable({
    diffs$data 
  })
  
  
})
