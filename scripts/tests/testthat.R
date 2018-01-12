
devtools::install_github("aedobbyn/dobtools")
library(dobtools)
library(testthat)
library(stringr)
library(feather)
library(tidyverse)

#### Load all scripts ####
dirs <- c("prep", "build", "score", "scrape", "solve")
paths <- str_c("./scripts/", dirs)

# Import all scripts from all the dirs above
dobtools::import_scripts(paths)


#### Load tests ####
path <- "./scripts/tests/testthat/"
test_types <- c("build", "scrape", "solve")
test_files <- str_c(path, str_c("test_", test_types), ".R")
# Add a fake file for testing purposes
fake_test <- "./scripts/tests/testthat/test_fake.R"
test_files <- c(fake_test, test_files)

# Run a test on just our small fake file
fake_test %>% dobtools::run_tests()

# Run all interactively
test_files %>% run_tests()

# Run silently and non-interactively
test_files %>% run_tests(line_by_line = FALSE)

