
# LP Solver
# https://r-forge.r-project.org/scm/viewvc.php/*checkout*/pkg/inst/doc/lpSolveAPI.pdf?revision=88&root=lpsolve

# GNU solver
# https://cran.r-project.org/web/packages/Rglpk/Rglpk.pdf

source("./scripts/menu_builder.R")

library(feather)
library(lpSolveAPI)
library(Rglpk)


# Simplify our menu space
cols_to_keep <- c(pos_df_small$positive_nut, mr_df$must_restrict, "Shrt_Desc", "Energ_Kcal", "GmWt_1")
menu_small <- menu[, which(names(menu) %in% cols_to_keep)] %>% 
  slice(1:3) %>% 
  mutate(
    shorter_desc = map_chr(Shrt_Desc, grab_first_word, splitter = ","), # Take only the fist word
    cost = runif(nrow(.), min = 1, max = 10) %>% round(digits = 2) # Add a cost column
  ) %>% 
  select(shorter_desc, GmWt_1, cost, everything(), -Shrt_Desc)

# OR, read in
menu_small <- read_feather(menu_small, "./data/menu_small.feather")



# Pick a few nutrients to start with and give them a flag for whether they're a must-restrict or not
pos_df_small <- pos_df[1:3, ] %>% rename(nutrient = positive_nut) %>% 
  mutate(is_mr = FALSE)
mr_df_small <- mr_df[1:3, ] %>% rename(nutrient = must_restrict) %>% 
  mutate(is_mr = TRUE)
nut_df_small <- bind_rows(pos_df_small, mr_df_small)




# ---- Small example ----
# -- minimize: 
    # cherries::cost*cherries::GmWt_1 + cheese::cost*cheese::GmWt_1 + cereals::cost*cereals::GmWt_1
# -- subject to: 
    # cherries::GmWt_1*Calcium_Mg + cheese::GmWt_1*Iron_mg + cereals::GmWt_1*Magnesium_mg > 1000, etc.

obj_fn <- c(2.29, 2.62, 3.88)

                     # Ca,     Fe,    Mg,   
menu_mat <-   matrix(c(11,    0.36,   9,        # > 1000      # CHERRIES      
                       1253,  0.87,   51,       # > 18        # CHEESE
                       307,   11.30,  84,       # > 65        # CEREALS
                     # Lipid,   Na,   Chol
                       0.13,    1,    0,        # < 65        # CHERRIES
                       27.34,   1696, 72,       # < 2400      # CHEESE
                       6.37,    499,  0),       # < 300       # CEREALS
                  nrow = 6, byrow = TRUE)  

dir <- c(">", ">", ">", "<", "<", "<")
rhs <- c(1000, 18, 400, 65, 2400, 300)    # Ca, Fe, Mg, Lipid, Na, Chol
solution <- Rglpk_solve_LP(obj_fn, menu_mat, dir, rhs, max = FALSE)

# Cost is solution$optimum

# cbind the solved amounts to the original menu
solved_col <- list(solution_amounts = solution$solution) %>% as_tibble()

menu_small_solved <- menu_small %>% bind_cols(solved_col) %>% 
  select(shorter_desc, solution_amounts, solution_nutrient_vals, everything())

solved_nutrient_vals <- list(solution_nutrient_vals = solution$auxiliary$primal) %>% as_tibble()

nut_df_small_solved <- nut_df_small %>% bind_cols(solved_nutrient_vals) 

# What's the max solution amount? If too high, may need to adjust down 
max_solution_amount <- solution$solution[which(solution$solution == max(solution$solution))]








# --- Programmatically ---
solve_it <- function(df, nutrient_df, maximize = FALSE) {
  n_foods <- nrow(df)

  construct_matrix <- function(df, nutrient_df) {
    mat_base <- NULL
    for (i in 1:n_foods) {
      mat_base <- c(mat_base, df[i, ][nutrient_df[["nutrient"]]] %>% as_vector())
    }
    mat <- matrix(mat_base, nrow = nrow(nutrient_df), byrow = TRUE)
    return(mat)
  }
  
  mat <- construct_matrix(df, nutrient_df)
  message("Matrix below:")
  print(mat)
  
  dir_pos <- rep(">", nutrient_df %>% filter(is_mr == FALSE) %>% ungroup() %>% count() %>% as_vector())
  dir_mr <- rep("<", nutrient_df %>% filter(is_mr == TRUE) %>% ungroup() %>% count() %>% as_vector())
  
  dir <- c(dir_pos, dir_mr)
  rhs <- nutrient_df[["value"]]
  obj_fn <- df[["cost"]]
  
  out <- Rglpk_solve_LP(obj_fn, mat, dir, rhs, max = maximize)
  out <- append(list(original_menu = df), out)
  out <- append(out, list(necessary_nutrients = nutrient_df))
  # out <- unlist(out, recursive = FALSE)
  message(paste0("Cost is ", round(out$optimum, digits = 2))) 
  
  return(out)
}
# Return a solution that contains the original menu as the first item in the list 
solve_it(menu_small, nut_df_small)

solution_out_list <- solve_it(menu_small, nut_df_small)

solution_out <- solve_it(menu_small, nut_df_small)


# # Test
# assertthat::are_equal(solution$optimum, solution_out$optimum)



# Take a menu and a solution and cbind them 
solve_menu <- function(sol) {
  
  solved_col <-  list(solution_amounts = sol$solution) %>% as_tibble()
  
  df_solved <- sol$original_menu %>% bind_cols(solved_col) %>% 
    select(shorter_desc, solution_amounts, everything())
  
  max_food <- df_solved %>% filter(solution_amounts == max(df_solved$solution_amounts))   # modify for if we've got mult maxes
  
  message(paste0("We've got a lot of ", max_food$shorter_desc %>% as_vector()), ". ", 
          max_food$solution_amounts %>% round(digits = 2), " grams of it.")
  
  return(df_solved)
}

solve_menu(solution_out_list)

menu_small %>% solve_it(nut_df_small) %>% solve_menu()


# Take a menu and a solution and get the nutrient vals
solve_nutrients <- function(sol) {
  # browser()
  
  solved_nutrient_vals <- list(solution_nutrient_vals = sol$auxiliary$primal) %>% as_tibble()
  
  nut_df_small_solved <- sol$necessary_nutrients %>% bind_cols(solved_nutrient_vals) 
  
  ratios <- nut_df_small_solved %>% 
    mutate(
      ratio = solution_nutrient_vals/value
    )
  
  max_pos_overshot <- ratios %>% 
    filter(is_mr == FALSE) %>% 
    filter(ratio == max(.$ratio))
  
  message(paste0("We've overshot on ", max_pos_overshot$nutrient %>% as_vector()), 
          ". The ratio of what we have to what we need is ", 
          max_pos_overshot$solution_nutrient_vals %>% round(digits = 2), ".")

  return(nut_df_small_solved)
}

menu_small %>% solve_it(nut_df_small) %>% solve_nutrients()

