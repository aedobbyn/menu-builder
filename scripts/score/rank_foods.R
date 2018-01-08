# ------------- Score individual foods -----------
# How "healthy" is a food overall? We use the score_menu function on a single food or a vector of foods and
# return a vector of their ranks that we can cbind to the menu

rank_foods <- function(this_menu) {
  food_ranks <- vector()
  for (i in 1:nrow(this_menu)) {
    this_food_rank <- score_menu(this_menu[i, ])
    food_ranks <- c(food_ranks, this_food_rank)
  }
  return(food_ranks)
}

# A random sample of 20 foods
samp <- sample_n(abbrev_sans_na, 20)
sample_foods_ranked <- cbind(name = samp$Shrt_Desc, 
                             score = as.numeric(rank_foods(samp)))

z_score <- function(vec) {
  vec_mean <- mean(vec)
  vec_sd <- sd(vec)
  
  get_score <- function(e) {
    z <- (e - vec_mean) / vec_sd
  }
  
  vec_z <- vec %>% map_dbl(get_score)
  return(vec_z)
}


# Arrange all foods in our db by their rank, from best to worst
ranked_foods <- cbind(abbrev_sans_na, score = rank_foods(abbrev_sans_na)) %>% 
  mutate(
    scaled_score = z_score(score)    # scale
  ) %>% 
  arrange(desc(score)) %>% 
  as_tibble()

# write_feather(ranked_foods, "./data/ranked_foods.feather")