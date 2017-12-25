
# Smart swap a single food
smart_swap_single <- function(orig_menu, cutoff = 0.5) {
  
  # while(nrow(test_mr_compliance(orig_menu)) > 0) {
    
    for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
      nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
      print(paste0("------- The nutrient we're restricting is ", nut_to_restrict, ". It has to be below ", mr_df$value[m]))
      to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # get the amount of that must restrict nutrient in our original menu
      print(paste0("The original total value of that nutrient in our menu is ", to_restrict))
      
      while (to_restrict > mr_df$value[m]) {     # if the amount of the must restrict in our current menu is above the max value it should be according to mr_df
        max_offender <- which(orig_menu[[nut_to_restrict]] == max(orig_menu[[nut_to_restrict]]))   # get index of food that's the worst offender in this respect
        
        print(paste0("The worst offender in this respect is ", orig_menu[max_offender, ]$Shrt_Desc))
        
        # ------- smart swap or randomly swap in a food here --------
        orig_menu[max_offender, ] <- replace_food_w_better(orig_menu, max_offender, nut_to_restrict, cutoff = cutoff)
        
        to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # recalculate the must restrict nutrient content
        print(paste0("Our new value of this must restrict is ", to_restrict))
      }
    }
  # }
  orig_menu
}