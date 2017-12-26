# Transpose a menu such that it looks like the matrix of constraints we're about to create
# with foods as the columns and nutrients as the rows

transpose_menu <- function(df) {
  transposed_df <- df %>% 
    select(cost, !!quo_nutrient_names) %>%   
    t() %>% as_data_frame() 
  
  names(transposed_df) <- df$shorter_desc
  
  transposed_df <- transposed_df %>%
    mutate(
      constraint = c("cost", nutrient_df$nutrient)
    ) %>% 
    select(constraint, everything())
  
  return(transposed_df)
}


# menu_unsolved_per_g %>% transpose_menu()
# menu_unsolved_per_g %>% get_raw_vals() %>% transpose_menu()