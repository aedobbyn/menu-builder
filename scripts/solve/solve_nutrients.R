
# Take solution (a list resulting from solve_it()) and get the raw values of each of the nutrients in the
# solved menu
solve_nutrients <- function(sol) {
  
  solved_nutrient_value <- list(solution_nutrient_value =         # Grab the vector of nutrient values in the solution
                                  sol$auxiliary$primal) %>% as_tibble()
  
  nut_df_small_solved <- sol$necessary_nutrients %>%       # cbind it to the nutrient requirements
    bind_cols(solved_nutrient_value)  %>% 
    rename(
      required_value = value
    ) %>% 
    select(nutrient, is_must_restrict, required_value, solution_nutrient_value)
  
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
