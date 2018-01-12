
# devtools::install_github("aedobbyn/dobtools")
library(dobtools)
library(testthat)
library(stringr)
library(feather)
library(tidyverse)

#### Load all scripts ####
dirs <- c("prep", "build", "score", "scrape", "solve")
paths <- str_c("./scripts/", dirs)

# Import all .R scripts from all the dirs above 
for (p in paths) {
  suppressPackageStartupMessages(dobtools::import_scripts(p))
}


#### Load tests ####
path <- "./scripts/tests/testthat/"  # Base directory
test_types <- c("build", "scrape", "solve")   # Patterns of file names that come after test_
test_files <- str_c(path, str_c("test_", test_types), ".R")   # Put together to get the file names of our tests
# Add a fake file for testing purposes
fake_test <- "./scripts/tests/testthat/test_fake.R"
# Compile all our test files together into a vector
test_files <- c(fake_test, test_files)

# Run a test on just our small fake file
fake_test %>% dobtools::run_tests()

# Run all interactively
test_files %>% run_tests()

# Run silently and non-interactively
test_files %>% run_tests(line_by_line = FALSE)

