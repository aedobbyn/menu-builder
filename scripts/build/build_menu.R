
source("./scripts/score/score_menu.R")
source("./scripts/build/add_calories.R")
# ranked_foods <- read_feather("./data/ranked_foods.feather")

# ------------- Initial Builder ---------------

# Build a daily menu from scratch by sampling one serving of a food at random from our dataframe 
# until we're at or over 2300 calories
# If we want to start building from a base of higher-scored foods, we can set from_better_cutoff to a z-score > 0

build_menu <- function(df = abbrev, menu = NULL, seed = NULL, from_better_cutoff = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  df <- df %>% drop_na_(all_nut_and_mr_df$nutrient) %>% 
    filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need 
  
  # Optionally choose a floor for what the z-score of each food to build from should be
  if (!is.null(from_better_cutoff)) {
    assert_that(is.numeric(from_better_cutoff), msg = "from_better_cutoff must be numeric or NULL")
    if (! "scaled_score" %in% names(df)) {
      df <- df %>% 
        add_ranked_foods()
    }
    df <- df %>% 
      filter(scaled_score > from_better_cutoff) # filter(NDB_No %in% ranked_foods[which(ranked_foods$scaled_score >= from_better_cutoff), ]$NDB_No)
  }
  
  if (nrow(df) == 0) {
    stop("No foods to speak of; you might try a lower cutoff.")
  }
  
  # if (! is.null(menu)) {
  #   menu <- menu %>% drop_na_(all_nut_and_mr_df$nutrient) %>%  filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  #   cals <- sum((menu$Energ_Kcal * menu$GmWt_1), na.rm = TRUE)/100   # set calories to our current number of calories
  # } else {
  #   cals <- 0   # set the builder variables to 0
  #   menu <- NULL
  # }
  # 
  # while (cals < 2300) {
  #   df <- df %>% filter(!NDB_No %in% menu$NDB_No)
  # 
  #   if (nrow(df) == 0) {
  #     message("No more elligible foods to sample from. Returning menu too low in calories.")
  #     return(menu)
  #   } else {
  #     food_i <- df %>%
  #       sample_n(1) # resample a new index from a food that doesn't already exist in our menu
  #   }
  # 
  #   this_food_cal <- (food_i$Energ_Kcal * food_i$GmWt_1)/100    # get the number of calories in 1 serving of this food (see N = (V*W)/100 formula)
  #   cals <- cals + this_food_cal    # add the calories in row of index i to the calorie sum variable
  # 
  #   menu <- bind_rows(menu, food_i)   # add that row to our menu
  # }
  
  menu <- add_calories(menu = menu, df = df)
  
  return(menu)
}


