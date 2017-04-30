
# load in the abbreviated data from the USDA database
source("./abbrev.R")

# ----------- Conditions to satisfy ---------
# minimum daily calories: 2300 kcal
# maximum daily must_restrict values appear in mr_df and mr_hash
# minimum daily positive nutrient values appear in pos_df and pos_hash
# -------------------------------------------

# ----------- Nutrient calculations ---------
# according to USDA documentation, to get nutrients in 1 serving of food: 
# N = (V*W)/100
# where:
#   N = nutrient value per household measure,
# V = nutrient value per 100 g and W = g weight of portion (Gm_Wgt in the Weight file).
# --------------------------------------------




# ------------- Initial Builder ---------------

# Build a daily menu from scratch by sampling one serving of a food at random from our dataframe 
# until we're at or over 2300 calories

set.seed(9)

build_menu <- function(df) {
  # df <- df %>% drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need
  # i <- sample(nrow(df), 1) # sample a random row from df and save its index in i
  
  df <- df %>% filter(!(is.na(Lipid_Tot_g)) & !(is.na(Sodium_mg)) & !(is.na(Cholestrl_mg)) & !(is.na(FA_Sat_g)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need
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

menu <- build_menu(abbrev)


# -------- Compliance Tests ---------
# Now that we've built our menu, we need to see how to tweak it so that it's in compliance with the guidelines.
# we'll test whether it's in compliance with the must restricts (not in compliance if it's over the max in in any way)
# and also with the positive nutrients.
# Finally, it should contain >= 2300 calories.


# Must restrict compliance
test_mr_compliance <- function(orig_menu) {
  compliance <- vector()
  
  for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
    nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
    to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1))/100   # get the amount of that must restrict nutrient in our original menu
    
    if (to_restrict > mr_df$value[m]) {
      this_compliance <- paste0("Not compliant on ", nut_to_restrict)
      compliance <- c(this_compliance, compliance)
    }
  }
  compliance
}



# Positive nutrients compliance
test_pos_compliance <- function(orig_menu) {
  orig_menu <- orig_menu %>% drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  compliance <- vector()
  
  for (p in seq_along(pos_df$positive_nut)) {    # for each row in the df of positives
    nut_to_augment <- pos_df$positive_nut[p]    # grab the name of the nutrient we're examining
    val_nut_to_augment <- (sum(orig_menu[[nut_to_augment]] * orig_menu$GmWt_1))/100   # get the total amount of that nutrient in our original menu
    
    
    if (val_nut_to_augment < pos_df$value[p]) {
      this_compliance <- paste0("Not compliant on ", nut_to_augment)
      compliance <- c(this_compliance, compliance)
      
    }
  }
  compliance
}



# Calories
test_calories <- function(our_menu) {
  total_cals <- sum((our_menu$Energ_Kcal * our_menu$GmWt_1))/100 
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
  
  if (length(test_mr_compliance(orig_menu)) + length(test_pos_compliance(orig_menu)) > 0 |
      test_calories(orig_menu) == "Calories too low") {
    combined_compliance <- "Not Compliant"
  } else if (length(test_mr_compliance(orig_menu)) + length(test_pos_compliance(orig_menu)) == 0 &
             test_calories(orig_menu) == "Calorie compliant") {
    combined_compliance <- "Compliant"
  } else {
    combined_compliance <- "Undetermined"
  }
  
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





# ----------------------- The Restrictor --------------------
# while we're not in compliance with must_restrict values (over the daily max in one or more respects),
# for each must_restrict, find the food in our menu that has the highest level of this must_restrict per gram
# and replace it with one serving of a random food in our dataframe of all foods

restrict_all <- function(orig_menu) {
  randomized <- abbrev[sample(nrow(abbrev)),] %>%  # take our original df of all foods, randomize it, and
    filter(!(is.na(Lipid_Tot_g)) & !(is.na(Sodium_mg)) & !(is.na(Cholestrl_mg)) & !(is.na(FA_Sat_g)) & !(is.na(GmWt_1)))   # filter out the columns that can't be NA
  
  while(length(test_mr_compliance(orig_menu)) > 0) {
    
    for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
      nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
      print(paste0("------- nutrient we're restricting is ", nut_to_restrict, ". It has to be below ", mr_df$value[m]))
      to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1))/100   # get the amount of that must restrict nutrient in our original menu
      print(paste0("original total value of that nutrient in our menu is ", to_restrict))
      
      while (to_restrict > mr_df$value[m]) {     # if the amount of the must restrict in our current menu is above the max value it should be according to mr_df
        max_offender <- which(orig_menu[[nut_to_restrict]] == max(orig_menu[[nut_to_restrict]]))   # get index of food that's the worst offender in this respect
        
        print(paste0("the worst offender in this respect is ", orig_menu[max_offender, ]$Shrt_Desc))
        rand_row <- randomized[sample(nrow(randomized), 1), ]   # grab a random row from our df of all foods
        print(paste0("we're replacing the worst offender with ", rand_row[["Shrt_Desc"]]))
        orig_menu[max_offender, ] <- rand_row   # replace the max offender with the next row in the randomzied df
        
        to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1))/100   # recalculate the must restrict nutrient content
        print(paste0("our new value of this must restrict is ", to_restrict))
      }
    }
  }
  orig_menu
}

restricted_menu <- restrict_all(menu)


# ------------ Increase Positive Nutrients ---------
# Here we'll take a different tack. Instead of swapping in better foods, we'll adjust the serving sizes of foods that already exist
# on our menu until we get in compliance with the minimum daily positive values.

# To see a more complicated version of this function that decreases the calorie count of the overall menu by the same amount as the
# increase, see adjust_portion_sizes_and_square_calories.R

# for each nutriet in <array of nutrients>, check whether we've met the required amount. if so, move on to the next
# if not, adjust serving sizes of current foods (Gm_Wt1) until we've met the requirements by finding the food on the menu that is
# highest in that nutrient per gram and increasing its weight by 10% until we've met that requirement.

adjust_portion_sizes <- function(orig_menu) {
  orig_menu <- orig_menu %>% drop_na_(pos_df$positive_nut) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  
  for (p in seq_along(pos_df$positive_nut)) {    # for each row in the df of positives
    nut_to_augment <- pos_df$positive_nut[p]    # grab the name of the nutrient we're examining
    print(paste0("------- The nutrient we're considering is ", nut_to_augment, ". It has to be above ", pos_df$value[p]))
    
    val_nut_to_augment <- (sum(orig_menu[[nut_to_augment]] * orig_menu$GmWt_1))/100   # get the total amount of that nutrient in our original menu
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
      val_nut_to_augment <- (sum(orig_menu[[nut_to_augment]] * orig_menu$GmWt_1))/100   # save the new value of the nutrient
      print(paste0("Our new value of this nutrient is ", val_nut_to_augment))
      
      # --------------
      
      # # Find the max_cals and its calorie count
      # food_w_max_cals <- which(orig_menu[-max_pos, ]$Energ_Kcal == max(orig_menu[-max_pos, ]$Energ_Kcal))   # what is the index of the food that isn't our max_pos is currently most calorie dense?
      # cals_of_food_w_max_cals <- (orig_menu[-max_pos, ]$Energ_Kcal[food_w_max_cals] * orig_menu[-max_pos, ]$GmWt_1[food_w_max_cals])/100
      # print(paste0("The food with the most calories that isn't our max positive is  ", orig_menu[-max_pos, ]$Shrt_Desc[food_w_max_cals], " at ", (orig_menu[-max_pos, ]$Energ_Kcal[food_w_max_cals] * orig_menu[-max_pos, ]$GmWt_1[food_w_max_cals])/100))
      # 
      # # Find what the new calorie count and weight of max_cals needs to be
      # max_cals_new_cals_need_to_be <- cals_of_food_w_max_cals - cal_diff
      # print(paste0("We've reduced the calories of the food with the most calories to  ", max_cals_new_cals_need_to_be))
      # max_cals_new_weight_needs_to_be <- max_cals_new_cals_need_to_be*100 / menu[-max_pos, ]$Energ_Kcal[food_w_max_cals]
      # 
      # # Decrement max_cal's weight by the amount it needs to be decreased by
      # orig_menu[food_w_max_cals, ]$GmWt_1 <- max_cals_new_weight_needs_to_be
      # print(paste0("We've reduced the weight of the food with the most calories to  ", orig_menu[food_w_max_cals, ]$GmWt_1))
    }
  }
  orig_menu
}



# ---------------- Add Calories -------------

# swapping in a single serving size of a given food for another might have put us below the minimum calorie requirement of 2300. If our
# menu's total calories are too low, increase them by adding one serving of a random food from our database to the menu

add_calories <- function(orig_menu) {
  orig_menu <- orig_menu %>% drop_na_(all_nut_and_mr_df$nutrient) %>%  filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) 
  df <- abbrev %>% drop_na_(all_nut_and_mr_df$nutrient) %>%  filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need
  
  i <- sample(nrow(df), 1) # sample a random row from df and save its index in i  
  
  cals <- sum((orig_menu$Energ_Kcal * orig_menu$GmWt_1))/100   # set calories to our current number of calories
  
  while (cals < 2300) {
    this_food_cal <- (df$Energ_Kcal[i] * df$GmWt_1[i])/100    # get the number of calories in 1 serving of this food (see N = (V*W)/100 formula)
    cals <- cals + this_food_cal    # add the calories in row of index i to the calorie sum variable
    
    menu <- rbind(menu, df[i,])   # add that row to our menu
    
    i <- sample(nrow(df), 1)   # resample a new index
  }
  menu    # return the full menu
}




# ---------------- Combine all of the above to build a menu that is compliant in all three respects ---------------

master_builder <- function(our_menu) {
  # our_menu <- build_menu(abbrev)   # seed with a random menu
  
  # first put it through the restrictor
  our_menu <- restrict_all(our_menu)
  
  # define conditions
  total_cals <- sum((our_menu$Energ_Kcal * our_menu$GmWt_1))/100 
  
  # while (test_all_compliance(our_menu) == "Not Compliant") {
  while (total_cals < 2300 |
  (length(test_mr_compliance(our_menu)) + length(test_pos_compliance(our_menu)) > 0)) {
    
    if (total_cals < 2300) {
      our_menu <- add_calories(our_menu)
      
    } else if (length(test_mr_compliance(our_menu))) {
      our_menu <- restrict_all(our_menu)
      
    } else if (length(test_pos_compliance(our_menu))) {
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
test_mr_compliance(restricted_menu)
test_mr_compliance(more_nutritious)
test_mr_compliance(master_menu)

# positives
test_pos_compliance(menu)
test_pos_compliance(restricted_menu)
test_pos_compliance(more_nutritious)
test_pos_compliance(master_menu)

# calories
test_calories(menu)
test_calories(restricted_menu)
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

# indices that differ between the original and new menu
which(!menu$GmWt_1 %in% master_menu$GmWt_1)

# -----------------------------------------------------------------------------------



