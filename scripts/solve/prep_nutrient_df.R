
# Quosure the nutrient and must restrict names
nutrient_names <- c(all_nut_and_mr_df$nutrient, "Energ_Kcal")
quo_nutrient_names <- quo(nutrient_names)

# Simplify our menu space
cols_to_keep <- c(all_nut_and_mr_df$nutrient, "Shrt_Desc", "GmWt_1", "Energ_Kcal", "NDB_No")

nutrient_df <- all_nut_and_mr_df %>% 
  bind_rows(list(nutrient = "Energ_Kcal",     # Add calorie restriction in
                 value = 2300) %>% as_tibble()) %>%
  mutate(
    is_must_restrict = ifelse(nutrient %in% mr_df$must_restrict, TRUE, FALSE)
  )