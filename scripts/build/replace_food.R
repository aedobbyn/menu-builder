
# ----------------------- Restrict must_restricts --------------------
# while we're not in compliance with must_restrict values (over the daily max in one or more respects),
# for each must_restrict, find the food in our menu that has the highest level of this must_restrict per gram (the max offender)
# and replace it with 
# if there are any, one serving of a food that is less than or equal to x standard deviations below the mean on that given nutrient 
# x is specified in replace_food_w_better()
# if there aren't any foods that meet the x standard deviations criteria, then replace the max offender with
# one serving of a random food in our dataframe of all foods



# ------- Helper functions for smart swapping --------------
# the scaled dataframe comes from abbrev.R. It has all nutrients z-scored per nutrient.
# pare it to foods that aren't NA in columns we care about

# for a given must_restrict and a given max_offender in a menu (these are determined in smart_swap())
# reduce our full corpus of foods, abbrev, to foods that are below some threshold on that must_restrict, as per the scaled dataframe
# then pick a random food from that reduced dataframe and replace the max offender with it

replace_food_w_better <- function(orig_menu, max_offender, nutrient_to_restrict, cutoff = 0.5, df = abbrev,
                                  verbose = TRUE) {
  
  if (!"shorter_desc" %in% names(df)) {
    df <- df %>% do_menu_mutates() %>% add_ranked_foods()
  }
  
  df <- df %>% 
    drop_na_(all_nut_and_mr_df$nutrient) %>% 
    filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) %>% 
    filter(! NDB_No %in% orig_menu$NDB_No) # This has to be a new food
  
  scaled <- df %>% 
    mutate_at(
      vars(nutrient_names, "Energ_Kcal"), dobtools::z_score 
    )
  
  replacment_food_pool <- df %>%    
    filter(NDB_No %in% scaled[scaled[[nutrient_to_restrict]] < (-1 * cutoff), ][["NDB_No"]]) 
  
  if(nrow(replacment_food_pool) == 0) {    # If our cutoff is too restrictive, just choose a random food from df
    replacment_food_pool <- df
      
    if (verbose == TRUE) { message("No better foods at this cutoff; choosing a food randomly.") }
  }
  
  # Grab a random row from our df of foods better on this dimension
  replacement_food <- replacment_food_pool[sample(nrow(replacment_food_pool), 1), ]

  if (verbose == TRUE) { message(paste0("Replacing the max offender with: ", replacement_food$Shrt_Desc)) }
  
  return(replacement_food)
}



