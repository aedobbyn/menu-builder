library(readxl)
library(tidyverse)
library(stringr)
library(hash)

abbrev <- readxl::read_excel("./ABBREV.xlsx")
abbrev <- as_tibble(abbrev)

# remove parens and spaces from names
names(abbrev) <- str_replace_all(names(abbrev), "\\(", "")
names(abbrev) <- str_replace_all(names(abbrev), "\\)", "")
names(abbrev) <- str_replace_all(names(abbrev), " ", "")
names(abbrev)


# get vector of must restricts
must_restrict <- c("Lipid_Tot_g", "Carbohydrt_g", "Sugar_Tot_g", 
                   "FA_Sat_g", "FA_Mono_g", "FA_Poly_g", "Cholestrl_mg",
                   "Sodium_(mg)")

# these fields are neither must_restricts nor positives
not_nuts <- c("NDB_No", "Shrt_Desc", "Water_g", "Energ_Kcal", 
              "GmWt_1", "GmWt_Desc1", "GmWt_2", "GmWt_Desc2", "Refuse_Pct")

# everything that's not a must_restrict or a not_nut must be a positive
positives <- names(abbrev)[c((!names(abbrev) %in% must_restrict) & (!names(abbrev) %in% not_nuts))]
positives



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


# means and standard deviations
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











