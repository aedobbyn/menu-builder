

# -------- Solve and swap if needed --------
# Test compliance; if we're above on some must_restricts, do a single swap and then solve
# If we're below on nutrients or calories, run the solver
# Every tenth iteraiton, run a wholesale swap
# If we can't get to compliance after 50 iterations, give up and return what we've got

solve_full <- function(menu, seed = 15, min_food_amount = 1, percent_to_swap = 0.5,
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
      
    } else if (counter > 0 && counter %% 10 == 0) {    # Every 10, do a wholesale swap
      if (verbose == TRUE) { message(" *** Running a wholesale swap. *** ") }
      counter <- counter + 1
      
      menu <- menu %>% solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        solve_menu() %>% 
        wholesale_swap(df = abbrev, percent_to_swap = percent_to_swap) %>% 
        solve_it(nutrient_df, min_food_amount = min_food_amount) %>% solve_menu()
      
    } else if (nrow(test_mr_compliance(menu)) > 0) {
      if (verbose == TRUE) { message("Doing a single swap on all must restricts") }
      counter <- counter + 1
      
      menu <- menu %>% 
        do_single_swap(verbose = verbose) %>%
        solve_it(nutrient_df, min_food_amount = min_food_amount) %>% solve_menu()
      
    } else if (nrow(test_pos_compliance(menu)) > 0) {
      if (verbose == TRUE) { message("Nutrients uncompliant; adjusting portions sizes") }
      counter <- counter + 1
      
      menu <- menu %>% 
        solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        solve_menu()
      
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

