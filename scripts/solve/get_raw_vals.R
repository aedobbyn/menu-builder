
# Get raw nutrient values per food by multiplying the per 100g amounts by GmWt_1 and dividing by 100
get_raw_vals <- function(df, nutrient_df = all_nut_and_mr_df){
  nutrient_names <- c(nutrient_df$nutrient, "Energ_Kcal")
  quo_nutrient_names <- quo(nutrient_names)
  
  at_cols <- which(names(df) %in% nutrient_names)
  non_nut_cols <- df[, setdiff(seq(1:ncol(df)), at_cols)]
  
  raw_vals <- df %>% 
    select(GmWt_1, !!quo_nutrient_names) %>%
    map_dfr(function(x) (x * .$GmWt_1)/100) %>%         # .at = at_cols
    select(-GmWt_1)
  
  out <- raw_vals %>% bind_cols(non_nut_cols) %>% 
    select(shorter_desc, GmWt_1, serving_gmwt, cost, !!quo_nutrient_names, everything())
  
  return(out)
}