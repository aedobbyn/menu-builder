
# ---- Smart swap a single food for each nutrient
# Same as smart_swap() without the while loops

smart_swap_single <- function(orig_menu, df = abbrev, cutoff = 0.5, verbose = FALSE) {
  
  if ("shorter_desc" %in% names(orig_menu)) {
    df <- df %>% do_menu_mutates()
  }
  
  swap_count <- 0

    for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
      nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
      message(paste0("------- The nutrient we're restricting is ", nut_to_restrict, ". It has to be below ", mr_df$value[m])) 
      to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # get the amount of that must restrict nutrient in our original menu
      message(paste0("The original total value of that nutrient in our menu is ", to_restrict)) 
      
      if (to_restrict > mr_df$value[m]) {     # if the amount of the must restrict in our current menu is above the max value it should be according to mr_df
        swap_count <- swap_count + 1
        
        max_offender <- which(orig_menu[[nut_to_restrict]] == max(orig_menu[[nut_to_restrict]]))   # get index of food that's the worst offender in this respect
        
        message(paste0("The worst offender in this respect is ", orig_menu[max_offender, ]$Shrt_Desc))
        
        # ------- smart swap or randomly swap in a food here --------
        orig_menu[max_offender, ] <- replace_food_w_better(orig_menu, df, max_offender, nut_to_restrict, cutoff = cutoff)
        
        to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # recalculate the must restrict nutrient content
        message(paste0("Our new value of this must restrict is ", to_restrict)) 
      } else {
        message("We're all good on this nutrient.") 
      }
    }
  
  if (verbose == TRUE) {
    print(paste0(swap_count, " swaps were completed."))
  }
  
  return(orig_menu)
}


quo_solved_names <- names(solved_menu)
name_overlap <- intersect(names(menu), names(solved_menu))
no_overlap <- setdiff(names(solved_menu), names(menu))


# Originally this was meant to only be passed a solved menu. We're getting old names from menu
# Make old and new dataframes play nicely when swapping
do_single_swap <- function(menu, solve_if_unsolved = TRUE, verbose = FALSE,
                        new_solution_amount = 1){  # What should the solution amount of the newly swapped in foods be?
  
  if (solve_if_unsolved == TRUE) {
    menu <- menu %>% do_menu_mutates() %>% solve_it() %>% solve_menu()
  }
  
  if (verbose == FALSE) {
    out <- suppressWarnings(suppressMessages(menu[, c(name_overlap)] %>% 
      smart_swap_single())) 
  } else {
    out <- menu[, c(name_overlap)] %>% 
      smart_swap_single() 
  }
  
  if (all(no_overlap %in% names(menu))) {
    out <- out %>% 
      mutate(
        serving_gmwt = menu$serving_gmwt,
        shorter_desc = map_chr(Shrt_Desc, grab_first_word, splitter = ","), # Recreate shorter_desc
        cost = runif(nrow(.), min = 1, max = 10) %>% round(digits = 2),    # Add in some costs
        solution_amounts = ifelse(Shrt_Desc %in% menu$Shrt_Desc, 
                                  menu$solution_amounts, new_solution_amount)
      ) %>%
      select(!!quo_solved_names) 
  }
  return(out)
}
  
  

