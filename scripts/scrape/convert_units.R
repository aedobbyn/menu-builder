convert_units <- function(df, name_col = accepted, val_col = portion,
                          pare_down = TRUE, round_to = 2) {
  
  quo_name_col <- enquo(name_col)
  quo_val_col <- enquo(val_col)
  
  out <- df %>% 
    rowwise() %>% 
    mutate(
      converted_g = try_conv(!!quo_val_col, !!quo_name_col, "g") %>% round(digits = round_to),
      converted_ml = try_conv(!!quo_val_col, !!quo_name_col, "ml") %>% round(digits = round_to), 
      converted = case_when(
        !is.na(converted_g) ~ as.numeric(converted_g), 
        !is.na(converted_ml) ~ as.numeric(converted_ml), 
        is.na(converted_g) && is.na(converted_ml) ~ NA_real_ 
      )
    ) 
  
  if (pare_down == TRUE) {
    out <- out %>% 
      select(-converted_g, -converted_ml)
  }
  
  return(out)
}