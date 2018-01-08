
# source("./scripts/score/score_menu.R")
ranked_foods <- write_feather("./data/ranked_foods.feather")

# ------------- Initial Builder ---------------

# Build a daily menu from scratch by sampling one serving of a food at random from our dataframe 
# until we're at or over 2300 calories
# If we want to start building from a base of higher-scored foods, we can set from_better_cutoff to a z-score > 0

build_menu <- function(df, seed = NULL, from_better_cutoff = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  # browser()
  
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
    stop("No foods at this cutoff; try a lower cutoff.")
  }
    
  df <- df %>% drop_na_(all_nut_and_mr_df$nutrient) %>% 
    filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need 
  
  
  food_i <- df %>% filter(!NDB_No %in% menu$NDB_No) %>% sample_n(1) # sample a random row from df and save its index in i

  cals <- 0   # set the builder variables to 0
  menu <- NULL
  
  while (cals < 2300) {
    df <- df %>% filter(!NDB_No %in% menu$NDB_No)
    
    if (nrow(df) == 0) {
      message("No more elligible foods to sample from. Returning menu too low in calories.")
      return(menu)
    } else {
      food_i <- df %>% sample_n(1) # resample a new index from a food that doesn't already exist in our menu
    }
    
    this_food_cal <- (food_i$Energ_Kcal * food_i$GmWt_1)/100    # get the number of calories in 1 serving of this food (see N = (V*W)/100 formula)
    cals <- cals + this_food_cal    # add the calories in row of index i to the calorie sum variable
    
    menu <- bind_rows(menu, food_i)   # add that row to our menu
  }
  menu    # return the full menu
}


# Make sure from_better_cutoff can't be character
expect_error(build_menu(abbrev, from_better_cutoff = "foo"))

# Scale on the way
x <- build_menu(abbrev, seed = 15, from_better_cutoff = 1)
# Scaled score should be greater than or equal to the cutoff we set 
expect_gte(x %>% summarise(mean_score = mean(scaled_score)) %>% as_vector(),
           1)
# Change ranks to scaled wrt this particular menu, so mean scaled score should be 0
y <- x %>% add_ranked_foods()
expect_lt(y %>% summarise(mean_score = mean(scaled_score)) %>% as_vector(),
           1)


