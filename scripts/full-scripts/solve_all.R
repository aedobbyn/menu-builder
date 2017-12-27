# Test out the various permutations and options of the solving functions
source("./scripts/solve.R")

# ---------- Transpose ----------
# Take a look at what the constraing matrix will look like 
foo <- menu_unsolved_per_g %>% transpose_menu()
bar <- menu_unsolved_per_g %>% get_raw_vals() %>% transpose_menu()
baz <- menu_unsolved_raw %>% get_per_g_vals() %>% transpose_menu()

assertthat::are_equal(foo, baz)


# -------- Solutions, various ---------
solve_it(menu_unsolved_per_g, nutrient_df, only_full_servings = TRUE, 
         v_v_verbose = TRUE, min_food_amount = 0.5)$solution
solve_it(menu_unsolved_per_g, nutrient_df, only_full_servings = FALSE, 
         min_food_amount = -0.5)$solution

solve_it(menu_unsolved_raw, nutrient_df, df_is_per_100g = FALSE)
solve_it(menu_unsolved_per_g, nutrient_df, min_food_amount = -3)
solve_it(menu_unsolved_per_g, nutrient_df, min_food_amount = -1)

solution_raw <- solve_it(menu_unsolved_raw, nutrient_df, df_is_per_100g = FALSE, min_food_amount = 0.5)
solution_per_g <- solve_it(menu_unsolved_per_g, nutrient_df, df_is_per_100g = TRUE, min_food_amount = 0.5)
assertthat::are_equal(solution_raw$solution, solution_per_g$solution)


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


#  ------------  Score  ------------ 
score_menu(solved_menu)
score_menu(swapped_solved)


#   ------------ Single swapping  ------------ 
singly_swapped <- do_single_swap(solved_menu)


#  ------------ From the top  ------------ 
build_menu(abbrev, seed = 11) %>% 
  do_menu_mutates() %>% 
  solve_it(nutrient_df, min_food_amount = -1) %>% 
  solve_menu() %>% 
  do_single_swap(silent = TRUE)

