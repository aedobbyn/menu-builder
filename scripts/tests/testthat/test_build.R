
source("./scripts/build.R")

test_that("build_menu() works as expected", {
          # Make sure from_better_cutoff can't be character
          expect_error(build_menu(abbrev, from_better_cutoff = "foo"))
          
          # Scale on the way
          x <- build_menu(abbrev, seed = 15, from_better_cutoff = 1)
          # Scaled score should be greater than or equal to the cutoff we set 
          expect_gte(x %>% summarise(mean_score = mean(scaled_score)) %>% as_vector(),
                     1)
          # Change ranks to scaled wrt this particular menu, so mean scaled score should be 0
          y <- x %>% add_ranked_foods()
          expect_lt(y %>% summarise(mean_score = mean(scaled_score)) %>% as_vector(),
                    1)
          # Make sure we have no dupes
          expect_equal(x$NDB_No %>% unique() %>% length(), 
                       nrow(x))
          
          # add_calories() works correctly; note that menu is the first argument to add_calories() and df is the first argument to build_menu()
          menu_too_low <- build_menu(abbrev) %>% slice(1:2)
          expect_equal(test_calories(menu_too_low), 
                       "Calories too low")
          expect_equal(add_calories(menu_too_low) %>% test_calories(), 
                       "Calorie compliant")

          })



# Either from_scratch must be FALSE or our_menu must not be NULL
expect_error(
  master_builder(from_scratch = FALSE)
)


