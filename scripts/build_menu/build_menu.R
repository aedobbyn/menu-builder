
# ------------- Initial Builder ---------------

# Build a daily menu from scratch by sampling one serving of a food at random from our dataframe 
# until we're at or over 2300 calories


build_menu <- function(df, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  df <- df %>% drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need
  i <- sample(nrow(df), 1) # sample a random row from df and save its index in i
  
  cals <- 0   # set the builder variables to 0
  menu <- NULL
  
  while (cals < 2300) {
    this_food_cal <- (df$Energ_Kcal[i] * df$GmWt_1[i])/100    # get the number of calories in 1 serving of this food (see N = (V*W)/100 formula)
    cals <- cals + this_food_cal    # add the calories in row of index i to the calorie sum variable
    
    menu <- rbind(menu, df[i,])   # add that row to our menu
    
    i <- sample(nrow(df), 1)   # resample a new index
  }
  menu    # return the full menu
}

menu <- build_menu(abbrev, seed = 9)