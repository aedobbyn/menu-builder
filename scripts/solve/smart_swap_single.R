# 
# source("./scripts/solve/square_names.R")

# ---- Smart swap a single food for each nutrient
# Same as smart_swap() without the while loops

smart_swap_single <- function(menu, max_offender, cutoff = 0.5, df = abbrev, verbose = FALSE) {
  
  swap_count <- 0

    for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
      nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
      message(paste0("------- The nutrient we're restricting is ", nut_to_restrict, ". It has to be below ", mr_df$value[m])) 
      to_restrict <- (sum(menu[[nut_to_restrict]] * menu$GmWt_1, na.rm = TRUE))/100   # get the amount of that must restrict nutrient in our original menu
      message(paste0("The original total value of that nutrient in our menu is ", to_restrict)) 
      
      if (to_restrict > mr_df$value[m]) {     # if the amount of the must restrict in our current menu is above the max value it should be according to mr_df
        swap_count <- swap_count + 1
        
        max_offender <- which(menu[[nut_to_restrict]] == max(menu[[nut_to_restrict]]))   # Find the food that's the worst offender in this respect
        
        message(paste0("The worst offender in this respect is ", menu[max_offender, ]$Shrt_Desc))
        
        # ------- Use replace_food_w_better() to smart swap or randomly swap in a food here --------
        menu[max_offender, ] <- replace_food_w_better(menu, max_offender, 
                                                           nutrient_to_restrict = nut_to_restrict, cutoff = cutoff)
        
        to_restrict <- (sum(menu[[nut_to_restrict]] * menu$GmWt_1, na.rm = TRUE))/100   # recalculate the must restrict nutrient content
        message(paste0("Our new value of this must restrict is ", to_restrict)) 
      } else {
        message("We're all good on this nutrient.") 
      }
    }
  
  if (verbose == TRUE) {
    print(paste0(swap_count, " swaps were completed."))
  }
  
  return(menu)
}



# Originally this was meant to only be passed a solved menu. We're getting names from "./data/derived/square_names.R"
# Make old and new dataframes play nicely when swapping
do_single_swap <- function(menu, solve_if_unsolved = TRUE, verbose = FALSE,
                        new_solution_amount = 1){  # What should the solution amount of the newly swapped in foods be?
  
  if (verbose == FALSE) {
    out <- suppressWarnings(suppressMessages(menu %>% 
      smart_swap_single(menu))) 
  } else {
    out <- menu
      smart_swap_single(menu) 
  }

  return(out)
}
  
  

