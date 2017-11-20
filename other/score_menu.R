
source("./menu_builder.R")

# ------------ Score menus on how nutritional they are
# - - - more positive scores are always better - - -
# 1) on positive nutrients, you can't get a better score than 0
# 2) on must_restricts, a positive score means you're below the daily maximum on some must_restricts, which is good. 
    # a negative score means you're above the maximum on some must_restricts, which is bad.
# 3) the overall score adds these two together


# -------------------- Positive Nutrients ----------------
# no extra credit for going above the daily min. best score is 0, worst score is negative infinity.
# max score is 0, min score is -infinity

# a positive score on any nutrient would mean you're above the min daily amount. no extra brownie points for that,
    # so we give you a 0
# a negative score on any nutrient means you're below the min daily amount
pos_score <- function(orig_menu) {
  total_nut_score <- 0
  
  for (p in seq_along(pos_df$positive_nut)) {    # for each row in the df of positives
    nut_considering <- pos_df$positive_nut[p]    # grab the name of the nutrient we're examining
    val_nut_considering <- (sum(orig_menu[[nut_considering]] * orig_menu$GmWt_1))/100   # get the total amount of that nutrient in our original menu
    
    nut_score <- (-1)*(pos_df$value[p] - val_nut_considering)    # (-1)*(min amount it's supposed to be - amount it is here)
    # print(paste0("nut_score is", nut_score))
    
    if (nut_score > 0) {
      nut_score <- 0
    } else if (is.na(nut_score)) {
      break
    }
    total_nut_score <- total_nut_score + nut_score
  }
  total_nut_score
}

pos_score(menu)
pos_score(master_menu)


# -------------------- Must Restricts ----------------
# we both penalize for going over the max and give you brownie points for getting below the max
# more positive score is better (same directionality of goodness as pos_score)

# a negative score on any one nutrient means you're over the max value you should be: bad
# a negative score means you're below the max: good job
mr_score <- function(orig_menu) {
  total_mr_score <- 0
  
  for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of positives
    mr_considering <- mr_df$must_restrict[m]    # grab the name of the nutrient we're examining
    val_mr_considering <- (sum(orig_menu[[mr_considering]] * orig_menu$GmWt_1))/100   # get the total amount of that nutrient in our original menu
    
    mr_score <- pos_df$value[m] - val_mr_considering  # max amount it's supposed to be - amount it is

    total_mr_score <- total_mr_score + mr_score
    total_mr_score
    
  }
  total_mr_score
}

mr_score(menu)
mr_score(master_menu)


# -------------------- Combined Score ----------------
# sum the two scores
score_menu <- function(orig_menu) {
  healthiness_score <- pos_score(orig_menu) + mr_score(orig_menu)
  healthiness_score
}

score_menu(menu)
score_menu(master_menu)







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


# Arrange all foods in our db by their rank, from best to worst
ranked_foods <- cbind(abbrev_sans_na, score = rank_foods(abbrev_sans_na)) %>% 
  arrange(desc(score))


