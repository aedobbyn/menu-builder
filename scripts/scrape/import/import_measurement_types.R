library(here)
library(feather)

# Other measurement types from https://github.com/NYTimes/ingredient-phrase-tagger/blob/master/ingredient_phrase_tagger/training/utils.py

units <- c(
  "cups", "cup",
  "tablespoons", "tablespoon",
  "teaspoons", "teaspoon",
  "pounds", "pound",
  "ounces", "ounce",
  "cloves", "clove",
  "sprigs", "sprig",
  "pinches", "pinch",
  "bunches", "bunch",
  "slices", "slice",
  "grams", "gram",
  "heads", "head",
  "quarts", "quart",
  "gallons", "gallon",     # <-- my addition
  "stalks", "stalk",
  "pints", "pint",
  "pieces", "piece",
  "sticks", "stick",
  "dashes", "dash",
  "fillets", "fillet",
  "cans", "can",
  "ears", "ear",
  "packages", "package",
  "strips", "strip",
  "bulbs", "bulb",
  "bottles", "bottle"
)

## This actually doesn't remove plurals with "es"
# remove_plurals <- function(vec) {
#   plurals <- seq(1, length(vec), by = 2)
#   vec <- vec[-plurals]
#   return(vec)
# }
# 
# units <- remove_plurals(units)


add_other_measurement_types <- function() {
  all_measurement_types_vec <- c(measurement_types$name, units) %>% unique()
  
  all_measurement_types <- list(name = all_measurement_types_vec) %>% as_tibble()
  return(all_measurement_types)
}


# From a website
get_measurement_types_from_source <- function(measurement_url = "https://www.convert-me.com/en/convert/cooking/") {
  
  measurement_types_raw <- measurement_url %>% 
    read_html() %>% 
    html_nodes(".usystem") %>% 
    html_text()
  
  measurement_types <- measurement_types_raw %>% 
    str_replace_all("\n", "") %>% 
    str_replace_all("/", "") %>%
    str_replace_all("Units:" , "")  %>% 
    str_replace_all("U.S." , "")  %>% 
    str_replace_all("British" , "")  %>% 
    str_replace_all("\\(" , "") %>% 
    str_replace_all("\\)" , "")
  
  measurement_types <- measurement_types[1:2] # third contains no more information
  
  for (i in seq_along(measurement_types)) {
    measurement_types[i] <- substr(measurement_types[i], 42, nchar(measurement_types[i]))
  }
  
  measurement_types <- measurement_types %>% remove_whitespace() %>% 
    str_split(" ") %>% unlist() %>% map_chr(str_replace_all, "[[:space:]]", "") 
  measurement_types <- measurement_types[which(measurement_types != " " | measurement_types != "")] 
  measurement_types <- list(name = measurement_types) %>% as_tibble() %>% 
    distinct() %>% 
    filter(! name %in% c("dessert", "spoon", "fluid", "fl") & nchar(name) > 0) 
  
  return(measurement_types)
}

raw_measurement_types <- get_measurement_types_from_source()

refine_measurement_types <- function(vec = raw_measurement_types,
                                     add_other_measurement_types = TRUE) {
  
  measurement_types <- raw_measurement_types %>%
    filter(! name == "cup")  # no abbrev here
  
  # Add in things that didn't have abbreviations 
  needs_abbrev <- c("tablespoon", "teaspoon", "fluid ounce", "gallon")
  abbrevs_needed <- c("tbsp", "tsp", "fluid oz", "gal")
  extra_measurements <- list(name = needs_abbrev, key = abbrevs_needed) %>% as_tibble()

  measurement_types <<- measurement_types %>% filter(!name %in% needs_abbrev) 
  abbrev_dict_pre <- measurement_types %>%  mutate(
    rownum = 1:nrow(.),
    key = ifelse(rownum %% 2 != 0, lead(name), name)
  ) %>% 
    filter(!name == key) %>% 
    select(-rownum) 
  abbrev_dict <<- abbrev_dict_pre %>% bind_rows(extra_measurements)
  
  # We need to put the prefix "us_" before some of our units in order to conver to grams
  to_usize <- c("tsp", "tbsp", "cup", "pint", "quart", "gal")   
  
  accepted <- c("oz", "pint", "lbs", "kg", "g", "l", "dl", "ml", "tbsp", "tsp", "oz", "gal", "quart", "cup")
  accepted[which(accepted %in% to_usize)] <- stringr::str_c("us_", accepted[which(accepted %in% to_usize)])
  
  # cbind this to our dictionary 
  abbrev_dict_w_accepted <<- abbrev_dict %>% bind_cols(accepted = accepted)
  
  if (add_other_measurement_types == TRUE) {
    measurement_types <- add_other_measurement_types()
  }
  
  return(measurement_types)
}

bing <- refine_measurement_types()






get_measurement_types_from_source_collapsed <- function() {
  
  measurement_types <- get_measurement_types_from_source()
  
  name_measures_collapsed <- abbrev_dict$name %>% str_c(collapse = "|")
  
  abbrev_dict$name %>% str_c(collapse = "\b") %>%
    str_split("\b") %>% str_c(collapse = "[[:digit:]]")
  
  vec_no_spaces <- vector()
  vec_w_spaces <- vector()
  for (i in abbrev_dict$key) {
    out_no_spaces <- c("[[:digit:]]", i, " ") %>% str_c(collapse = "")    # using " " instead of \b for word boundary
    out_w_spaces <- c("[[:digit:]] ", i, " ") %>% str_c(collapse = "")
    vec_no_spaces <- c(vec_no_spaces, out_no_spaces) 
    vec_w_spaces <- c(vec_w_spaces, out_w_spaces)
  }
  vec_no_spaces <- str_c(vec_no_spaces, collapse = "|")
  vec_w_spaces <- str_c(vec_w_spaces, collapse = "|")
  key_all <- str_c(vec_no_spaces, "|", vec_w_spaces, collapse = "|")
  measures_collapsed <- str_c(key_all, "|", name_measures_collapsed, collapse = "|")
  
  return(measures_collapsed)
}




# write_rds(units, "./data/derived/units.rds")
# write_feather(abbrev_dict, "./data/derived/abbrev_dict.feather")
# write_feather(abbrev_dict_w_accepted, "./data/derived/abbrev_dict_w_accepted.feather")
# write_rds(mc, "./data/derived/measurement_types.rds")



