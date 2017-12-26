
# ----------------------- Restrict must_restricts --------------------
# while we're not in compliance with must_restrict values (over the daily max in one or more respects),
# for each must_restrict, find the food in our menu that has the highest level of this must_restrict per gram (the max offender)
# and replace it with 
# if there are any, one serving of a food that is less than or equal to x standard deviations below the mean on that given nutrient 
# x is specified in replace_food_w_better()
# if there aren't any foods that meet the x standard deviations criteria, then replace the max offender with
# one serving of a random food in our dataframe of all foods



# ------- Helper functions for smart swapping --------------
# the scaled dataframe comes from stats.R. It has all nutrients z-scored per nutrient.
# pare it to foods that aren't NA in columns we care about

# for a given must_restrict and a given max_offender in a menu (these are determined in smart_swap())
# reduce our full corpus of foods, abbrev, to foods that are below some threshold on that must_restrict, as per the scaled dataframe
# then pick a random food from that reduced dataframe and replace the max offender with it

replace_food_w_better <- function(orig_menu, max_offender, nutrient_to_restrict, cutoff = 0.5) {
  scaled <- scaled %>% 
    drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  
  replacment_food_pool <- abbrev %>% 
    drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) %>% 
    filter(NDB_No %in% scaled[scaled[[nutrient_to_restrict]] < (-1 * cutoff), ][["NDB_No"]])
  
  if(nrow(replacment_food_pool) == 0) {    # Rather than subbing in replace_food_w_rand() for replace_food_w_better() if we get an exception, just build it in
    replacment_food_pool <- abbrev
    print("No better foods at this cutoff; choosing a food randomly.")
  }
  
  replacement_food <- replacment_food_pool[sample(nrow(replacment_food_pool), 1), ]  # grab a random row from our df of foods better on this dimension
  
  print(paste0("Replacing the max offender with: ", replacement_food$Shrt_Desc))
  
  return(replacement_food)
}

# Replace a food with a randomly chosen food
# Not used in smart_swap anymore; random replacement built into replace_food_w_better()
replace_food_w_rand <- function(orig_menu, max_offender) {
  randomized <- abbrev[sample(nrow(abbrev)),] %>%  # take our original df of all foods, randomize it, and
    drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  
  rand_row <- randomized[sample(nrow(randomized), 1), ]   # grab a random row from our df of all food
  
  orig_menu[max_offender, ] <- rand_row
}
# ---------------------------------------------

