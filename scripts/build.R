
# Source in all scripts
source("./scripts/prep/abbrev.R")
source("./scripts/prep/stats.R")

# Building and tweaking scripts in /build_menu
path <- "./scripts/build_menu"
for (f in list.files(path, pattern = "*.R", ignore.case = TRUE)) {
  source(str_c(path, "/", f))
}

library(dobtools)
library(feather)

# --------- Build ---------

# Build our original menu
menu <- build_menu(abbrev, seed = 9)

