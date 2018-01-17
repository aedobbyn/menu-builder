

wholesale_swap <- function(menu, df = abbrev, percent_to_swap = 0.5) {
  
  # browser()
  
  # Get foods with the lowest solution amounts -- might think about using lowest scores instead
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
  
  get_swap_candidates <- function(df, to_swap_out) {
    swap_candidate <- df %>% 
      filter(! (NDB_No %in% menu)) %>%    # We can't swap in a food that already exists in our menu
      sample_n(., size = nrow(to_swap_out)) %>% 
      do_menu_mutates() %>% 
      mutate(solution_amounts = 1)    # Give us one serving of each of these new foods
    
    if (score_menu(swap_candidate) < score_menu(to_swap_out)) {
      message("Swap candidate not good enough; reswapping.")
      swap_candidate <- sample_n(df, size = nrow(to_swap_out)) %>% 
        do_menu_mutates() %>% 
        mutate(solution_amounts = 1)
    } else {
        message("Swap candidate is good enough. Doing the wholesale swap.")
        return(swap_candidate)
    }
  }
  
  newly_swapped_in <- get_swap_candidates(df, to_swap_out)
  
  message(paste0("Replacing with: ", 
                 str_c(newly_swapped_in$shorter_desc, collapse = ", ")))
  
  out <- menu %>% 
    filter(!NDB_No %in% worst_foods) %>% 
    bind_rows(newly_swapped_in)
  
  return(out)
}

