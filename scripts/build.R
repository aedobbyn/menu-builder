
library(dobtools)
library(feather)
library(assertthat)

import_scripts("./scripts/prep")
# source("./scripts/prep/abbrev.R")      
import_scripts("./scripts/build")

# --------- Build a menu ---------
menu <- build_menu(abbrev, seed = 9)

