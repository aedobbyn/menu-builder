
import_scripts("./scripts/prep")
import_scripts("./scripts/build")
import_scripts("./scripts/score")
import_scripts("./scripts/solve")

abbrev <- read_feather("./data/abbrev_processed.feather")
scaled <- read_feather("./data/scaled.feather")
all_nut_and_mr_df <- read_feather("./data/all_nut_and_mr_df.feather")
mr_df <- read_feather("./data/mr_df.feather")
pos_df <- read_feather("./data/pos_df.feather")
