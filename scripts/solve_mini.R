
# LP Solver
# https://r-forge.r-project.org/scm/viewvc.php/*checkout*/pkg/inst/doc/lpSolveAPI.pdf?revision=88&root=lpsolve

# GNU solver
# https://cran.r-project.org/web/packages/Rglpk/Rglpk.pdf

source("./scripts/menu_builder.R")

library(feather)
library(lpSolveAPI)
library(Rglpk)


# Pick a few nutrients to start with and give them a flag for whether they're a must-restrict or not
pos_df_small <- pos_df[1:3, ] %>% bind_rows(list(positive_nut = "Energ_Kcal", 
                                                 value = 2300) %>% as_tibble()) %>%
  rename(nutrient = positive_nut) %>% 
  mutate(is_must_restrict = FALSE)
mr_df_small <- mr_df[1:3, ] %>% rename(nutrient = must_restrict) %>% 
  mutate(is_must_restrict = TRUE)
nut_df_small <- bind_rows(mr_df_small, pos_df_small)

# Simplify our menu space
cols_to_keep <- c(pos_df_small$nutrient, mr_df$must_restrict, "Shrt_Desc", "GmWt_1")
menu_small <- menu[, which(names(menu) %in% cols_to_keep)] %>% 
  slice(1:3) %>% 
  mutate(
    shorter_desc = map_chr(Shrt_Desc, grab_first_word, splitter = ","), # Take only the fist word
    cost = runif(nrow(.), min = 1, max = 10) %>% round(digits = 2) # Add a cost column
  ) %>% 
  select(shorter_desc, GmWt_1, cost, everything(), -Shrt_Desc)

# OR, read in
menu_small <- read_feather(menu_small, "./data/menu_small.feather")



# Get names in correct order
quo_names <- quo(c(mr_df_small$nutrient, pos_df_small$nutrient))

menu_small <- menu_small %>% 
  select(shorter_desc, GmWt_1, cost, !!quo_names)


# ---- Small example ----
# -- minimize: 
# cherries::cost*cherries::GmWt_1 + cheese::cost*cheese::GmWt_1 + cereals::cost*cereals::GmWt_1
# -- subject to: 
# cherries::GmWt_1*Calcium_Mg + cheese::GmWt_1*Iron_mg + cereals::GmWt_1*Magnesium_mg > 1000, etc.

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
obj_fn <- c(2.29, 2.62, 3.88)

# Ca,     Fe,    Mg,   
menu_mat <-   matrix(c(
  # CHERRIES  CHEESE CEREALS 
  0.130,   27.34,   6.370,   # Lipid
  1.000, 1696.00, 499.000,   # Na
  0.000,   72.00,   0.000,   # Chol
  11.000, 1253.00, 307.000,  # Ca,   
  0.360,    0.87,  11.300,   # Fe
  9.000,   51.00,  84.000,   # Mg
  46.00,  415.00,  379.00),  # cals
  nrow = 7, byrow = TRUE)  

dir <- c("<", "<", "<", ">", ">", ">", ">")
rhs <- c(65, 2400, 300, 1000, 18, 400, 2300)    # Ca, Fe, Mg, Lipid, Na, Chol, cals
bounds <- bounds <- list(lower = list(ind = c(1L, 2L, 3L), 
                                      val = c(1, 1, 1)),
                         upper = list(ind = c(1L, 2L, 3L),
                                      val = c(100, 100, 100)))
solution <- Rglpk_solve_LP(obj_fn, menu_mat, dir, rhs, bounds, max = FALSE)

constraint_mat <- menu_mat %>% as_data_frame() 
names(constraint_mat) <- menu_small$shorter_desc
constraint_mat %>% 
  mutate(
    dir = dir,
    rhs = rhs
  )

# Cost is solution$optimum

# cbind the solved amounts to the original menu
solved_col <- list(solution_amounts = solution$solution) %>% as_tibble()

menu_small_solved <- menu_small %>% bind_cols(solved_col) %>% 
  select(shorter_desc, solution_amounts, everything())

solved_nutrient_vals <- list(solution_nutrient_vals = solution$auxiliary$primal) %>% as_tibble()

nut_df_small_solved <- nut_df_small %>% bind_cols(solved_nutrient_vals) 

# What's the max solution amount? If too high, may need to adjust down 
max_solution_amount <- solution$solution[which(solution$solution == max(solution$solution))]


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 




# # # # # # # # # # # # Programmatic solution creation # # # # # # # # # # # # # # # # # # # # # # # #

# Return a solution that contains the original menu and the needed nutrient df along with the rest
# of the solution in a list

solve_it <- function(df, nutrient_df, min_food_amount = 1, max_food_amount = 100, maximize = FALSE) {
  
  n_foods <- length(df$shorter_desc)
  
  dir_mr <- rep("<", nutrient_df %>% filter(is_must_restrict == TRUE) %>% ungroup() %>% count() %>% as_vector())       # And less than on all the must_restricts
  dir_pos <- rep(">", nutrient_df %>% filter(is_must_restrict == FALSE) %>% ungroup() %>% count() %>% as_vector())     # Final menu must be greater than on all the positives
  
  dir <- c(dir_mr, dir_pos)
  rhs <- nutrient_df[["value"]]      # The right-hand side of the equation is all of the min or max nutrient values
  obj_fn <- df[["cost"]]             # Objective function will be to minimize total cost
  
  bounds <- list(lower = list(ind = seq(n_foods), 
                              val = rep(min_food_amount, n_foods)),
                 upper = list(ind = seq(n_foods), 
                              val = rep(max_food_amount, n_foods)))
  
  construct_matrix <- function(df, nutrient_df) {       # Set up matrix constraints
    mat_base <- df[, which(names(df) %in% nutrient_df$nutrient)] %>% as_vector()  # Get a vector of all our nutrients
    mat <- matrix(mat_base, nrow = nrow(nutrient_df), byrow = TRUE)       # One row per constraint, one column per food (variable)
    return(mat)
  }
  
  mat <- construct_matrix(df, nutrient_df)
  constraint_matrix <- mat %>% as_data_frame() 
  names(constraint_matrix) <- df$shorter_desc
  constraint_matrix <- constraint_matrix %>% 
    mutate(
      dir = dir,
      rhs = rhs
    ) %>% left_join(nutrient_df, by = c("rhs" = "value")) %>% 
    select(nutrient, everything())
  
  message("Constraint matrix below:")
  print(constraint_matrix)
  
  out <- Rglpk_solve_LP(obj_fn, mat, dir, rhs, bounds, max = maximize)           # Do the solving; we get a list back
  
  out <- append(append(append(                                           # Append the dataframe of all min/max nutrient values
    out, list(necessary_nutrients = nutrient_df)),
    list(constraint_matrix = constraint_matrix)),                        # our constraint matrix
    list(original_menu = df))                                            # and our original menu
  
  return(out)
  
  message(paste0("Cost is $", out$optimum %>% round(digits = 2), ".")) 
}

solve_it(menu_small, nut_df_small)
solution_out <- solve_it(menu_small, nut_df_small)



# Take a solution (a list resulting from solve_it()) and 
# return a menu with the solution column cbound as well as a helpful message
solve_menu <- function(sol) {
  
  solved_col <-  list(solution_amounts = sol$solution) %>% as_tibble()    # Grab the vector of solution amounts
  
  df_solved <- sol$original_menu %>% bind_cols(solved_col) %>%            # cbind that to the original menu
    select(shorter_desc, solution_amounts, everything())
  
  max_food <- df_solved %>%                                   # Find what the most of any one food we've got is
    filter(solution_amounts == max(df_solved$solution_amounts)) %>% 
    slice(1:1)                                           # If we've got multiple maxes, take only the first
  
  message(paste0("We've got a lot of ", max_food$shorter_desc %>% as_vector()), ". ",
          max_food$solution_amounts %>% round(digits = 2), " grams of ",
          max_food$shorter_desc %>% as_vector() %>% is_plural(return_bool = FALSE), ".")
  
  return(df_solved)
}

solve_menu(solution_out)
solved_menu <- menu_small %>% solve_it(nut_df_small) %>% solve_menu()


# Take solution (a list resulting from solve_it()) and get the values of each of the nutrients in the
# solved menu
solve_nutrients <- function(sol) {
  
  solved_nutrient_value <- list(solution_nutrient_value =         # Grab the vector of nutrient values in the solution
                                 sol$auxiliary$primal) %>% as_tibble()
  
  nut_df_small_solved <- sol$necessary_nutrients %>%       # cbind it to the nutrient requirements
    bind_cols(solved_nutrient_value)  %>% 
    rename(
      required_value = value
    )
  
  ratios <- nut_df_small_solved %>%                # Find the solution:required ratios for each nutrient
    mutate(
      ratio = solution_nutrient_value/required_value
    )
  
  max_pos_overshot <- ratios %>%             # Find where we've overshot our positives the most
    filter(is_must_restrict == FALSE) %>% 
    filter(ratio == max(.$ratio))
  
  message(paste0("We've overshot the most on ", max_pos_overshot$nutrient %>% as_vector()), 
          ". It's ", 
          max_pos_overshot$ratio %>% round(digits = 2), " times what is needed.")
  
  return(nut_df_small_solved)
}

solve_nutrients(solution_out)
solved_nutrients <- menu_small %>% solve_it(nut_df_small) %>% solve_nutrients()



# # Test that the manual and programmatic solution are the same
assertthat::are_equal(solution$optimum, solution_out$optimum)


