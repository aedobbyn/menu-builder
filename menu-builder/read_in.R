
import_scripts("./scripts/prep")
import_scripts("./scripts/build")
import_scripts("./scripts/score")
import_scripts("./scripts/solve")


abbrev <- read_feather("./data/abbrev_processed.feather")
scaled <- read_feather("./data/scaled.feather")

all_nut_and_mr_df <- read_feather("./data/all_nut_and_mr_df.feather")
nutrient_df <- read_feather("./data/nutrient_df.feather")
mr_df <- read_feather("./data/mr_df.feather")
pos_df <- read_feather("./data/pos_df.feather")


nutrient_names <- c(all_nut_and_mr_df$nutrient, "Energ_Kcal")
quo_nutrient_names <- quo(nutrient_names)
cols_to_keep <- c(nutrient_names, "Shrt_Desc", "GmWt_1", "NDB_No")

# Helper
see_diffs <- function(menu_1, menu_2) {
  diff <- setdiff(menu_1, menu_2) %>% 
    select(Shrt_Desc, GmWt_1)
  diff
}