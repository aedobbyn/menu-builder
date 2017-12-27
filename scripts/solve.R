# Use the GNU solver linear program solver to get from a random menu to a compliant
# menu, if possible, by adjusting food portions
library(Rglpk)
devtools::install_github("aedobbyn/dobtools", force = FALSE) ; library(dobtools)

source("./helpers/helpers.R")
source("./scripts/build.R")   # Load all original menu building and tweaking functions but 
                              # only create the original menu (with seed = 9)
  
# Load solving scripts in /solve
path <- "./scripts/solve"
for (f in list.files(path, pattern = "*.R", ignore.case = TRUE)) {
  source(str_c(path, "/", f))
}

# Get menu into formats we can use
menu_unsolved_per_g <- do_menu_mutates(menu)   # Nutrients per 100g

# Get raw weight of nutrients
menu_unsolved_raw <- get_raw_vals(menu_unsolved_per_g)  # Reverse with get_per_g_vals()

# Transpose menu
menu_transposed <- menu_unsolved_raw %>% get_per_g_vals() %>% transpose_menu()

# Run solve_it()
solution <- solve_it(menu_unsolved_raw, nutrient_df, df_is_per_100g = FALSE, min_food_amount = 0.5)
compliant_solution <- solve_it(menu_unsolved_per_g, nutrient_df, min_food_amount = -1)

# Solve nutrients
solved_nutrinets <- solution %>% solve_nutrients()
compliant_nutrinets <- compliant_solution %>% solve_nutrients()

# Run solve_menu()
solved_menu <- solution %>% solve_menu()
compliant_menu <- compliant_solution %>% solve_menu()

# Test compliance 
solved_menu %>% test_all_compliance_verbose()
compliant_menu %>% test_all_compliance_verbose()

# Swap a single 
solved_one_swap <- solved_menu %>% do_single_swap()
compliant_one_swap <- compliant_menu %>% do_single_swap()

# Full thing from beginning to end
out <- build_menu(abbrev, seed = 9) %>% 
  do_menu_mutates() %>% 
  solve_it(nutrient_df, min_food_amount = -1) %>% 
  solve_menu() %>% 
  do_single_swap(silent = TRUE)

# Test equality
are_equal(out %>% select(-cost),   # Cost is randomly assigned, for now
          compliant_one_swap %>% select(-cost))
