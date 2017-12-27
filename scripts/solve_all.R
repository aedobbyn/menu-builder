
source("./scripts/solve.R")


get_per_g_vals(menu_unsolved_raw)



# ---------- Transpose ----------
# Take a look at what the constraing matrix will look like 
foo <- menu_unsolved_per_g %>% transpose_menu()
bar <- menu_unsolved_per_g %>% get_raw_vals() %>% transpose_menu()
baz <- menu_unsolved_raw %>% get_per_g_vals() %>% transpose_menu()

# assertthat::are_equal(foo, baz)




# Solution

solve_it(menu_unsolved_per_g, nutrient_df, only_full_servings = TRUE, v_v_verbose = TRUE, min_food_amount = 0.5)$solution
solve_it(menu_unsolved_per_g, nutrient_df, only_full_servings = FALSE, min_food_amount = -0.5)$solution

solve_it(menu_unsolved_raw, nutrient_df, df_is_per_100g = FALSE)
solve_it(menu_unsolved_per_g, nutrient_df, min_food_amount = -3)

full_solution <- solve_it(menu_unsolved_per_g, nutrient_df, min_food_amount = -1)



# Menu

solve_menu(full_solution)
solved_menu <- menu_unsolved_per_g %>% solve_it(nutrient_df, min_food_amount = 1) %>% solve_menu()

compliant_solved <- solve_it(menu_unsolved_per_g, nutrient_df, 
                             only_full_servings = TRUE, min_food_amount = -2) %>% solve_menu()



# 


# Test compliance
solved_menu %>% test_all_compliance_verbose()
compliant_solved %>% test_all_compliance_verbose()




# Nutrients



# solve_nutrients(full_solution)
a <- menu_unsolved_per_g %>% 
  solve_it(nutrient_df, only_full_servings = TRUE, min_food_amount = -3) %>% 
  solve_nutrients()

b <- menu_unsolved_raw %>% 
  solve_it(nutrient_df, df_is_per_100g = FALSE, only_full_servings = TRUE, min_food_amount = -3) %>% 
  solve_nutrients()

solved_nutrients <- menu_unsolved_per_g %>% solve_it(nutrient_df) %>% solve_nutrients()




# all the way through


# -----------
# Start merging with old code

swapped_solved <- solved_menu %>% 
  select(NDB_No, Shrt_Desc, !!quo_nutrient_names, everything()) %>%  # get columns in old order
  smart_swap_single() 



score_menu(solved_menu)
score_menu(swapped_solved)



# Single swapping
singly_swapped <- do_single_swap(solved_menu)

build_menu(abbrev, seed = 11) %>% do_menu_mutates() %>% solve_it(nutrient_df, min_food_amount = -1) %>% 
  solve_menu() %>% 
  do_single_swap(silent = TRUE)