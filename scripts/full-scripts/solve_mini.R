
# LP Solver
# https://r-forge.r-project.org/scm/viewvc.php/*checkout*/pkg/inst/doc/lpSolveAPI.pdf?revision=88&root=lpsolve

# GNU solver
# https://cran.r-project.org/web/packages/Rglpk/Rglpk.pdf

source("./scripts/solve.R")

# Pick a few nutrients to start with and give them a flag for whether they're a must-restrict or not
pos_df_small <- pos_df[1:3, ] %>% bind_rows(list(positive_nut = "Energ_Kcal", 
                                                 value = 2300) %>% as_tibble()) %>%
  rename(nutrient = positive_nut) %>% 
  mutate(is_must_restrict = FALSE)
mr_df_small <- mr_df[1:3, ] %>% rename(nutrient = must_restrict) %>% 
  mutate(is_must_restrict = TRUE)
nut_df_small <- bind_rows(mr_df_small, pos_df_small)

# Get our test menu
get_menu_small <- function(from_file = FALSE) {
  
  if (from_file == TRUE) {
    menu_small <- read_feather("./data/menu_small.feather")
    
  } else {
    # Simplify our menu space
    cols_to_keep <- c(pos_df_small$nutrient, mr_df$must_restrict, "Shrt_Desc", "GmWt_1")
    menu_small <- menu[, which(names(menu) %in% cols_to_keep)] %>% 
      slice(1:3) %>% 
      mutate(
        shorter_desc = map_chr(Shrt_Desc, grab_first_word, splitter = ","), # Take only the fist word
        cost = runif(nrow(.), min = 1, max = 10) %>% round(digits = 2), # Add a cost column
        serving_gmwt = GmWt_1
      ) %>% 
      select(shorter_desc, GmWt_1, serving_gmwt, cost, everything(), -Shrt_Desc)
  }
  
  return(menu_small)
}

# Assign
menu_small <- get_menu_small()
# write_feather(menu_small, "./data/menu_small.feather")


# Get names in correct order
quo_nut_small_names <- quo(c(mr_df_small$nutrient, pos_df_small$nutrient))

menu_small <- menu_small %>% 
  select(shorter_desc, GmWt_1, serving_gmwt, cost, !!quo_nut_small_names) %>%
  get_raw_vals(nut_df_small)

# ---- Small example ----
# Transpose our menu such that it looks like the matrix of constraints we're about to create
# with foods as the columns and nutrients as the rows
transposed_menu <- menu_small %>% select(-shorter_desc) %>% 
  t() %>% as_data_frame() %>% 
  rename(
    CHERRIES = V1,
    CHEESE = V2,
    CEREALS = V3
  ) %>% mutate(
    col = names(menu_small)[2:length(names(menu_small))]
  ) %>% 
  select(col, everything())


# # # # # # # # # # # # # # # # # # Manual solution creation # # # # # # # # # # # # # # #
obj_fn <- c(9.40, 9.97, 5.83)

# Ca,     Fe,    Mg,   
menu_mat <-   matrix(c(
  # CHERRIES  CHEESE     CEREALS 
  0.2560,     1.3670,    5.2938,   # Lipid
  17.92,      84.80,     27.54,   # Na
  0.000,      3.60,      1.02,   # Chol
  25.60,      62.65,     51.51,  # Ca,   
  3.3280,     0.0435,    1.3719,   # Fe
  15.36,      2.55,      56.10,   # Mg
  232.96,     20.75,     210.12),  # cals
  nrow = 7, byrow = TRUE)  


dir <- c("<", "<", "<", ">", ">", ">", ">")
rhs <- c(65, 2400, 300, 1000, 18, 400, 2300)    # Ca, Fe, Mg, Lipid, Na, Chol, cals
bounds <- list(lower = list(ind = c(1L, 2L, 3L), 
                            val = c(1, 1, 1)),
               upper = list(ind = c(1L, 2L, 3L),
                            val = c(100, 100, 100)))
solution_manual <- Rglpk_solve_LP(obj_fn, menu_mat, dir, rhs, bounds, max = FALSE)

constraint_mat <- menu_mat %>% as_data_frame() 
names(constraint_mat) <- menu_small$shorter_desc
constraint_mat <- constraint_mat %>% 
  mutate(
    dir = dir,
    rhs = rhs
  ) %>% left_join(nut_df_small, by = c("rhs" = "value")) %>% 
  select(nutrient, everything())

# cbind the solved amounts to the original menu
solved_col <- list(solution_amounts = solution_manual$solution) %>% as_tibble()

menu_small_solved <- menu_small %>% bind_cols(solved_col) %>% 
  select(shorter_desc, solution_amounts, everything())

solved_nutrient_vals <- list(solution_nutrient_vals = solution_manual$auxiliary$primal) %>% as_tibble()

nut_df_small_solved <- nut_df_small %>% bind_cols(solved_nutrient_vals) 

# What's the max solution amount? If too high, may need to adjust down 
max_solution_amount <- solution_manual$solution[which(solution_manual$solution == max(solution_manual$solution))]

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


# # # # # # # # # # # # # Programmatic solution creation # # # # # # # # # # # # # # # # # # # # # # # #

# solve_it(menu_small, nut_df_small, only_full_servings = FALSE)
solution_auto <- solve_it(menu_small, nut_df_small, df_is_per_100g = FALSE)


# solve_menu(solution_auto)
solved_menu_small <- menu_small %>% solve_it(nut_df_small, df_is_per_100g = FALSE) %>% solve_menu()


# solve_nutrients(solution_auto)
solved_nutrients_small <- menu_small %>% solve_it(nut_df_small, df_is_per_100g = FALSE) %>% solve_nutrients()


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# # Test that the manual and programmatic solution are the same
assertthat::are_equal(solution_manual$solution, solution_auto$solution)



