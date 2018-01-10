
source("./scripts/build_menu.R")


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

          })


x <- add_calories(seed = 4)
x$NDB_No %>% unique() %>% length()
nrow(x)

menu_too_low <- build_menu(abbrev) %>% smart_swap()
test_calories(menu_too_low)
menu_too_low %>% add_calories() %>% test_calories


# Either from_scratch must be FALSE or our_menu must not be NULL
expect_error(
  master_builder(from_scratch = FALSE)
)


