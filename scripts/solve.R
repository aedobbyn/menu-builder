# GNU solver
# https://cran.r-project.org/web/packages/Rglpk/Rglpk.pdf

source("./scripts/menu_builder.R")

library(feather)
library(Rglpk)

# Simplify our menu space
cols_to_keep <- c(all_nut_and_mr_df$nutrient, "Shrt_Desc", "Energ_Kcal", "GmWt_1", "NDB_No")
menu_unsolved <- menu[, which(names(menu) %in% cols_to_keep)] %>% 
  mutate(
    shorter_desc = map_chr(Shrt_Desc, grab_first_word, splitter = ","), # Take only the fist word
    cost = runif(nrow(.), min = 1, max = 10) %>% round(digits = 2) # Add a cost column
  ) %>%
  select(shorter_desc, cost, !!quo_nutrient_names, GmWt_1, Energ_Kcal, Shrt_Desc, NDB_No)

# Give nutrients a flag for whether they're a must-restrict or not
nutrient_df <- all_nut_and_mr_df %>% 
  mutate(
    is_mr = ifelse(nutrient %in% mr_df$must_restrict, TRUE, FALSE)
  )

# Get names in correct order
quo_nutrient_names <- quo(nutrient_df$nutrient)

# Transpose our menu such that it looks like the matrix of constraints we're about to create
# with foods as the columns and nutrients as the rows
transposed_menu_unsolved <- menu_unsolved %>% 
  select(cost, !!quo_nutrient_names) %>%   
  t() %>% as_data_frame() 

names(transposed_menu_unsolved) <- menu_unsolved$shorter_desc

transposed_menu_unsolved <- transposed_menu_unsolved %>%
  mutate(
    constraint = c("cost", nutrient_df$nutrient)
  ) %>% 
  select(constraint, everything())



# # # # # # # # # # # # # # # # # # # # Solve  # # # # # # # # # # # # # # # # # # # # # # # #

# Return a solution that contains the original menu and the needed nutrient df along with the rest
# of the solution in a list
solve_it <- function(df, nutrient_df, maximize = FALSE) {
  
  dir_mr <- rep("<", nutrient_df %>% filter(is_mr == TRUE) %>% ungroup() %>% count() %>% as_vector())       # And less than on all the must_restricts
  dir_pos <- rep(">", nutrient_df %>% filter(is_mr == FALSE) %>% ungroup() %>% count() %>% as_vector())     # Final menu must be greater than on all the positives
  
  dir <- c(dir_mr, dir_pos)          
  rhs <- nutrient_df[["value"]]      # The right-hand side of the equation is all of the min or max nutrient values
  obj_fn <- df[["cost"]]             # Objective function will be to minimize total cost
  
  construct_matrix <- function(df, nutrient_df) {       # Set up matrix constraints
    mat_base <- df[, which(names(df) %in% nutrient_df$nutrient)] %>% as_vector()  # Get a vector of all our nutrients
    mat <- matrix(mat_base, nrow = nrow(nutrient_df), byrow = TRUE)       # One row per constraint, one column per food (variable)
    return(mat)
  }
  
  mat <- construct_matrix(df, nutrient_df)                # Make the constraintmatrix we'll use in Rglpk_solve_LP()
  
  constraint_matrix <- mat %>% as_data_frame()            # Take that matrix, give it names, join it on the directionality 
  names(constraint_matrix) <- df$shorter_desc             # of the constraint and the max (rhs) so we can read it 
  constraint_matrix <- constraint_matrix %>% 
    mutate(
      dir = dir,
      rhs = rhs
    ) %>% left_join(nutrient_df, by = c("rhs" = "value")) %>% 
    select(nutrient, everything())
  
  message("Constraint matrix below:")
  print(constraint_matrix)
  
  out <- Rglpk_solve_LP(obj_fn, mat, dir, rhs, max = maximize)           # Do the solving; we get a list back
  
  out <- append(append(append(                                           
    out, list(necessary_nutrients = nutrient_df)),                       # Append the dataframe of all min/max nutrient values
    list(constraint_matrix = constraint_matrix)),                        # our constraint matrix
    list(original_menu = df))                                            # and our original menu
  
  return(out)
  
  message(paste0("Cost is $", out$optimum %>% round(digits = 2), ".")) 
}

solve_it(menu_unsolved, nutrient_df)
full_solution <- solve_it(menu_unsolved, nutrient_df)



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

solve_menu(full_solution)
solved_menu <- menu_unsolved %>% solve_it(nutrient_df) %>% solve_menu()



# Take solution (a list resulting from solve_it()) and get the values of each of the nutrients in the
# solved menu
solve_nutrients <- function(sol) {
  
  solved_nutrient_vals <- list(solution_nutrient_vals =         # Grab the vector of nutrient values in the solution
                                 sol$auxiliary$primal) %>% as_tibble()
  
  nut_df_small_solved <- sol$necessary_nutrients %>%       # cbind it to the nutrient requirements
    bind_cols(solved_nutrient_vals)                    
  
  ratios <- nut_df_small_solved %>%                # Find the solution:required ratios for each nutrient
    mutate(
      ratio = solution_nutrient_vals/value
    )
  
  max_pos_overshot <- ratios %>%             # Find where we've overshot our positives the most
    filter(is_mr == FALSE) %>% 
    filter(ratio == max(.$ratio))
  
  message(paste0("We've overshot the most on ", max_pos_overshot$nutrient %>% as_vector()), 
          ". It's ", 
          max_pos_overshot$ratio %>% round(digits = 2), " times what is needed.")
  
  return(nut_df_small_solved)
}

solve_nutrients(full_solution)
solved_nutrients <- menu_unsolved %>% solve_it(nutrient_df) %>% solve_nutrients()

