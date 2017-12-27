# GNU solver
# https://cran.r-project.org/web/packages/Rglpk/Rglpk.pdf

source("./scripts/build.R")   # Load all original menu building and tweaking functions but 
# only create the original menu
source("./helpers/helpers.R")  
library(Rglpk)

# Building and tweaking scripts in /build_menu
path <- "./scripts/solve"
for (f in list.files(path, pattern = "*.R", ignore.case = TRUE)) {
  source(str_c(path, "/", f))
}

menu_unsolved_per_g <- do_menu_mutates(menu)
menu_unsolved_raw <- get_raw_vals(menu_unsolved_per_g)