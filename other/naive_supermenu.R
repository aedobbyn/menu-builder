# naive super menu

source("./score_menu.R")


# what happens when we build a menu from the best ranked foods?
# build a menu by adding the highest overall rated foods until we hit 2300 cals. are compliant?

build_best_menu <- function(df) {
  i <- 1
  
  cals <- 0   # set the builder variables to 0
  menu <- NULL
  
  while (cals < 2300) {
    this_food_cal <- (df$Energ_Kcal[i] * df$GmWt_1[i])/100    # get the number of calories in 1 serving of this food (see N = (V*W)/100 formula)
    cals <- cals + this_food_cal    # add the calories in row of index i to the calorie sum variable
    
    menu <- rbind(menu, df[i,])   # add that row to our menu
    
    i <- i + 1   
  }
  menu    # return the full menu
}

best_menu <- build_best_menu(ranked_foods)

score_menu(best_menu) # 2111.848
test_all_compliance(best_menu) # "Not Compliant"
test_pos_compliance(best_menu) # "Not compliant on Riboflavin_mg" "Not compliant on Manganese_mg" 



# So just building a menu 