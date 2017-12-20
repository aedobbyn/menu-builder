
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

                     # Ca,     Fe,    Mg,   Lipid,   Na,   Chol
menu_mat <-   matrix(c(11,    0.36,   9,     0.13,    1,    0,             # CHERRIES
                       1253,  0.87,   51,    27.34,   1696, 72,            # CHEESE
                       307,   11.30,  84,     6.37,   499,  0 ),           # CEREALS
                     nrow = 6, byrow = TRUE)  
dir <- c(">", ">", ">", "<", "<", "<")
rhs <- c(1000, 18, 400, 65, 2400, 300)    # Ca, Fe, Mg, Lipid, Na, Chol
solution <- Rglpk_solve_LP(obj_fn, menu_mat, dir, rhs, max = FALSE)

# Cost is solution$optimum

# cbind the solved amounts to the original menu
solved_col <- list(solution_amounts = solution$solution) %>% as_tibble()
menu_small_solved <- menu_small %>% bind_cols(solved_col) %>% 
  select(shorter_desc, solution_amounts, everything())

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
  message(paste0("Cost is ", out$optimum))
  
  return(out)
}

solution_out <- solve_it(menu_small, pos_df_small)


# # Test
# assertthat::are_equal(solution$optimum, solution_out$optimum)



# Take a menu and return a solved menu
solve_menu <- function(df, nutrient_df) {
  sol <- df %>% solve_it(nutrient_df)
  
  df_solved <- df %>% bind_cols(solved_col) %>% 
    select(shorter_desc, solution_amounts, everything())
  
  max_food <- df_solved %>% filter(solution_amounts == max(solution_amounts))   # modify for if we've got mult maxes
  
  message(paste0("We've got a lot of ", max_food$shorter_desc), ". ", 
          solution_amounts, " of it.")
  
  return(df_solved)
}

