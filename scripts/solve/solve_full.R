

# -------- Solve and swap if needed --------
# Test compliance; if we're above on some must_restricts, do a single swap
# If we're below on nutrients or calories, run the solver

solve_full <- function(menu, seed = 15, min_food_amount = 1, percent_to_swap = 0.5,
                           silent = FALSE) {
  # browser()
  counter <- 0
  
  while (test_all_compliance(menu) == "Not Compliant") {
    message("No solution found -- menu not currently compliant")
    
    print(test_all_compliance_verbose(menu))
    
    if (counter == 50) {
      message("Time out; returning menu as is")
      return(menu)
      
    } else if (counter > 0 && counter %% 10 == 0) {    # Every 10, do a wholesale swap
      message(" *** Running a wholesale swap. *** ")
      counter <- counter + 1
      
      menu <- menu %>% solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        solve_menu() %>% 
        wholesale_swap(df = abbrev, percent_to_swap = percent_to_swap)
      
    } else if (nrow(test_mr_compliance(menu)) > 0) {
      message("Doing a single swap on all must restricts")
      counter <- counter + 1
      
      menu <- menu %>% 
        # solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        # solve_menu() %>% 
        # wholesale_swap(df = abbrev, percent_to_swap = percent_to_swap)
        do_single_swap(silent = silent)
      
    } else if (nrow(test_pos_compliance(menu)) > 0) {
      message("Nutrients uncompliant; adjusting portions sizes")
      counter <- counter + 1
      
      menu <- menu %>% solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        solve_menu()
      
    } else if (test_calories(menu) == "Calories too low") {
      message("Calories too low; adjusting portions sizes")
      counter <- counter + 1
      
      menu <- menu %>% solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        solve_menu()
    }
  }
  
  message(paste0("Final compliance: ", test_all_compliance(menu)))
  return(menu)
}

solve_full(solved_menu)

# Test that our min solution amount gets carried through 
x <- build_menu(abbrev, seed = 9) %>% 
  do_menu_mutates() %>% 
  solve_it(nutrient_df, min_food_amount = 0.5) %>% solve_menu() %>%
  solve_full(min_food_amount = 0.5, percent_to_swap = 1) 

expect_equal(min(x$solution_amounts), 0.5)

# Test that we're not touching menus that are already compliant
expect_equal(solve_full(out), out)

