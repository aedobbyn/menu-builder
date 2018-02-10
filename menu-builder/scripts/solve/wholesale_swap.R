
get_swap_candidates <- function(menu, df = abbrev, size_to_swap) {
  candidate <- df %>% 
    drop_na_(all_nut_and_mr_df$nutrient) %>% 
    filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) %>% 
    filter(! (NDB_No %in% menu$NDB_No)) %>%    # We can't swap in a food that already exists in our menu
    sample_n(., size = size_to_swap) %>% 
    mutate(solution_amounts = 1)    # Give us one serving of each of these new foods
  return(candidate)
}

wholesale_swap <- function(menu, df = abbrev, percent_to_swap = 0.5) {
  
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
  size_to_swap <- nrow(to_swap_out)
  
  newly_swapped_in <- get_swap_candidates(menu, abbrev, size_to_swap)
  
  if(any(newly_swapped_in$NDB_No %in% menu$NDB_No)){ stop ("Swapping in food we already have :/") }
  
  # If it's not good enough, resample once
  if (score_menu(newly_swapped_in) < score_menu(to_swap_out)) {
    message("Swap candidate not good enough; reswapping.")
    newly_swapped_in <- get_swap_candidates(menu = menu, df = abbrev, size_to_swap = size_to_swap)
    
  } else {
    message("Swap candidate is good enough. Doing the wholesale swap.")
  }
  
  message(paste0("Replacing with: ", 
                 str_c(newly_swapped_in$shorter_desc, collapse = ", ")))
  
  out <- menu %>% 
    filter(!NDB_No %in% worst_foods) %>% 
    bind_rows(newly_swapped_in)
  
  return(out)
}



