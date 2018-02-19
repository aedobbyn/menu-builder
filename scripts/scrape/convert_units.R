
library(measurements)
library(feather)
more_recipes_df <- read_feather("./data/derived/more_recipes_df.feather")

more_recipes_df_head <- more_recipes_df %>% head()



# See what this does
expect_equal(396.89, conv_unit(more_recipes_df[3, ]$portion, more_recipes_df[3, ]$portion_abbrev, "g") %>% round(digits = 2))


# What percent of 



more_recipes_df <- more_recipes_df %>% 
  left_join(abbrev_dict, by = c("portion_abbrev" = "key"))

more_recipes_df_head <- more_recipes_df_head %>% 
  left_join(abbrev_dict, by = c("portion_abbrev" = "key"))


convert_units <- function(df, name_col = accepted, val_col = portion,
                          pare_down = TRUE) {
  
  quo_name_col <- enquo(name_col)
  quo_val_col <- enquo(val_col)
  
  out <- df %>% 
    rowwise() %>% 
    mutate(
      converted_g = try_conv(!!quo_val_col, !!quo_name_col, "g"),
      converted_ml = try_conv(!!quo_val_col, !!quo_name_col, "ml"), 
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


more_recipes_df_head %>% convert_units() %>% View()
  



more_recipes_df %>% 
  left_join(abbrev_dict, by = c("portion_abbrev" = "key")) %>% 
  sample_n(300) %>%
  convert_units() %>% View()

# Test that this works with volume
more_recipes_df %>% 
  filter(portion_abbrev %in% c("cup", "tbsp", "tsp", "pt")) %>% 
  sample_n(5) %>% 
  left_join(abbrev_dict, by = c("portion_abbrev" = "key")) %>% 
  convert_units()


