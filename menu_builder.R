
# load in the abbreviated data from the USDA database
source("./abbrev.R")

# minimum daily calories: 2300 kcal
# max sodium: 2400 mg

# according to USDA documentation, to get nutrients in 1 serving of food: 
# N = (V*W)/100
# where:
#   N = nutrient value per household measure,
# V = nutrient value per 100 g and W = g weight of portion (Gm_Wgt in the Weight file).


set.seed(9)


# build a daily menu from scratch by sampling one serving of a food at random from our dataframe 
# until we're at or over 2300 calories

build_menu <- function(df) {
  df <- df %>% filter(!(is.na(Sodium_mg)) & !(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))    # filter out rows that have NAs in columns that we need
  i <- sample(nrow(df), 1) # sample a random row from df and save its index in i
  
  cals <- 0   # set the builder variables to 0
  sodium <- 0
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
menu

View(menu)




# now get below the daily sodium threshold of 2400 by subbing out the food with the highest sodium 
# and putting a random one in its place

restrict_sodium <- function(orig_menu) {
  randomized <- abbrev[sample(nrow(abbrev)),] %>%  # take our original df of all foods, randomize it, and
    filter(!(is.na(Sodium_mg)) & !(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))   # filter out the columns that can't be NA
  
  sodium <- (sum(orig_menu$Sodium_mg * orig_menu$GmWt_1))/100   # get the amount of sodium in our original menu

  for (j in seq_along(1:nrow(randomized))) {     # loop through the randomized df in order (equivalent to sampling randomly from our orignal df)
    if (sodium > 2400) {
      max_sodium_offender <- which(orig_menu$Sodium_mg == max(orig_menu$Sodium_mg))   # get index of food with max sodium

      orig_menu[max_sodium_offender, ] <- randomized[j, ]   # replace the max offender with the next row in the randomzied df
      
      sodium <- (sum(orig_menu$Sodium_mg * orig_menu$GmWt_1))/100   # recalculate the sodium content
      
    } else {
      break     # if we're below 2400, exit the loop
    }
  }
  orig_menu
}


low_sodium_menu <- restrict_sodium(menu)
low_sodium_menu

View(low_sodium_menu)

