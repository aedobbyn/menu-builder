# Take a solution (a list resulting from solve_it()) and 
# return a menu with the solution column cbound as well as a helpful message
solve_menu <- function(sol, v_v_verbose = TRUE) {
  # browser()
  
  solved_col <-  list(solution_amounts = sol$solution) %>% as_tibble()    # Grab the vector of solution amounts
  
  if (! "solution_amounts" %in% names(sol$original_menu_per_g)) {
    df_solved <- sol$original_menu_per_g %>% 
      bind_cols(solved_col) %>%            # cbind that to the original menu
      select(shorter_desc, solution_amounts, GmWt_1, serving_gmwt, everything()) %>% 
      mutate(
        GmWt_1 = GmWt_1 * solution_amounts,
        cost = cost * solution_amounts
      ) 
  } else {
    df_solved <- sol$original_menu_per_g %>% 
      select(shorter_desc, GmWt_1, serving_gmwt, everything()) %>% 
      mutate(
        solution_amounts = solved_col %>% as_vector(),    # If we've already got a solution amounts column, replace the old one with the new
        GmWt_1 = GmWt_1 * solution_amounts,
        cost = cost * solution_amounts
      ) 
  }
  
  max_food <- df_solved %>%                                   # Find what the most of any one food we've got is
    filter(solution_amounts == max(df_solved$solution_amounts)) %>% 
    slice(1:1)                                           # If we've got multiple maxes, take only the first
  
  if (v_v_verbose == TRUE) {
    message(paste0("We've got a lot of ", max_food$shorter_desc %>% as_vector()), ". ",
            max_food$solution_amounts %>% round(digits = 2), " servings of ",
            max_food$shorter_desc %>% as_vector() %>% is_plural(return_bool = FALSE), ".")  
  }
  
  return(df_solved)
}
