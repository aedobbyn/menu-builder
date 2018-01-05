



# -------- Solve and swap if needed --------
# Test compliance; if we're above on some must_restricts, do a single swap
# If we're below on nutrients, run the solver
solve_and_swap <- function(df, seed = 15, min_food_amount = 1) {
  menu <- build_menu(df, seed = seed) %>% 
    do_menu_mutates() %>% 
    solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
    solve_menu()
  
  if (test_all_compliance(menu) == "Not Compliant") {
    message("No solution found -- menu not currently compliant")
    
    print(test_all_compliance_verbose(menu))
    
    if (nrow(test_mr_compliance(menu)) > 0) {
      message("Doing a single swap on all must restricts")
      menu <- menu %>% 
        do_single_swap(silent = TRUE)
      
    } else if (nrow(test_pos_compliance(menu)) > 0) {
      message("Adjusting portions sizes")
      menu <- menu %>% solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        solve_menu()
      
    } else if (test_calories(menu) == "Calories too low") {
      message("Calories too low")
      
      menu <- menu %>% solve_it(nutrient_df, min_food_amount = min_food_amount) %>% 
        solve_menu()
      
    } else {
      message("Menu compliant")
    }
  }
  message(paste0("Final compliance: ", test_all_compliance(menu)))
  return(menu)
}

solve_and_swap(abbrev)



wholesale_swap <- function(menu, df = abbrev, percent_to_swap = 0.5) {
  
  min_solution_amount <- min(menu$solution_amounts)
  worst_foods <- menu %>% 
    filter(solution_amounts == min_solution_amount)
  
  if (nrow(worst_foods) >= 2) {
    to_swap_out <- worst_foods %>% sample_frac(percent_to_swap)
    message(paste0("Swapping out a random ", percent_to_swap*100, "% of foods: ", 
                   str_c(to_swap_out$shorter_desc, collapse = ", ")))
    
  } else if (nrow(worst_foods) == 1)  {
    message("Only one worst food. Swapping this guy out.")
    to_swap_out <- worst_foods
    
  } else {
    message("No worst foods")
  }
  
  newly_swapped_in <- sample_n(df, size = nrow(to_swap_out)) %>% 
    do_menu_mutates() %>% 
    mutate(solution_amounts = 1)    # Give us one serving of each of these new foods
  
  message(paste0("Replacing with: ", 
                 str_c(newly_swapped_in$shorter_desc, collapse = ", ")))
  
  out <- out %>% 
    filter(!NDB_No %in% worst_foods) %>% 
    bind_rows(newly_swapped_in)
  
  return(out)
}
   
wholesale_swap(out)

