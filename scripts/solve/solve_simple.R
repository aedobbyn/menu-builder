
solve_simple <- function(menu, seed = 15, min_food_amount = 1, percent_to_swap = 0.5,
                       verbose = TRUE, time_out_count = 50, return_menu = TRUE) {
  counter <- 0
  
  while (test_all_compliance(menu) == "Not Compliant") {
    if (verbose == TRUE) { 
      message("No solution found -- menu not currently compliant") 
      message(paste0("Uncomplinat here: ", test_all_compliance_verbose(menu))) }
    
    if (counter == 0) {
      menu <- menu %>% solve_it(nutrient_df, min_food_amount = min_food_amount) %>% solve_menu()
      
      counter <- counter + 1
      
    } else if (counter == time_out_count) {
      if (verbose == TRUE) { message("Time out; returning menu as is") }
      if (return_menu == TRUE) {
        return(menu)
      }  else {
        return(counter)
      }
      
    } else if (nrow(test_mr_compliance(menu)) || nrow(test_pos_compliance(menu)) > 0) {
      if (verbose == TRUE) { message("Doing a single swap on all must restricts") }
      counter <- counter + 1
      
      menu <- menu %>% 
        do_single_swap() %>% 
        # wholesale_swap(df = abbrev, percent_to_swap = percent_to_swap) %>%
        solve_it(nutrient_df, min_food_amount = min_food_amount) %>% solve_menu()
      
    } else if (test_calories(menu) == "Calories too low") {
      if (verbose == TRUE) { message("Calories too low; adjusting portions sizes") }
      counter <- counter + 1
      
      menu <- menu %>% add_calories() %>% solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        solve_menu()
    }
  }
  
  message(paste0("Final compliance: ", test_all_compliance(menu)))
  
  if (return_menu == TRUE) {
    return(menu)
  }  else {
    return(counter)
  }
}

