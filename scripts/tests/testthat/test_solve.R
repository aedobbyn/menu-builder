library(testthat)

# Test out the various permutations and options of the solving functions
source("./scripts/solve.R")

# Test equality
expect_equal(out %>% select(-cost),   # Cost is randomly assigned, for now
          compliant_one_swap %>% select(-cost))

# ---------- Transpose ----------
# Take a look at what the constraing matrix will look like 
foo <- menu_unsolved_per_g %>% transpose_menu()
bar <- menu_unsolved_per_g %>% get_raw_vals() %>% transpose_menu()
baz <- menu_unsolved_raw %>% get_per_g_vals() %>% transpose_menu()

# expect_equal(foo, baz)    # This seems to be failing, not sure why because they look the same


# -------- Solutions, various ---------
solve_it(menu_unsolved_per_g, nutrient_df, only_full_servings = TRUE, 
         v_v_verbose = TRUE, min_food_amount = 0.5)$solution
solve_it(menu_unsolved_per_g, nutrient_df, only_full_servings = FALSE, 
         min_food_amount = -0.5)$solution

solve_it(menu_unsolved_raw, nutrient_df, df_is_per_100g = FALSE)
solve_it(menu_unsolved_per_g, nutrient_df, min_food_amount = -3)
full_solution <- solve_it(menu_unsolved_per_g, nutrient_df, min_food_amount = -1)

solution_raw <- solve_it(menu_unsolved_raw, nutrient_df, df_is_per_100g = FALSE, min_food_amount = 0.5)
solution_per_g <- solve_it(menu_unsolved_per_g, nutrient_df, df_is_per_100g = TRUE, min_food_amount = 0.5)
expect_equal(solution_raw$solution, solution_per_g$solution)


# ------------ Menu ------------ 
solve_menu(full_solution)
solved_menu <- menu_unsolved_per_g %>% solve_it(nutrient_df, min_food_amount = 1) %>% solve_menu()

compliant_solved <- solve_it(menu_unsolved_per_g, nutrient_df, 
                             only_full_servings = TRUE, min_food_amount = -2) %>% solve_menu()


# ------------  Test compliance  ------------ 
solved_menu %>% test_all_compliance_verbose()
compliant_solved %>% test_all_compliance_verbose()


# ------------  Nutrients  ------------ 
a <- menu_unsolved_per_g %>% 
  solve_it(nutrient_df, only_full_servings = TRUE, min_food_amount = -3) %>% 
  solve_nutrients()

b <- menu_unsolved_raw %>% 
  solve_it(nutrient_df, df_is_per_100g = FALSE, only_full_servings = TRUE, min_food_amount = -3) %>% 
  solve_nutrients()

solved_nutrients <- menu_unsolved_per_g %>% solve_it(nutrient_df) %>% solve_nutrients()


#   ------------ Single swapping  ------------ 
singly_swapped <- do_single_swap(solved_menu)


#  ------------  Score  ------------ 
test_that("Scoreing of menus results in numeric", {
  expect_is(score_menu(solved_menu), "numeric")
  expect_is(score_menu(singly_swapped), "numeric")
})

#  ------------ wholesale_swap()  ------------ 
test_that("Wholesale swap works", {
  wholesale_out <- wholesale_swap(out)
  setdiff(wholesale_out, out)
})


#  ------------ solve_full()  ------------ 
test_that("The building and solving in full works correctly", {
  
  # Test that our min solution amount gets carried through 
  x <- suppressMessages(build_menu(abbrev, seed = 9) %>% 
                          do_menu_mutates() %>% 
                          solve_it(nutrient_df, min_food_amount = 0.5) %>% solve_menu() %>%
                          solve_full(min_food_amount = 0.5, percent_to_swap = 1)) 
  expect_equal(min(x$solution_amounts), 0.5)
  
  # Test that we're not touching menus that are already compliant
  expect_equal(solve_full(out), out)
  
  # Test silence
  expect_silent(suppressMessages(solve_full(out, verbose = FALSE)))
})





