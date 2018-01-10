# ------------- Score individual foods -----------
# How "healthy" is a food overall? We use the score_menu function on a single food or a vector of foods and
# return a vector of their ranks that we can cbind to the menu

rank_foods <- function(df) {
  food_ranks <- vector()
  for (i in 1:nrow(df)) {
    this_food_rank <- score_menu(df[i, ])
    food_ranks <- c(food_ranks, this_food_rank)
  }
  return(food_ranks)
}


# Arrange all foods in our db by their rank, from best to worst
add_ranked_foods <- function(df, verbose = TRUE) {
  if(!("score" %in% names(df))) { 
    if (verbose == TRUE) {
      message("score column doesn't exist; creating it") 
    }
    df <- df %>% 
      mutate(
        score = rank_foods(df)   # map_dfr(score_menu)
      )
  }
  
  if (verbose == TRUE) {
    if ("scaled_score" %in% names(df)) { 
      message("scaled_score column already exists; replacing it") 
    } else {
      message("scaled_score doesn't exist; creating it")
    }
  } 
  
  df <- df %>% 
    mutate(
      scaled_score = z_score(score)
    )
  
  return(df)
}

# ranked_foods <- add_ranked_foods(abbrev_sans_na)
# write_feather(ranked_foods, "./data/ranked_foods.feather")

