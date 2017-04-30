

# we're going to manipulate the weights of foods, which has calorie implications. we want our calorie count to stay the same but our menu
# to become more nutritious.
# for each positive nutrient, find the food that is the best contributor to our menu in that respect, per gram
# increase the weight of that food by 10% 
# find out how many calories that increased our menu by
# then find the food that contributes the most calories to the meal (and that also isn't the food we're increasing for its nutritional content)
# decrease the weight of that calorie-heavy food in an amount equal to the calorie increase we had due to our max pos
adjust_portion_sizes_and_square_calories <- function(orig_menu) {
  orig_menu <- orig_menu %>% drop_na_(pos_df$positive_nut) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  
  
  while(length(test_pos_compliance(orig_menu)) > 0) {
    
    for (p in seq_along(pos_df$positive_nut)) {    # for each row in the df of positives
      nut_to_augment <- pos_df$positive_nut[p]    # grab the name of the nutrient we're examining
      print(paste0("------- The nutrient we're considering is ", nut_to_augment, ". It has to be above ", pos_df$value[p]))
      
      val_nut_to_augment <- (sum(orig_menu[[nut_to_augment]] * orig_menu$GmWt_1))/100   # get the total amount of that nutrient in our original menu
      print(paste0("The original total value of that nutrient in our menu is ", val_nut_to_augment))
      
      
      while (val_nut_to_augment < pos_df$value[p]) {     # if the amount of the must restrict in our current menu is below the min daily value it should be according to pos_df
        
        # Find the max_pos and its starting calorie count
        max_pos <- which(orig_menu[[nut_to_augment]] == max(orig_menu[[nut_to_augment]]))   # get index of food that's the best in this respect
        max_pos_starting_cals <- (orig_menu[max_pos, ]$Energ_Kcal * orig_menu[max_pos, ]$GmWt_1)/100
        print(paste0("The best food in this respect is ", orig_menu[max_pos, ]$Shrt_Desc, ". It contributes ", max_pos_starting_cals, " calories."))
        
        # Augment max_pos's weight by 10%
        new_gmwt <- (orig_menu[max_pos, ]$GmWt_1) * 1.1 # augment by 10%
        orig_menu[max_pos, ]$GmWt_1 <- new_gmwt   # replace the value with the augmented one
        
        # Find how much we increased max_pos's calorie count by
        max_pos_new_cals <- (orig_menu[max_pos, ]$Energ_Kcal * new_gmwt)/100   # get the amount that we increased our menu's calories by in augmenting the max_pos
        print(paste0("After an increase of 10% weight the calories contributed by our max positive are ", max_pos_new_cals, " calories."))
        cal_diff <- max_pos_new_cals - max_pos_starting_cals
        
        # Find the newly augmented nutrient value to see if we need to continue the loop
        val_nut_to_augment <- (sum(orig_menu[[nut_to_augment]] * orig_menu$GmWt_1))/100   # save the new value of the nutrient
        print(paste0("Our new value of this nutrient is ", val_nut_to_augment))
        
        # --------------
        
        # Find the max_cals and its calorie count
        food_w_max_cals <- which(orig_menu[-max_pos, ]$Energ_Kcal == max(orig_menu[-max_pos, ]$Energ_Kcal))   # what is the index of the food that isn't our max_pos is currently most calorie dense?
        cals_of_food_w_max_cals <- (orig_menu[-max_pos, ]$Energ_Kcal[food_w_max_cals] * orig_menu[-max_pos, ]$GmWt_1[food_w_max_cals])/100
        print(paste0("The food with the most calories that isn't our max positive is  ", orig_menu[-max_pos, ]$Shrt_Desc[food_w_max_cals], " at ", (orig_menu[-max_pos, ]$Energ_Kcal[food_w_max_cals] * orig_menu[-max_pos, ]$GmWt_1[food_w_max_cals])/100))
        
        # Find what the new calorie count and weight of max_cals needs to be
        max_cals_new_cals_need_to_be <- cals_of_food_w_max_cals - cal_diff
        print(paste0("We've reduced the calories of the food with the most calories to  ", max_cals_new_cals_need_to_be))
        max_cals_new_weight_needs_to_be <- max_cals_new_cals_need_to_be*100 / menu[-max_pos, ]$Energ_Kcal[food_w_max_cals]
        
        # Decrement max_cal's weight by the amount it needs to be decreased by
        orig_menu[food_w_max_cals, ]$GmWt_1 <- max_cals_new_weight_needs_to_be
        print(paste0("We've reduced the weight of the food with the most calories to  ", orig_menu[food_w_max_cals, ]$GmWt_1))
      }
    }
  }
  orig_menu
}

more_nutritious <- adjust_portion_sizes(menu)
more_nutritious
View(more_nutritious)