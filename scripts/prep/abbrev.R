library(readxl)
library(tidyverse)
library(stringr)
library(dobtools)

source("./scripts/prep/do_menu_mutates.R")
import_scripts("./scripts/score")

# Read in the abbreviated dataframe
abbrev_raw <- readxl::read_excel("./data/raw/ABBREV.xlsx")
abbrev <- as_tibble(abbrev_raw)

# Remove parens and spaces from nutrient names
names(abbrev) <- str_replace_all(names(abbrev), "\\(", "") %>% 
  str_replace_all("\\)", "") %>% 
  str_replace_all(" ", "")


# -------------- Wrangle Nutrients -------------

# Get vector of must_restricts
must_restrict <- c("Lipid_Tot_g", "Carbohydrt_g", "Sugar_Tot_g", 
                   "FA_Sat_g", "FA_Mono_g", "FA_Poly_g", "Cholestrl_mg",
                   "Sodium_mg")

# These fields are neither must_restricts nor positives
not_nuts <- c("NDB_No", "Shrt_Desc", "Water_g", "Energ_Kcal",   # <--- Energ_Kcal could be considered a nutrient becuase it needs to be above a cerain threshold
              "GmWt_1", "GmWt_Desc1", "GmWt_2", "GmWt_Desc2", "Refuse_Pct")

# Everything that's not a must_restrict or a not_nut must be a positive
positives <- names(abbrev)[c((!names(abbrev) %in% must_restrict) & (!names(abbrev) %in% not_nuts))]


# Create dataframes consisting of key-value pairs between nutrients or must_restricts and their min or max values
# Based on PantryFoods, 100g Nutrient Data, only considering Calcium to B6
pos_nuts <- positives[c(1, 4:18)]
pos_vals <- c(56, 1000, 18, 400, 1000, 3500, 15, 2, 2, 70, 60, 2, 2, 20, 10, 2)

pos_df <- as_tibble(list(positive_nut = pos_nuts, value = pos_vals))


# Same for must_restricts
mr <- c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
mr_vals <- c(65, 2400, 300, 20)

mr_df <- as_tibble(list(must_restrict = mr, value = mr_vals))


# Combine all nuts and must_restricts
all_nut_and_mr_df <- rbind(mr_df %>% 
                             rename(nutrient = must_restrict),     
                           pos_df %>% 
                             rename(nutrient = positive_nut))


# Quosure the nutrient and must restrict names
nutrient_names <- c(all_nut_and_mr_df$nutrient, "Energ_Kcal")
quo_nutrient_names <- quo(nutrient_names)

# Add calorie restriction
nutrient_df <- all_nut_and_mr_df %>% 
  bind_rows(list(nutrient = "Energ_Kcal",     # Add calorie restriction in
                 value = 2300) %>% as_tibble()) %>%
  mutate(
    is_must_restrict = ifelse(nutrient %in% mr_df$must_restrict, TRUE, FALSE)
  )

# z-score all must_restricts and nutrients
scaled <- abbrev %>% 
  drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) %>% 
  mutate_at(
    vars(nutrient_names, "Energ_Kcal"), dobtools::z_score   # <-- equivalent to scale(), but simpler
  )

# -------------------------------------------------------

# Which columns to keep
cols_to_keep <- c(nutrient_names, "Shrt_Desc", "GmWt_1", "NDB_No")

# Do mutates and add scaled values to abbrev
abbrev <- abbrev %>% do_menu_mutates() %>% add_ranked_foods() 

# Ge our abbreviated dataframe without any NAs
abbrev_sans_na <- abbrev %>% 
  drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))



# write_feather(scaled, "./data/derived/scaled.feather")
# ln -s ~/Desktop/Earlybird/food-progress/data/derived/scaled.feather ~/Desktop/Earlybird/food-progress/menu-builder/data
# write_feather(all_nut_and_mr_df, "./data/derived/all_nut_and_mr_df.feather")
# write_feather(nutrient_df, "./data/derived/nutrient_df.feather")

# write_feather(mr_df, "./data/derived/mr_df.feather")
# write_feather(pos_df, "./data/derived/pos_df.feather")

# ln -s ~/Desktop/Earlybird/food-progress/data/derived/nutrient_df.feather ~/Desktop/Earlybird/food-progress/menu-builder/data

# ln -s ~/Desktop/Earlybird/food-progress/data/derived/all_nut_and_mr_df.feather ~/Desktop/Earlybird/food-progress/menu-builder/data
# ln -s ~/Desktop/Earlybird/food-progress/data/derived/mr_df.feather ~/Desktop/Earlybird/food-progress/menu-builder/data
# ln -s ~/Desktop/Earlybird/food-progress/data/derived/pos_df.feather ~/Desktop/Earlybird/food-progress/menu-builder/data

# ln -s ~/Desktop/Earlybird/food-progress/scripts/prep/ ~/Desktop/Earlybird/food-progress/menu-builder/scripts/prep


