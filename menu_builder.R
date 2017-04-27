
# load in the abbreviated data from the USDA database
source("./abbrev.R")

# minimum daily calories: 2300 kcal
# maximum daily must_restrict values appear in mr_df and mr_hash
# minimum daily positive nutrient values a

# according to USDA documentation, to get nutrients in 1 serving of food: 
# N = (V*W)/100
# where:
#   N = nutrient value per household measure,
# V = nutrient value per 100 g and W = g weight of portion (Gm_Wgt in the Weight file).


set.seed(9)


# build a daily menu from scratch by sampling one serving of a food at random from our dataframe 
# until we're at or over 2300 calories

build_menu <- function(df) {
  df <- df %>% filter(!(is.na(Lipid_Tot_g)) & !(is.na(Sodium_mg)) & !(is.na(Cholestrl_mg)) & !(is.na(FA_Sat_g)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need
  i <- sample(nrow(df), 1) # sample a random row from df and save its index in i
  
  cals <- 0   # set the builder variables to 0
  sodium <- 0
  menu <- NULL
  
  while (cals < 2300) {
    this_food_cal <- (df$Energ_Kcal[i] * df$GmWt_1[i])/100    # get the number of calories in 1 serving of this food (see N = (V*W)/100 formula)
    cals <- cals + this_food_cal    # add the calories in row of index i to the calorie sum variable
    
    menu <- rbind(menu, df[i,])   # add that row to our menu
    
    i <- sample(nrow(df), 1)   # resample a new index
    # menu <- restrict_all(menu)    # work in progress incorporating restrict_all()
  }
  menu    # return the full menu
}

menu <- build_menu(abbrev)
menu

View(menu)

menu_cals <- sum((menu$Energ_Kcal * menu$GmWt_1)/100)
menu_cals # 




restrict_all <- function(orig_menu) {
  randomized <- abbrev[sample(nrow(abbrev)),] %>%  # take our original df of all foods, randomize it, and
    filter(!(is.na(Lipid_Tot_g)) & !(is.na(Sodium_mg)) & !(is.na(Cholestrl_mg)) & !(is.na(FA_Sat_g)) & !(is.na(GmWt_1)))   # filter out the columns that can't be NA
  
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
  orig_menu
}

restricted_menu <- restrict_all(menu)
restricted_menu
View(restricted_menu)

setdiff(menu, restricted_menu)


new_cals <- sum((restricted_menu$Energ_Kcal * restricted_menu$GmWt_1)/100)
new_cals
# too low!
# need to keep checking that we're above the min calorie number




# ------ next up
# for each nutriet in <array of nutrients>, check whether we've met the required amount. if so, move on to the next
  # if not, either
    # a) adjust serving sizes of current foods (Gm_Wt1) until we've met the requirements
        # increase the serving size of a food that is high in that nutrient. find out how many calories we incrased by when we made this adjustment
        # correspondingly decrease the serving size of all other foods such that the calorie count stays the same after
          # we make thse adjustments
    # b) swap in food that is > 1 std_dev above the mean on the nutrient we're lacking for a food on our current menu that
        # is low in that nutrient



adjust_portion_sizes <- function(orig_menu) {
  orig_menu <- orig_menu %>% drop_na_(pos_df$positive_nut) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) %>% select(-Magnesium_mg)
  for (p in seq_along(pos_df$positive_nut)) {    # for each row in the df of positives
    nut_to_augment <- pos_df$positive_nut[p]    # grab the name of the nutrient we're examining
    print(paste0("------- nutrient we're considering is ", nut_to_augment, ". It has to be above ", pos_df$value[p]))
    to_augment <- (sum(orig_menu[[nut_to_augment]] * orig_menu$GmWt_1))/100   # get the total amount of that nutrient in our original menu
    print(paste0("original total value of that nutrient in our menu is ", to_augment))
    
    while (to_augment < pos_df$value[p]) {     # if the amount of the must restrict in our current menu is below the min daily value it should be according to pos_df
      max_pos <- which(orig_menu[[nut_to_augment]] == max(orig_menu[[nut_to_augment]]))   # get index of food that's the best in this respect
      starting_cals <- (orig_menu[max_pos, ]$Energ_Kcal * orig_menu[max_pos, ]$GmWt_1)/100
      print(paste0("the best food in this respect is ", orig_menu[max_pos, ]$Shrt_Desc, ". It contributes ", starting_cals, " calories."))
      
      new_gmwt <- (orig_menu[max_pos, ]$GmWt_1) * 1.1 # augment by 10%
      orig_menu[max_pos, ]$GmWt_1 <- new_gmwt   # replace the value with the augmented one
      
      new_cals <- (orig_menu[max_pos, ]$Energ_Kcal * orig_menu[max_pos, ]$GmWt_1)/100
      print(paste0("New cals are ", new_cals, " calories."))
      
      cal_diff <- new_cals - starting_cals
      
      
      to_augment <- (sum(orig_menu[[nut_to_augment]] * new_gmwt))/100   # recalculate the nutrient content
      print(paste0("our new value of this nutrient is ", to_augment))
    }
    to_augment
  }
  orig_menu
}

more_nutritious <- adjust_portion_sizes(menu)
more_nutritious




