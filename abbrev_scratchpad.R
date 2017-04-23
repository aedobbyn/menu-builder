# abbrev scratchpad


source("./abbrev.R")


length(must_restrict) # 8
length(positives) # 36


library(Rfit)


# fit <- rfit(Energ_Kcal ~ must_restrict[1] + must_restrict[2] + must_restrict[3], data = abbrev)
# fit <- rfit(Energ_Kcal ~ Lipid_Tot_g + Carbohydrt_g + Sugar_Tot_g, data = abbrev)
# summary(fit)



# which foods have the highest kcals
abbrev$Shrt_Desc[which(abbrev$Energ_Kcal == max(abbrev$Energ_Kcal))]
# same as
abbrev %>% 
  filter(Energ_Kcal == max(Energ_Kcal)) %>% 
  select(Shrt_Desc, Energ_Kcal)


# Based on Rick's guidelines, set per the sheet PantryFoods, 100g Nutrient Data
# Only considering Calcium to B6
pos_nuts <- positives[4:18]
pos_vals <- c(1000, 18, 400, 1000, 3500, 15, 2, 2, 70, 60, 2, 2, 20, 10, 2)

pos_df <- as_tibble(list(must_restrict = pos_nuts, value = pos_vals))
pos_hash <- hash(pos_nuts, pos_vals)
pos_hash


# same for must_restricts
mr <- c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
mr_vals <- c(65, 2400, 300, 20)

mr_df <- as_tibble(list(must_restrict = mr, value = mr_vals))
mr_hash <- hash(mr, mr_vals)
mr_hash




abbrev[[(keys(mr_hash)[1])]][1:3]
abbrev$Cholestrl_mg[1:3]



# which foods are below the daily must restrict thresholds?


ab <- sample_n(abbrev, 100) %>% 
  select_(
    # NDB_No, Shrt_Desc,
    .dots = mr_df$must_restrict
    # Lipid_Tot_g, Sodium_mg, Cholestrl_mg, FA_Sat_g
  ) %>% 
  filter(
    Lipid_Tot_g <= mr_df$value[1],    # same as values(mr_hash)[1]
    Sodium_mg <= mr_df$value[2],
    Cholestrl_mg <= mr_df$value[3],
    FA_Sat_g <= mr_df$value[4]
  )



# how many standard deviations above/below the must_restrict?
abbrev_st_dev <- apply(abbrev[, 3:which(names(abbrev)=="Cholestrl_mg")],  # everything after cholesterol is not necc numeric
                       2, sd, na.rm = TRUE)

abbrev_mean <- apply(abbrev[, 3:which(names(abbrev)=="Cholestrl_mg")],  # everything after cholesterol is not necc numeric
                     2, mean, na.rm = TRUE)

abbrev_st_dev_names <- names(abbrev_st_dev)

abbrev_st_dev_df <- as_tibble(list(nut_name = abbrev_st_dev_names,
                                   mean = abbrev_mean,
                                   std_dev = abbrev_st_dev))


# must restrict standard devs
mr_st_dev <- abbrev_st_dev_df[(abbrev_st_dev_df$nut_name %in% mr), ]

mr_st_dev_join <- left_join(mr_st_dev, mr_df, 
                            by = c("nut_name" = "must_restrict"))

mr_st_dev_join <- mr_st_dev_join %>% 
  mutate(
    one_above = mean + std_dev,
    one_below = mean - std_dev
  )


# get foods that are > 1 sd above mean on sodium
salty_foods <- abbrev %>% 
  filter(
    Sodium_mg > mr_st_dev_join[mr_st_dev_join$nut_name=="Sodium_mg", ][["one_above"]]
  )


worst_foods <- abbrev %>% 
  filter(
    Lipid_Tot_g > mr_st_dev_join[mr_st_dev_join$nut_name=="Lipid_Tot_g", ][["one_above"]],
    Sodium_mg > mr_st_dev_join[mr_st_dev_join$nut_name=="Sodium_mg", ][["one_above"]]
    # FA_Sat_g > mr_st_dev_join[mr_st_dev_join$nut_name=="FA_Sat_g", ][["one_above"]],
    # Cholestrl_mg > mr_st_dev_join[mr_st_dev_join$nut_name=="Cholestrl_mg", ][["one_above"]]
  )

worst_foods


get_worst_foods <- function(dat, nut, ...) {
  filtered <- dat %>% 
    filter(nut > mr_st_dev_join[mr_st_dev_join$nut_name==nut, ][["one_above"]])
  filtered
}

get_worst_foods(abbrev, "Sodium_mg")
wf <- get_worst_foods(abbrev, "Sodium_mg")


# z-score everything
scaled <- abbrev %>% 
  select(
    3:which(names(abbrev)=="Cholestrl_mg")
  ) %>% 
  mutate_all(
    scale
  )

# cbind the ndbno and description
scaled <- bind_cols(abbrev[, 1:2], scaled, abbrev[, 49:ncol(abbrev)]) # cbind freaks out (?)




# build a random meal by adding foods until Energ_Kcal reaches 2300
build_meal <- function() {
  cal_vec <- abbrev$Energ_Kcal 
  this_food_cal <- cal_vec[sample(cal_vec, 1)]
  
  cals <- 0
  meal <- NULL
  
  while (cals < 2300) {
    cals <- cals + this_food_cal
    i <- sample(cal_vec, 1)
    
    # print(cal_vec[i])
    # print(abbrev[i,])
    
    meal <- rbind(meal, abbrev[i,])
  }
  cals
  meal
}

my_first_meal <- build_meal()

View(my_first_meal)








# multiply this_food_cal by GmWt_1

# nutrient value per household measure
# N = (V*W)/100
# where:
#   N = nutrient value per household measure,
# V = nutrient value per 100 g (Nutr_Val in the Nutrient Data file), and W = g weight of portion (Gm_Wgt in the Weight file).

build_meal2 <- function() {
  i <- sample(nrow(abbrev), 1)
  # cal_vec <- abbrev$Energ_Kcal 
  # this_food_cal <- cal_vec[sample(cal_vec, 1)]
  this_food_cal <- (abbrev$Energ_Kcal[i] * abbrev$GmWt_1[i])/100
  
  cals <- 0
  meal <- NULL
  
  while (cals < 2300) {
    print(i)
    this_food_cal <- (abbrev$Energ_Kcal[i] * abbrev$GmWt_1[i])/100
    cals <- cals + this_food_cal
    
    # print(cal_vec[i])
    # print(abbrev[i,])
    
    meal <- rbind(meal, abbrev[i,])
    i <- sample(nrow(abbrev), 1)
  }
  cals
  meal
}

my_second_meal <- build_meal2()
my_second_meal

View(my_second_meal)



# now check whether we've hit our nutrient count for a few nutrients. if not, keep resampling until we hit it.



set.seed(9)
build_meal3 <- function() {
  i <- sample(nrow(abbrev), 1) # sample a random row from df
  
  cals <- 0   # set the builder variables to 0
  sodium <- 0
  meal <- NULL
  
  while (cals < 2300 & sodium < 2400) {
    this_food_cal <- (abbrev$Energ_Kcal[i] * abbrev$GmWt_1[i])/100    # get the number of calories in 1 serving of this food
    cals <- cals + this_food_cal    # add i's calories to the calorie sum variable
    
    this_food_sodium <- (abbrev$Sodium_mg[i] * abbrev$GmWt_1[i])/100  # get the amount of sodium in 1 serving of this food
    sodium <- sodium + this_food_sodium    # add i's sodium to the sodium sum variable
    
    meal <- rbind(meal, abbrev[i,])
    
    i <- sample(nrow(abbrev), 1)   # resample a new i
  }
  meal    # return the full meal
}

my_third_meal <- build_meal3()
my_third_meal

View(my_third_meal)








set.seed(12)
build_meal4 <- function() {
  abbrev <- abbrev %>% filter(!(is.na(Sodium_mg)) & !(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  i <- sample(nrow(abbrev), 1) # sample a random row from df
  
  cals <- 0   # set the builder variables to 0
  sodium <- 0
  meal <- NULL
  
  while (cals < 2300) {
    this_food_cal <- (abbrev$Energ_Kcal[i] * abbrev$GmWt_1[i])/100    # get the number of calories in 1 serving of this food
    cals <- cals + this_food_cal    # add i's calories to the calorie sum variable
    
    this_food_sodium <- (abbrev$Sodium_mg[i] * abbrev$GmWt_1[i])/100  # get the amount of sodium in 1 serving of this food
    sodium <- sodium + this_food_sodium    # add i's sodium to the sodium sum variable
    
    meal <- rbind(meal, abbrev[i,])
    print(paste0("sodium is ", sodium))
    
    i <- sample(nrow(abbrev), 1)   # resample a new i
    
  }
  meal    # return the full meal
}

my_fourth_meal <- build_meal4()
my_fourth_meal

(sum(my_fourth_meal$Sodium_mg * my_fourth_meal$GmWt_1))/100

View(my_fourth_meal)



# swap out the single biggest sodium offender 
resamp_sodium <- function(orig_meal) {
  abbrev <- abbrev %>% filter(!(is.na(Sodium_mg)) & !(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  sodium <- (sum(orig_meal$Sodium_mg * orig_meal$GmWt_1))/100
  print(paste0("original sodium is", sodium))
  
  while (sodium > 2400) {
    print(paste0("sodium is ", sodium))
    
    max_sodium_offender <- which(my_fourth_meal$Sodium_mg == max(my_fourth_meal$Sodium_mg))   # get index of food with max sodium
    
    j <- sample(nrow(abbrev), 1)
    print(paste0("j is ", j))
    orig_meal[max_sodium_offender, ] <- abbrev[j, ]
    
    sodium <- (sum(orig_meal$Sodium_mg * orig_meal$GmWt_1))/100
    print(paste0("sodium is now", sodium))
    
  }
  orig_meal
}


lower_sodium <- resamp_sodium(my_fourth_meal)
lower_sodium

(sum(lower_sodium$Sodium_mg * lower_sodium$GmWt_1))/100




#a different approach
set.seed(105)
resamp_sodium2 <- function(orig_meal) {
  randomized <- abbrev[sample(nrow(abbrev)),]
  randomized <- randomized %>% filter(!(is.na(Sodium_mg)) & !(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  
  sodium <- (sum(orig_meal$Sodium_mg * orig_meal$GmWt_1))/100
  print(paste0("original sodium is", sodium))
  
  
  for (j in seq_along(1:nrow(randomized))) {
    if (sodium > 2400) {
      print(paste0("sodium is ", sodium))
      
      max_sodium_offender <- which(orig_meal$Sodium_mg == max(orig_meal$Sodium_mg))   # get index of food with max sodium
      print(paste0("index of max offender is ", max_sodium_offender))
      
      print(paste0("j is ", j))
      orig_meal[max_sodium_offender, ] <- randomized[j, ]
      
      sodium <- (sum(orig_meal$Sodium_mg * orig_meal$GmWt_1))/100
      print(paste0("sodium is now ", sodium))
    } else {
      break
    }
    print(paste0("sodium is now last", sodium))
  }
  orig_meal
}


lower_sodium2 <- resamp_sodium2(my_fourth_meal)
lower_sodium2

View(lower_sodium2)






# not done
# get_worst_foods_multiple <- function(dat, nut_vec, ...) {
#   for (nut in seq_along(nut_vec)) {
#     print(nut)
#     print(nut_vec[nut])
#    filtered <- dat %>% 
#       filter(nut_vec[nut] > mr_st_dev_join[mr_st_dev_join$nut_name==nut_vec[nut], ][["one_above"]])
#    filtered
#    print(filtered[1, ])
#   }
#   filtered
# }
# 
# get_worst_foods(abbrev, c("Lipid_Tot_g", "Sodium_mg"))





# tsne

colors = rainbow(length(unique(iris$Species)))
names(colors) = unique(iris$Species)
ecb = function(x,y){ plot(x,t='n'); text(x,labels=iris$Species, col=colors[iris$Species]) }
tsne_iris = tsne(iris[,1:4], epoch_callback = ecb, perplexity=50)



ab <- ab %>% na.omit()
colors = rainbow(length(unique(ab$Shrt_Desc)))
names(colors) = unique(ab$Shrt_Desc)

ecb = function (x,y) { 
  plot(x,t='n'); 
  text(x, labels=ab$Shrt_Desc, col=colors[ab$Shrt_Desc]) }

tsne_ab = tsne(ab[,3:6], epoch_callback = ecb, perplexity=20)







