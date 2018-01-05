

# -------- Solve and swap if needed --------
# Test compliance; if we're above on some must_restricts, do a single swap
# If we're below on nutrients or calories, run the solver

solve_full <- function(df, seed = 15, min_food_amount = 1, percent_to_swap = 0.5,
                           silent = FALSE) {
  browser()
  counter <- 0
  
  menu <- build_menu(df, seed = seed) %>% 
    do_menu_mutates() %>% 
    solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
    solve_menu()
  
  while (test_all_compliance(menu) == "Not Compliant") {
    message("No solution found -- menu not currently compliant")
    
    print(test_all_compliance_verbose(menu))
    
    if (counter %% 10 == 0) {
      message(" *** Running a wholesale swap. *** ")
      menu <- menu %>% wholesale_swap(df = abbrev, percent_to_swap = percent_to_swap)
    } else if (nrow(test_mr_compliance(menu)) > 0) {
      message("Doing a single swap on all must restricts")
      counter <- counter + 1
      
      menu <- menu %>% 
        do_single_swap(silent = silent)
      
    } else if (nrow(test_pos_compliance(menu)) > 0) {
      message("Adjusting portions sizes")
      counter <- counter + 1
      
      menu <- menu %>% solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        solve_menu()
      
    } else if (test_calories(menu) == "Calories too low") {
      message("Calories too low")
      counter <- counter + 1
      
      menu <- menu %>% solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        solve_menu()
      
    } else {
      message("Menu compliant")
    }
  }
  message(paste0("Final compliance: ", test_all_compliance(menu)))
  return(menu)
}

solve_full(out)

