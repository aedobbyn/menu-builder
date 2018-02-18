
library(measurements)
library(feather)
more_recipes_df <- read_feather("./data/derived/more_recipes_df.feather")

more_recipes_df_head <- more_recipes_df %>% head()

convert_units <- function(df, val = , from = portion_abbrev, to = g) {
  
  quo_col <- enquo(col)
  quo_to <- enquo(to)
  
  df <- df %>% 
    mutate(
      conv_unit()
    )
}



convert_a_unit <- function(df, val = "portion", from_col = "portion_abbrev", to_unit = "g") {
  out <- NULL
  
  for (i in 1:nrow(df)) {
    if (is.null(df[[from_col]][i]) | df[[from_col]][i] == "") {
      out_i <- ""
    } else {
      out_i <- conv_unit(df[[val]][i], df[[from_col]][i], "g")
    }
    out <- c(out, out_i)
  }
  
  # out <- conv_unit(val, from, to)
  return(out)
}

convert_a_unit(more_recipes_df_head)


conv_unit(more_recipes_df[3, ]$portion, more_recipes_df[3, ]$portion_abbrev, "g")





convert_a_unit <- function(df, val = "portion", from_col = "portion_abbrev", to_unit = "g") {

  if (is.null(df[[from_col]][i]) | df[[from_col]][i] == "") {
    out <- ""
  } else {
    out <- conv_unit(df[[val]][i], df[[from_col]][i], "g")
  }
  
  # out <- conv_unit(val, from, to)
  return(out)
}

more_recipes_df_head %>% 
  mutate(
    foo = ifelse(portion_abbrev == "", "", conv_unit(portion, portion_abbrev, "g"))
  ) %>% View()


abbrev_dict$key

try_conv <- possibly(conv_unit, otherwise = NA)

test_abbrev_dict_conv <- function(dict, key_col = key, val = 10) {
  
  quo_col <- enquo(key_col)
  
  out <- dict %>% 
    rowwise() %>% 
    mutate(
      converted_g = try_conv(val, !!quo_col, "g"),
      converted_ml = try_conv(val, !!quo_col, "ml"),
      converted = case_when(
        !is.na(converted_g) ~ converted_g,
        !is.na(converted_ml) ~ converted_ml
      )
    )
  
  return(out)
}

test_abbrev_dict_conv(abbrev_dict)



more_recipes_df %>% 
  sample_n(30) %>% 
  mutate(
    foo = ifelse(portion_abbrev == "", "", conv_unit(portion, portion_abbrev, "g"))
  ) %>% View()



