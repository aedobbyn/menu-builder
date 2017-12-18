
# LP Solver
# https://r-forge.r-project.org/scm/viewvc.php/*checkout*/pkg/inst/doc/lpSolveAPI.pdf?revision=88&root=lpsolve

# GNU solver
# https://cran.r-project.org/web/packages/Rglpk/Rglpk.pdf

source("./scripts/menu_builder.R")

library(lpSolveAPI)
library(Rglpk)

# Pick a few nutrients to start with
pos_df_small <- pos_df[1:3, ] %>% rename(nutrient = positive_nut)
mr_df_small <- mr_df[1:3, ] %>% rename(nutrient = must_restrict)

# Simplify our menu space
cols_to_keep <- c(pos_df_small$positive_nut, mr_df$must_restrict, "Shrt_Desc", "Energ_Kcal", "GmWt_1")
menu_small <- menu[, which(names(menu) %in% cols_to_keep)] %>% 
  slice(1:3) %>% 
  mutate(
    shorter_desc = map_chr(Shrt_Desc, grab_first_word, splitter = ","), # Take only the fist word
    cost = runif(nrow(.), min = 1, max = 10) %>% round(digits = 2) # Add a cost column
  ) %>% 
  select(shorter_desc, GmWt_1, cost, everything(), -Shrt_Desc)


# -------  Rglpk example  -------
# One row per constraint
## maximize:   2 x_1 + 4 x_2 + 3 x_3
## subject to: 3 x_1 + 4 x_2 + 2 x_3 <= 60
##             2 x_1 + 1 x_2 + 2 x_3 <= 40
##             1 x_1 + 3 x_2 + 2 x_3 <= 80
obj_ex <- c(2, 4, 3)
mat_ex <- matrix(c(3, 4, 2, 
                   2, 1, 2, 
                   1, 3, 2), nrow = 3, byrow = TRUE)
dir_ex <- c("<=", "<=", "<=")
rhs_ex <- c(60, 40, 80)
max_ex <- TRUE
Rglpk_solve_LP(obj_ex, mat_ex, dir_ex, rhs_ex, max = max_ex)


# ---- Small example ----

# minimize: cherries::cost*cherries::GmWt_1 + cheese::cost*cheese::GmWt_1 + cereals::cost*cereals::GmWt_1
# subject to: 
# cherries::GmWt_1*Calcium_Mg + cheese::GmWt_1*Iron_mg + cereals::GmWt_1*Magnesium_mg > 1000, etc.

obj_fn <- c(2.29, 2.62, 3.88)

                  # Calcium,  Iron,   Magnesium
menu_mat <-   matrix(c(11,    0.36,   9,            # CHERRIES
                       1253,  0.87,   51,          # CHEESE
                       307,   11.30,  84),             # CEREALS
                     nrow = 3, byrow = TRUE)  
dir <- c(">", ">", ">")
rhs <- c(1000, 18, 400)    # Ca, Fe, Mg
solution <- Rglpk_solve_LP(obj_fn, menu_mat, dir, rhs, max = FALSE)


# --- Programmatically ---
solve_it <- function(df, nutrient_df, maximize = FALSE) {
  n_foods <- nrow(df)

  construct_matrix <- function(df, nutrient_df) {
    mat_base <- NULL
    for (i in 1:n_foods) {
      mat_base <- c(mat_base, df[i, ][nutrient_df[["nutrient"]]] %>% as_vector())
    }
    mat <- matrix(mat_base, nrow = n_foods, byrow = TRUE)
    return(mat)
  }
  
  mat <- construct_matrix(df, nutrient_df)
  message("Matrix below:")
  print(mat)
  
  dir <- rep(">", n_foods)
  rhs <- nutrient_df[["value"]]
  obj_fn <- df[["cost"]]
  
  out <- Rglpk_solve_LP(obj_fn, mat, dir, rhs, max = maximize)
  return(out)
}

solution_out <- solve_it(menu_small, pos_df_small)


# Test
assertthat::are_equal(solution$optimum, solution_out$optimum)


construct_matrix <- function(df) {
  mat_base <- NULL
  for (i in 1:n_foods) {
    mat_base <- c(mat_base, df[i, pos_df_small$positive_nut])
    mat <- matrix(mat_base, nrow = n_foods)
  }
  return(mat)
}

mat2 <- construct_matrix(menu_small)

dir2 <- rep(">", n_foods)

rhs2 <- pos_df_small$value

obj_fn2 <- menu_small[["cost"]]

out2 <- Rglpk_solve_LP(obj_fn2, mat2, dir2, rhs2, max = FALSE)


