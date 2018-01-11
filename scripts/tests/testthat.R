
source("./helpers/import_scripts.R")
library(testthat)
library(stringr)
library(feather)
library(tidyverse)

# Load all scripts
dirs <- c("prep", "build", "score", "scrape", "solve")
paths <- str_c("./scripts/", dirs)


# import_scripts(paths)

for (p in paths) {
  for (f in list.files(p, pattern = "*.R", ignore.case = TRUE)) {
    source(str_c(p, "/", f))
  }
}

# Load tests
path <- "./scripts/tests/testthat/"
tests <- c("build", "scrape", "solve")
test_files <- str_c(path, str_c("test_", tests))


# Run individual tests interactively or not
run_tests <- function(line_by_line = TRUE, pattern = ".R") {
  files <- str_c(test_files, pattern)
  
  if (line_by_line == FALSE | interactive() == FALSE) {
    for (f in files) {
      result <- try(source(f), silent = TRUE)
      if (class(result) != "try-error") {
        message("Passed")
      } else {
        message("Failed")
      }
    }
  } else {
    for (f in files) {
      answer <- readline(paste0("Should we test ", f, " ? \n y/n:       "))
      if (answer == "y" | answer == "Y") {
        result <- try(source(f))
      } else {
        message(paste0("Ok; not testing ", f, "."))
      }
    }
  } 
}

run_tests()







