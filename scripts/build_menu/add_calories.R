# ---------------- Add Calories -------------

# swapping in a single serving size of a given food for another might have put us below the minimum calorie requirement of 2300. If our
# menu's total calories are too low, increase them by adding one serving of a random food from our database to the menu

add_calories <- function(orig_menu) {
  orig_menu <- orig_menu %>% drop_na_(all_nut_and_mr_df$nutrient) %>%  filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) 
  df <- abbrev %>% drop_na_(all_nut_and_mr_df$nutrient) %>%  filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need
  
  i <- sample(nrow(df), 1) # sample a random row from df and save its index in i  
  
  cals <- sum((orig_menu$Energ_Kcal * orig_menu$GmWt_1), na.rm = TRUE)/100   # set calories to our current number of calories
  
  while (cals < 2300) {
    this_food_cal <- (df$Energ_Kcal[i] * df$GmWt_1[i])/100    # get the number of calories in 1 serving of this food (see N = (V*W)/100 formula)
    cals <- cals + this_food_cal    # add the calories in row of index i to the calorie sum variable
    
    menu <- rbind(menu, df[i,])   # add that row to our menu
    
    i <- sample(nrow(df), 1)   # resample a new index
  }
  menu    # return the full menu
}
