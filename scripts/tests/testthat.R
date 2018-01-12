
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
  # files <- "./scripts/tests/testthat/test_fake.R"
  
  if (line_by_line == FALSE ) {  # | interactive() == FALSE
    for (f in files) {
      source(f)
    }
  } else {
    for (i in seq_along(files)) {
      while (i <= 1:length(files)) {
        answer <- readline(paste0("Should we test ", files[i], " ? \n y/n:       "))
        if (answer == "y" | answer == "Y") {
          i <- i + 1
          result <- try(source(files[i]), silent = TRUE)
          
          if (inherits(result, "try-error")) {
            message(" --- Failed --- ")
          } else {
            message(" --- Passed --- ")
          }
          
        } else if (answer == "n" | answer == "N") {
          i <- i + 1
          message(paste0("Ok; not testing ", files[i], "."))
          
        } else {
          i <- i - 1
          message("Unrecognized choice submitted.")
        }
      }
    }
  } 
}

run_tests()

suppressMessages(suppressWarnings(run_tests())) 







