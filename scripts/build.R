
# Source in all scripts
source("./scripts/prep/abbrev.R")

# Building and tweaking scripts in /build_menu
path <- "./scripts/build"
for (f in list.files(path, pattern = "*.R", ignore.case = TRUE)) {
  source(str_c(path, "/", f))
}

library(dobtools)
library(feather)
library(assertthat)


# --------- Build a menu ---------
menu <- build_menu(abbrev, seed = 9)

