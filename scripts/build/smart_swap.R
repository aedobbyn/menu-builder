# While loop for doing swapping
# if we reduce the original corpus of foods down to foods that are lower than x standard deviations below the mean on a given must_restrict
# and we're left with an empty dataframe, trying to replace the max offender with an empty dataframe will throw an error
# if we do get an error in trycatch, then replace the max offender with a random food
# otherwise, go ahead with replacing it with a better one

smart_swap <- function(df, cutoff = 0.5) {
  
  while(nrow(test_mr_compliance(df)) > 0) {
    
    for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
      nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
      message(paste0("------- The nutrient we're restricting is ", nut_to_restrict, ". It has to be below ", mr_df$value[m]))
      to_restrict <- (sum(df[[nut_to_restrict]] * df$GmWt_1, na.rm = TRUE))/100   # get the amount of that must restrict nutrient in our original menu
      message(paste0("The original total value of that nutrient in our menu is ", to_restrict))
      
      while (to_restrict > mr_df$value[m]) {     # if the amount of the must restrict in our current menu is above the max value it should be according to mr_df
        max_offender <- which(df[[nut_to_restrict]] == max(df[[nut_to_restrict]]))   # get index of food that's the worst offender in this respect
        
        message(paste0("The worst offender in this respect is ", df[max_offender, ]$Shrt_Desc))
        
        # ------- smart swap or randomly swap in a food here --------
        df[max_offender, ] <- replace_food_w_better(df, max_offender, nut_to_restrict, cutoff = cutoff)
        
        to_restrict <- (sum(df[[nut_to_restrict]] * df$GmWt_1, na.rm = TRUE))/100   # recalculate the must restrict nutrient content
        message(paste0("Our new value of this must restrict is ", to_restrict))
      }
    }
  }
  return(df)
}