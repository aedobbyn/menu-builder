
source("./helpers/import_scripts.R")
library(testthat)
library(stringr)
library(feather)
library(tidyverse)

#### Load all scripts ####
dirs <- c("prep", "build", "score", "scrape", "solve")
paths <- str_c("./scripts/", dirs)


# import_scripts(paths)

for (p in paths) {
  for (f in list.files(p, pattern = "*.R", ignore.case = TRUE)) {
    source(str_c(p, "/", f))
  }
}



#### Load tests ####
path <- "./scripts/tests/testthat/"
test_types <- c("build", "scrape", "solve")
test_files <- str_c(path, str_c("test_", test_types), ".R")
# Add a fake file for testing purposes
test_files <- c("./scripts/tests/testthat/test_fake.R", test_files)


# Return whether an individual test passed or not
test_it <- function(f, verbose = FALSE) {
  if (verbose == FALSE) {
    result <- suppressMessages(suppressWarnings(try(source(f), silent = TRUE)))
  } else {
    result <- try(source(f), silent = TRUE)
  }
  
  if (inherits(result, "try-error")) {
    message(paste0(" --- ", f, " FAILED --- "))
  } else {
    message(paste0(" --- ", f, " PASSED --- "))
  }
}


# Run individual tests interactively or not
run_tests <- function(files = NULL, ext = NULL, line_by_line = TRUE) {
  files <- str_c(files, ext)

  if (line_by_line == FALSE ) {  # | interactive() == FALSE
    for (i in seq_along(files)) {
      test_it(files[i])
    }
    
  } else {
    i <- 1
      while (i <= length(files)) {
        answer <- readline(paste0("Should we test ", files[i], " ? \n y/n:       "))
        
        if (answer == "y" | answer == "Y") {
          test_it(files[i])
          i <- i + 1
          
        } else if (answer == "n" | answer == "N") {
          message(paste0("Ok; not testing ", files[i], "."))
          i <- i + 1
          
        } else if (answer == "q" | answer == "Q") {
          message("Quitting tests.")
          break
          
        } else {
          message("Unrecognized choice submitted. Trying again.")
          i <- i    # Step back one
        }
    }
  } 
}

# Run interactively
test_files %>% run_tests()

# Run silently and non-interactively
test_files %>% run_tests(line_by_line = FALSE)

