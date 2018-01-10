# ---------------- Add Calories -------------
# *** Refactored inside of build_menu, so this is deprecated ***

# Swapping in a single serving size of a given food for another might have put us below the minimum calorie 
# requirement of 2300. If our menu's total calories are too low, increase them by adding one serving of a 
# random food from our database to the menu

add_calories <- function(menu = NULL, df = abbrev, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  df <- df %>% drop_na_(all_nut_and_mr_df$nutrient) %>% 
    filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need 
  
  # browser()
  
  if (! is.null(menu)) {
    menu <- menu %>% drop_na_(all_nut_and_mr_df$nutrient) %>%  filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) 
    cals <- sum((menu$Energ_Kcal * menu$GmWt_1), na.rm = TRUE)/100   # set calories to our current number of calories
  } else {
    cals <- 0   # set the builder variables to 0
    menu <- NULL
  }
  
  while (cals < 2300) {
    df <- df %>% filter(!NDB_No %in% menu$NDB_No)
    
    if (nrow(df) == 0) {
      message("No more elligible foods to sample from. Returning menu too low in calories.")
      return(menu)
    } else {
      food_i <- df %>% filter(!(NDB_No %in% menu$NDB_No)) %>% 
        sample_n(1) # resample a new index from a food that doesn't already exist in our menu
    }
    
    this_food_cal <- (food_i$Energ_Kcal * food_i$GmWt_1)/100    # get the number of calories in 1 serving of this food (see N = (V*W)/100 formula)
    cals <- cals + this_food_cal    # add the calories in row of index i to the calorie sum variable
    
    menu <- bind_rows(menu, food_i)   # add that row to our menu
  }
  return(menu)    # return the full menu
}

menu_too_low <- build_menu(abbrev) %>% smart_swap()
test_calories(menu_too_low)
menu_too_low %>% add_calories() %>% test_calories


# Make sure we have no dupes
expect_equal(add_calories(seed = 4) %>% select(NDB_No) %>% count(), 
             add_calories(seed = 4) %>% nrow())



