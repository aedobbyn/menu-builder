
# load in the abbreviated data from the USDA database
source("./scripts/prep/abbrev.R")
source("./scripts/prep/stats.R")
library(dobtools)

# ----------- Conditions to satisfy ---------
# minimum daily calories: 2300 kcal
# maximum daily must_restrict values appear in mr_df and mr_hash
# minimum daily positive nutrient values appear in pos_df and pos_hash
# -------------------------------------------

# ----------- Nutrient calculations ---------
# according to USDA documentation (p. 37), to get nutrients in 1 serving of food: 
# N = (V*W)/100
# where:
  # N = nutrient value per household measure,
  # V = nutrient value per 100 g and 
  # W = g weight of portion (Gm_Wgt in the Weight file).

# Documentation: https://www.ars.usda.gov/ARSUserFiles/80400525/Data/SR/sr28/sr28_doc.pdf
# --------------------------------------------



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


# -------- Compliance Tests ---------
# Now that we've built our menu, we need to see how to tweak it so that it's in compliance with the guidelines.
# we'll test whether it's in compliance with the must restricts (not in compliance if it's over the max in in any way)
# and also with the positive nutrients.
# Finally, it should contain >= 2300 calories.


# Must restrict compliance
test_mr_compliance <- function(orig_menu, capitalize_colname = TRUE) {
  compliance_df <- list(must_restricts_uncompliant_on = vector(), 
                        `difference_(g)` = vector()) %>% as_tibble()
  
  for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
    nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
    to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # get the amount of that must restrict nutrient in our original menu
    
    if ((to_restrict - mr_df$value[m]) > 0.01) {    # account for rounding error
      this_compliance <- list(must_restricts_uncompliant_on = nut_to_restrict,
                              `difference_(g)` = (to_restrict - mr_df$value[m]) %>% round(digits = 2)) %>% as_tibble()
      compliance_df <- bind_rows(compliance_df, this_compliance)
    }
  }
  if (capitalize_colname == TRUE) {
    compliance_df <- compliance_df %>% cap_df()
  }
  return(compliance_df)
}


# Positive nutrients compliance
test_pos_compliance <- function(orig_menu, capitalize_colname = TRUE) {
  orig_menu <- orig_menu %>% drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  compliance_df <- list(nutrients_uncompliant_on = vector(),
                        `difference_(g)` = vector()) %>% as_tibble()
  
  for (p in seq_along(pos_df$positive_nut)) {    # for each row in the df of positives
    nut_to_augment <- pos_df$positive_nut[p]     # grab the name of the nutrient we're examining
    val_nut_to_augment <- (sum(orig_menu[[nut_to_augment]] * 
                                 orig_menu$GmWt_1, na.rm = TRUE))/100   # get the total amount of that nutrient in our original menu
    
    if ((pos_df$value[p] - val_nut_to_augment) > 0.01) {     # account for rounding error (instead of if val_nut_to_augment < pos_df$value[p])
      this_compliance <- list(nutrients_uncompliant_on = nut_to_augment,
                              `difference_(g)` = (pos_df$value[p] - val_nut_to_augment) %>% 
                                round(digits = 2)) %>%
                                as_tibble()
      compliance_df <- bind_rows(compliance_df, this_compliance)
    }
  }
  if (capitalize_colname == TRUE) {
    compliance_df <- compliance_df %>% cap_df()
  }
  return(compliance_df)
}


# Calories
test_calories <- function(our_menu) {
  total_cals <- sum((our_menu$Energ_Kcal * our_menu$GmWt_1), na.rm = TRUE)/100 
  if (total_cals < 2300) {
    cal_compliance <- "Calories too low"
  } else {
    cal_compliance <- "Calorie compliant"
  }
  cal_compliance
}


# Omnibus test
test_all_compliance <- function(orig_menu) {
  combined_compliance <- "Undetermined"
  
  if (nrow(test_mr_compliance(orig_menu)) + nrow(test_pos_compliance(orig_menu)) > 0 |
      test_calories(orig_menu) == "Calories too low") {
    combined_compliance <- "Not Compliant"
    
  } else if (nrow(test_mr_compliance(orig_menu)) + nrow(test_pos_compliance(orig_menu)) == 0 &
             test_calories(orig_menu) == "Calorie compliant") {
    combined_compliance <- "Compliant"
    
  } else {
    combined_compliance <- "Undetermined"
  }
  combined_compliance
}



# Verbose omnibus test: 
test_all_compliance_verbose <- function(orig_menu) {
  combined_compliance <- "Undetermined"
  uncompliant_message <- NULL
  
  if (nrow(test_mr_compliance(orig_menu)) + nrow(test_pos_compliance(orig_menu)) == 0 &
      test_calories(orig_menu) == "Calorie compliant") {
    combined_compliance <- "Compliant"
    uncompliant_message <- NULL
  } else if (nrow(test_mr_compliance(orig_menu)) + nrow(test_pos_compliance(orig_menu)) > 0 |
             test_calories(orig_menu) == "Calories too low") {
    combined_compliance <- "Not Compliant"
    uncompliant_message <- c(uncompliant_message, 
                             test_calories(orig_menu), 
                             test_pos_compliance(orig_menu)[, 1], 
                             test_mr_compliance(orig_menu)[, 1])
  } else {
    combined_compliance <- "Undetermined"
  }
  print(uncompliant_message)
  combined_compliance
}


# --------- Test Initial Compliance ------

# all
test_all_compliance(menu)

# must_restricts
test_mr_compliance(menu)

# positives
test_pos_compliance(menu)

# calories
test_calories(menu)

# ---------------------------------------


# ----------------------------------------------------------------------------------------------------------------
# -------------------------------- Mechanisms for Adjusting Menus into Compliance --------------------------------


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

# do the swapping
  # if we reduce the original corpus of foods down to foods that are lower than x standard deviations below the mean on a given must_restrict
  # and we're left with an empty dataframe, trying to replace the max offender with an empty dataframe will throw an error
  # if we do get an error in trycatch, then replace the max offender with a random food
    # otherwise, go ahead with replacing it with a better one

smart_swap <- function(orig_menu, cutoff = 0.5) {
  
  while(nrow(test_mr_compliance(orig_menu)) > 0) {
    
    for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
      nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
      print(paste0("------- The nutrient we're restricting is ", nut_to_restrict, ". It has to be below ", mr_df$value[m]))
      to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # get the amount of that must restrict nutrient in our original menu
      print(paste0("The original total value of that nutrient in our menu is ", to_restrict))
      
      while (to_restrict > mr_df$value[m]) {     # if the amount of the must restrict in our current menu is above the max value it should be according to mr_df
        max_offender <- which(orig_menu[[nut_to_restrict]] == max(orig_menu[[nut_to_restrict]]))   # get index of food that's the worst offender in this respect
        
        print(paste0("The worst offender in this respect is ", orig_menu[max_offender, ]$Shrt_Desc))
        
        # ------- smart swap or randomly swap in a food here --------
        orig_menu[max_offender, ] <- replace_food_w_better(orig_menu, max_offender, nut_to_restrict, cutoff = cutoff)
        
        to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # recalculate the must restrict nutrient content
        print(paste0("Our new value of this must restrict is ", to_restrict))
      }
    }
  }
  orig_menu
}

smartly_swapped <- smart_swap(menu)
smartly_swapped_cutoff <- smart_swap(menu, cutoff = 3)





# ------------ Increase Positive Nutrients ---------
# Here we'll take a different tack. Instead of swapping in better foods, we'll adjust the serving sizes of foods that already exist
# on our menu until we get in compliance with the minimum daily positive values.

# To see a more complicated version of this function that decreases the calorie count of the overall menu by the same amount as the
# increase, see adjust_portion_sizes_and_square_calories.R

# For each nutriet in <array of nutrients>, check whether we've met the required amount. If so, move on to the next.
# If not, adjust serving sizes of current foods (Gm_Wt1) until we've met the requirements by finding the food on the menu that is
# highest in that nutrient per gram and increasing its weight by 10% until we've met that requirement.

adjust_portion_sizes <- function(orig_menu) {
  orig_menu <- orig_menu %>% drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))

  for (p in seq_along(pos_df$positive_nut)) {    # for each row in the df of positives
    nut_to_augment <- pos_df$positive_nut[p]    # grab the name of the nutrient we're examining
    print(paste0("------- The nutrient we're considering is ", nut_to_augment, ". It has to be above ", pos_df$value[p]))
    
    val_nut_to_augment <- (sum(orig_menu[[nut_to_augment]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # get the total amount of that nutrient in our original menu
    print(paste0("The original total value of that nutrient in our menu is ", val_nut_to_augment))
    
    while (val_nut_to_augment < pos_df$value[p]) {     # if the amount of the must restrict in our current menu is below the min daily value it should be according to pos_df
      
      # Find the max_pos and its starting calorie count
      max_pos <- which(orig_menu[[nut_to_augment]] == max(orig_menu[[nut_to_augment]]))   # get index of food that's the best in this respect
      max_pos_starting_cals <- (orig_menu[max_pos, ]$Energ_Kcal * orig_menu[max_pos, ]$GmWt_1)/100
      print(paste0("The best food in this respect is ", orig_menu[max_pos, ]$Shrt_Desc, ". It contributes ", max_pos_starting_cals, " calories."))
      
      # Augment max_pos's weight by 10%
      new_gmwt <- (orig_menu[max_pos, ]$GmWt_1) * 1.1 # augment by 10%
      orig_menu[max_pos, ]$GmWt_1 <- new_gmwt   # replace the value with the augmented one
      
      # Find how much we increased max_pos's calorie count by
      max_pos_new_cals <- (orig_menu[max_pos, ]$Energ_Kcal * new_gmwt)/100   # get the amount that we increased our menu's calories by in augmenting the max_pos
      print(paste0("After an increase of 10% weight the calories contributed by our max positive are ", max_pos_new_cals, " calories."))
      cal_diff <- max_pos_new_cals - max_pos_starting_cals
      
      # Find the newly augmented nutrient value to see if we need to continue the loop
      val_nut_to_augment <- (sum(orig_menu[[nut_to_augment]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # save the new value of the nutrient
      print(paste0("Our new value of this nutrient is ", val_nut_to_augment))
    }
  }
  orig_menu
}

more_nutritious <- adjust_portion_sizes(menu)


# ---------------- Add Calories -------------

# swapping in a single serving size of a given food for another might have put us below the minimum calorie requirement of 2300. If our
# menu's total calories are too low, increase them by adding one serving of a random food from our database to the menu

add_calories <- function(orig_menu) {
  orig_menu <- orig_menu %>% drop_na_(all_nut_and_mr_df$nutrient) %>%  filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) 
  df <- abbrev %>% drop_na_(all_nut_and_mr_df$nutrient) %>%  filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need
  
  i <- sample(nrow(df), 1) # sample a random row from df and save its index in i  
  
  cals <- sum((orig_menu$Energ_Kcal * orig_menu$GmWt_1), na.rm = TRUE)/100   # set calories to our current number of calories
  
  while (cals < 2300) {
    this_food_cal <- (df$Energ_Kcal[i] * df$GmWt_1[i])/100    # get the number of calories in 1 serving of this food (see N = (V*W)/100 formula)
    cals <- cals + this_food_cal    # add the calories in row of index i to the calorie sum variable
    
    menu <- rbind(menu, df[i,])   # add that row to our menu
    
    i <- sample(nrow(df), 1)   # resample a new index
  }
  menu    # return the full menu
}

# ----------------------------------------------------------------------------------------------------------------



# ---------------- Build Compliant Menu ---------------
# Combine all of the above to build a menu that is compliant in all three respects

master_builder <- function(our_menu) {
  # our_menu <- build_menu(abbrev)   # seed with a random menu
  
  # define conditions
  total_cals <- sum((our_menu$Energ_Kcal * our_menu$GmWt_1), na.rm = TRUE)/100 
  
  while (test_all_compliance(our_menu) == "Not Compliant") {
    
    if (total_cals < 2300) {
      our_menu <- add_calories(our_menu)
      
    } else if (nrow(test_mr_compliance(our_menu))) {
      our_menu <- smart_swap(our_menu)
      
    } else if (nrow(test_pos_compliance(our_menu))) {
      our_menu <- adjust_portion_sizes(our_menu)
      
    } else {
      print("Something went wrong")
    }
  }
  our_menu
}

master_menu <- master_builder(menu)
master_menu




# --------- Test Compliances ------
# all
test_all_compliance(menu)
test_all_compliance(master_menu)

# must_restricts
test_mr_compliance(menu)
test_mr_compliance(smartly_swapped)
test_mr_compliance(more_nutritious)
test_mr_compliance(master_menu)

# positives
test_pos_compliance(menu)
test_pos_compliance(smartly_swapped)
test_pos_compliance(more_nutritious)
test_pos_compliance(master_menu)

# calories
test_calories(menu)
test_calories(smartly_swapped)
test_calories(more_nutritious)
test_calories(master_menu)
# ---------------------------------------


# ------------ Find the differences between starting and ending menus -------------

# food desriptions and weights that differ between two menus

see_diffs <- function(menu_1, menu_2) {
  diff <- setdiff(menu_1, menu_2) %>% 
    select(Shrt_Desc, GmWt_1)
  diff
}
see_diffs(menu, master_menu)

# indices that differ on weight between the original and new menu
which(!menu$GmWt_1 %in% master_menu$GmWt_1)

# -----------------------------------------------------------------------------------


# Main output we'd want to see
test_all_compliance(master_menu)

