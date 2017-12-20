

# Constraints on all nutrients, must_restrics, and on calories
# Vary GmWt_1
# Optimize cost
# lp <- make.lp((nrow(pos_df_small) + nrow(mr_df_small) + 1), 2)
lp <- make.lp(nrow(pos_df_small), 2)

# -- Set dimnames --
# Constraints in rows
# row_names <- c(pos_df_small$positive_nut, mr_df$must_restrict, "Calories")
row_names <- c(pos_df_small$positive_nut)
col_names <- c("Nutrient", "GmWt_1", "Cost")

dimnames(lp) <- list(row_names, col_names)




# 



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

# First column
set.column(lp, 1, c(1, 1, 1000))
# Second column
set.column(lp, 2, c(1, 1, 0))
# Third column
set.column(lp, 3, c(1, 1, 0))
set.rhs(lp, c(1000, 18, 400))
set.constr.type(my.lp, rep(">", 3))   # third column
set.objfn(my.lp, c(0, 1, 1))  # minimize product of GmWt_1 (column 2) and Cost (column 3)











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




# same as their example

obj <- c(2, 4, 3)
mat <- matrix(c(3, 2, 1, 
                4, 1, 3, 
                2, 2, 2), nrow = 3)
dir <- c("<=", "<=", "<=")
rhs <- c(60, 40, 80)
max <- TRUE
Rglpk_solve_LP(obj, mat, dir, rhs, max = max)

