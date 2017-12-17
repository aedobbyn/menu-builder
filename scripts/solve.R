
# Solver
# https://r-forge.r-project.org/scm/viewvc.php/*checkout*/pkg/inst/doc/lpSolveAPI.pdf?revision=88&root=lpsolve

source("./scripts/menu_builder.R")

library(lpSolveAPI)

pos_df_small <- pos_df[1:3, ]
mr_df_small <- mr_df[1:3, ]

# Constraints on all nutrients, must_restrics, and on calories
# Vary GmWt_1
# Optimize cost
lp <- make.lp((nrow(pos_df_small) + nrow(mr_df_small) + 1), 1)

# Keep only columns we care about
cols_to_keep <- c(pos_df_small$positive_nut, mr_df$must_restrict, "Shrt_Desc", "Energ_Kcal", "GmWt_1")
menu_small <- menu[, which(names(menu) %in% cols_to_keep)]

# Add a cost column
menu_small$cost <- runif(nrow(menu_small), min = 1, max = 10) %>% round(digits = 2)


# ---- Minimize cost
# cost = cost * GmWt_1

# ----- Constraints
# # Example
# subject to: x1 + 3x2 ≤ 4
#             x1 + x2 ≤ 2
#             2x1 + ≤ 3
# set.column(lp, 1, c(1, 1, 2))
# set.column(lp, 2, c(3, 1, 0))
# set.rhs(lp, c(4, 2, 3))


# calories = Energ_Kcal * GmWt_1

# ----- Set constraints
# Calcium_mg * GmWt_1 > 1000
# Iron_mg * GmWt_1 > 18
# Magnesium_mg * GmWt_1 > 400

set.column(lp, 1, c(1, 1, 1000))
set.column(lp, 2, c(1, 1, 0))
set.column(lp, 3, c(1, 1, 0))
set.rhs(lp, c(1000, 18, 400))


row_names <- c("Nutrient", "GmWt_1")
col_names <- c(pos_df_small$positive_nut, mr_df$must_restrict, "Calories")

dimnames(lp) <- list(RowNames, ColNames)



  
  
  
  
  ## Simple linear program.
  ## maximize: 2 x_1 + 4 x_2 + 3 x_3
  ## subject to: 3 x_1 + 4 x_2 + 2 x_3 <= 60
  ## 2 x_1 + x_2 + 2 x_3 <= 40
  ## x_1 + 3 x_2 + 2 x_3 <= 80
  ## x_1, x_2, x_3 are non-negative real numbers
library(Rglpk)
obj <- c(2, 4, 3)
mat <- matrix(c(3, 2, 1, 4, 1, 3, 2, 2, 2), nrow = 3)
dir <- c("<=", "<=", "<=")
rhs <- c(60, 40, 80)
max <- TRUE
Rglpk_solve_LP(obj, mat, dir, rhs, max = max)
