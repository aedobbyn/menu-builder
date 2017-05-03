


# no extra credit for going above the daily min. best score is 0, worst score is negative infinity.
# max score is 0, min score is -infinity
pos_score <- function(orig_menu) {
  total_nut_score <- 0
  
  for (p in seq_along(pos_df$positive_nut)) {    # for each row in the df of positives
    nut_considering <- pos_df$positive_nut[p]    # grab the name of the nutrient we're examining
    val_nut_considering <- (sum(orig_menu[[nut_considering]] * orig_menu$GmWt_1))/100   # get the total amount of that nutrient in our original menu
    
    nut_score <- val_nut_considering - pos_df$value[p]   # amount it is - min amount it's supposed to be
    
    if (nut_score > 0) {
      nut_score <- 0
    }
    total_nut_score <- total_nut_score + nut_score
  }
  total_nut_score
}

pos_score(menu)
pos_score(master_menu)


# we both penalize for going over the max and give you brownie points for getting below the max
# more positive score is better
mr_score <- function(orig_menu) {
  total_mr_score <- 0
  
  for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of positives
    mr_considering <- mr_df$must_restrict[m]    # grab the name of the nutrient we're examining
    val_mr_considering <- (sum(orig_menu[[mr_considering]] * orig_menu$GmWt_1))/100   # get the total amount of that nutrient in our original menu
    
    mr_score <- pos_df$value[m] - val_mr_considering   # max amount it's supposed to be - amount it is
    print(paste0('this score: ', mr_score))
    
    total_mr_score <- total_mr_score + mr_score
    print(paste0('running total: ', total_mr_score))
    total_mr_score
    
  }
  total_mr_score
}

mr_score(menu)
mr_score(master_menu)





