
library(testthat)
library(stringr)

# Load all scripts
dirs <- c("prep", "build", "score", "scrape", "solve")
paths <- str_c("./scripts/", dirs)

for (p in paths) {
  for (f in list.files(p, pattern = "*.R", ignore.case = TRUE)) {
    source(str_c(p, "/", f))
  }
}

# Load tests
path <- "./scripts/tests/testthat/"
tests <- c("build", "scrape", "solve")
test_files <- str_c(path, tests)

for (f in list.files(test_files, pattern = "*.R", ignore.case = TRUE)) {
  source(str_c(test_files))
}

source("./scripts/tests/testthat/test_build.R")
source("./scripts/tests/testthat/test_scrape.R")
source("./scripts/tests/testthat/test_solve.R")