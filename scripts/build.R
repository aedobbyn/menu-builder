
library(dobtools)
library(feather)
library(assertthat)

import_scripts("./scripts/prep")
import_scripts("./scripts/build")

# --------- Build a menu ---------
menu <- build_menu(abbrev, seed = 9)

# write_feather(abbrev, "./data/derived/abbrev_processed.feather")
# ln -s ~/Desktop/Earlybird/food-progress/data/derived/abbrev_processed.feather ~/Desktop/Earlybird/food-progress/menu-builder/data/abbrev_processed.feather