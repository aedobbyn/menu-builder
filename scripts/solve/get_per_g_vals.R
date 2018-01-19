# Get nutrient values per 100g

get_per_g_vals <- function(df, nut_df = nutrient_df) {
  # browser()
  nutrient_names <- c(nut_df$nutrient, "Energ_Kcal")
  quo_nutrient_names <- quo(nutrient_names)
  
  at_cols <- which(names(df) %in% nutrient_names)
  non_nut_cols <- df[, setdiff(seq(1:ncol(df)), at_cols)]
  
  per_g_vals <- df %>%
    select(GmWt_1, !!quo_nutrient_names) %>%
    map_dfr(function(x) (x / .$GmWt_1)*100) %>% 
    select(-GmWt_1)
  
  out <- per_g_vals %>% bind_cols(non_nut_cols) %>%
    # bind_cols(GmWt_1 = df$GmWt_1) %>% 
    select(shorter_desc, GmWt_1, serving_gmwt, cost, !!quo_nutrient_names, everything())
  
  return(out)
}

# ---------- Thoughts for refactoring ---------
# get_per_g <- function(row, x) {
#   (x / row[["GmWt_1"]])*100
#   x
# }
# 
# get_per_g_vals_3 <- function(df, nut_df = nutrient_df) {
#   # browser()
#   nutrient_names <- c(nut_df$nutrient, "Energ_Kcal")
#   quo_nutrient_names <- quo(nutrient_names)
#   
#   at_cols <- which(names(df) %in% nutrient_names)
#   non_nut_cols <- df[, setdiff(seq(1:ncol(df)), at_cols)]
#   
#   per_g_vals <- df %>%
#     select(GmWt_1, !!quo_nutrient_names) %>%
#     map2_dfr(.f = get_per_g, ) %>% 
#     select(-GmWt_1)
#   
#   out <- per_g_vals %>% bind_cols(non_nut_cols) %>%
#     # bind_cols(GmWt_1 = df$GmWt_1) %>% 
#     select(shorter_desc, GmWt_1, serving_gmwt, cost, !!quo_nutrient_names, everything())
#   
#   return(out)
# }
# 
# get_per_g_vals_2 <- function(df, nut_df = nutrient_df) {
#   # browser()
#   nutrient_names <- c(nut_df$nutrient, "Energ_Kcal")
#   quo_nutrient_names <- quo(nutrient_names)
#   
#   at_cols <- which(names(df) %in% nutrient_names)
#   non_nut_cols <- df[, setdiff(seq(1:ncol(df)), at_cols)]
#   
#   per_g_vals <- df %>%
#     select(GmWt_1, !!quo_nutrient_names) %>%
#     mutate_at(vars(nutrient_names), 
#               map_dbl(get_per_g))
#     map_dfr() %>% 
#     select(-GmWt_1)
#   
#   out <- per_g_vals %>% bind_cols(non_nut_cols) %>%
#     # bind_cols(GmWt_1 = df$GmWt_1) %>% 
#     select(shorter_desc, GmWt_1, serving_gmwt, cost, !!quo_nutrient_names, everything())
#   
#   return(out)
# }
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
