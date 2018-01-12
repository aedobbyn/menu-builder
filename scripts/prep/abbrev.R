library(readxl)
library(tidyverse)
library(stringr)
library(hash)

abbrev <- readxl::read_excel("./data/ABBREV.xlsx")
abbrev <- as_tibble(abbrev)

# remove parens and spaces from names
names(abbrev) <- str_replace_all(names(abbrev), "\\(", "") %>% 
  str_replace_all("\\)", "") %>% 
  str_replace_all(" ", "")

# get vector of must restricts
must_restrict <- c("Lipid_Tot_g", "Carbohydrt_g", "Sugar_Tot_g", 
                   "FA_Sat_g", "FA_Mono_g", "FA_Poly_g", "Cholestrl_mg",
                   "Sodium_mg")

# these fields are neither must_restricts nor positives
not_nuts <- c("NDB_No", "Shrt_Desc", "Water_g", "Energ_Kcal", 
              "GmWt_1", "GmWt_Desc1", "GmWt_2", "GmWt_Desc2", "Refuse_Pct")

# everything that's not a must_restrict or a not_nut must be a positive
positives <- names(abbrev)[c((!names(abbrev) %in% must_restrict) & (!names(abbrev) %in% not_nuts))]


# Based on PantryFoods, 100g Nutrient Data, only considering Calcium to B6
pos_nuts <- positives[c(1, 4:18)]
pos_vals <- c(56, 1000, 18, 400, 1000, 3500, 15, 2, 2, 70, 60, 2, 2, 20, 10, 2)

pos_df <- as_tibble(list(positive_nut = pos_nuts, value = pos_vals))
pos_hash <- hash(pos_nuts, pos_vals)


# Same for must_restricts
mr <- c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
mr_vals <- c(65, 2400, 300, 20)

mr_df <- as_tibble(list(must_restrict = mr, value = mr_vals))
mr_hash <- hash(mr, mr_vals)


# Combine all nuts and must_restricts
all_nut_and_mr_df <- rbind(mr_df %>% 
                             rename(nutrient = must_restrict),     
                           pos_df %>% 
                             rename(nutrient = positive_nut))

