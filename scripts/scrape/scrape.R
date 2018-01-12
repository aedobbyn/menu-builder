library(tidyverse)
library(magrittr)
library(stringr)
library(rvest)
library(hash)
library(testthat)
# devtools::install_github("aedobbyn/dobtools")
library(dobtools)

# Source in script for grabbing all the types of measurements (pound, ounce, etc. and their abbreviations in abbrev_dict())
source("./scripts/scrape/get_measurement_types.R") 

base_url <- "http://allrecipes.com/recipe/"

grab_urls <- function(base_url, id) {
  id <- as.character(id)
  recipe_url <- str_c(base_url, id)
  return(recipe_url)
}

remove_whitespace <- function(str) {
  str <- str %>% str_split(" ") %>% as_vector()
  str <- str[!str == ""]
  str <- str_c(str, collapse = " ")
  return(str)
}

# Get the recipe title
# Takes a page (a url that's been read_html'd)
get_recipe_name <- function(page) {
  recipe_name <- page %>% 
    html_nodes(".recipe-summary__h1") %>% 
    html_text() 
  return(recipe_name)
}

# Get the recipe content
get_recipe_content <- function(page) {
  recipe <- page %>% 
    html_nodes(".checkList__line") %>% 
    html_text() %>% 
    str_replace_all("ADVERTISEMENT", "") %>% 
    str_replace_all("\n", "") %>% 
    str_replace_all("\r", "") %>% 
    str_replace_all("Add all ingredients to list", "")
  return(recipe)
}

# Safe reading -- don't error if we've got a bad URL, just tell us, don't exit the loop
read_url <- function(url) {
  page <- read_html(url)
}
try_read <- possibly(read_url, otherwise = "Bad URL", quiet = TRUE)


# Get recipe content and name it with the recipe title, returnign a list of dataframe recipes
get_recipes <- function(urls, sleep = 5, verbose = TRUE, append_bad_URLs = TRUE) {
  out <- NULL
  
  for (url in urls) {
    Sys.sleep(sleep)    # Sleep in between requests to avoid 429 (too many requests)
    recipe_page <- try_read(url)
  
    if (recipe_page == "Bad URL" || 
       (!class(recipe_page) %in% c("xml_document", "xml_node"))) { 
      recipe_list <- recipe_page    # If we've got a bad URL, recipe_df will be "Bad URL" because of the otherwise clause
      
      if (append_bad_URLs == TRUE) { out <- append(out, recipe_list) }

    } else {
      recipe_name <- get_recipe_name(recipe_page)
      
      if (!recipe_name %in% names(out)) {
        
        if (verbose == TRUE) { message(recipe_name) }
      
        recipe <- recipe_page %>% 
          get_recipe_content() %>% 
          map(remove_whitespace) %>% as_vector()
        
        recipe_list <- list(tmp_name = recipe) %>% as_tibble()   # could do with deparse(recipe_name)?
        names(recipe_list) <- recipe_name
        
        out <- append(out, recipe_list)
        
      } else {
        if (verbose == TRUE) {
          message("Skipping recipe we already have")
        }
      }
    }
  }
  return(out)
}


# Take our list of recipes and make them into a dataframe with 
dfize <- function(lst, remove_bad_urls = TRUE) {

  df <- NULL
  if (remove_bad_urls == TRUE) {
    lst <- lst[!lst == "Bad URL"]
  }
  # TODO: if it makes sense, write the else condition
  
  for (i in seq_along(lst)) {
    this_df <- lst[i] %>% as_tibble()
    recipe_name <- names(lst[i])
    names(this_df) <- "ingredients"
    this_df <- this_df %>% 
      mutate(recipe_name = recipe_name)
    df <- df %>% bind_rows(this_df)
  }
  return(df)
}


# Get a dictionary of our portion measurements; this gives us measurement_types() and abbrev_dict()
get_measurement_types(from_file = TRUE)

# Match any number, even if it has a decimal or slash in it
portions_reg <- "[[:digit:]]+\\.*[[:digit:]]*+\\/*[[:digit:]]*"

# Only multiply numbers separated by " (" as in "3 (5 ounce) cans of broth"
multiplier_reg <- "[[:digit:]]+ \\(+[[:digit:]]"   
multiplier_reg_looser <- "[0-9]+\ +[0-9]"
multiplier_regs <- str_c(multiplier_reg, multiplier_reg_looser, collapse = "|")


# Turn fractions into decimals but keep them as character so we can put this in pipeline before 
# the as.numeric() call
frac_to_dec <- function(e) {
  if (length(e) == 0) {    # If NA, make the portion 0
    out <- 0
  } else {
    out <- parse(text = e) %>% eval() %>% as.character()
  }
  return(out)
}


# We need this because eval() in frac_to_dec() only evaluates the last string in a vector, not both
map_frac_to_dec <- function(e) {
  out <- NULL
  for (i in e) {
      out <- e %>% map_chr(frac_to_dec)
  }
  return(out)
}


# We only do calculations on the first two numbers that appear
# Multiply all numbers by each other, unless they're a range or a complex fraction
# e.g., if we've got 3 (14 ounce) cans beef broth we want to know we need 42 oz
multiply_or_add_portions <- function(e) {
  if (length(e) == 0) {
    e <- 0    # NA to 0
  } else if (length(e) > 1) {
    if (e[2] < 1) {  # If our second element is a fraction, we know this is a complex fraction so we add the two
      e <- e[1:2] %>% reduce(`+`)
    } else {   # Otherwise, we multiply them
      e <- e[1:2] %>% reduce(`*`)
    }   
  }
  return(e)
}


# For use in get_ragng(): get the mean of the first two elements in a numeric vector
get_portion_means <- function(e) {
  if (length(e) == 0) {
    e <- 0    # NA to 0
  } else if (length(e) > 1) {
      e <- mean(e[1:2])
  }
  return(e)
}


# Regex for " or ", "-", " - " appearing between two numbers
to_reg <- "([0-9])(( to ))(([0-9]))"
or_reg <- "([0-9])(( or ))(([0-9]))"
dash_reg_1 <- "([0-9])((-))(([0-9]))"
dash_reg_2 <- "([0-9])(( - ))(([0-9]))"

# TODO: combine the above: lookaheads/behinds currently don't work
# is_range_reg <- "(?<=[0-9])((-)*\n?)(( - )*\n?)(( to )*\n?)(?=([0-9]))" 
# range_splitters <- c(" to ",  or ", "-", " - ") %>% 
#   str_c(collapse = "|")


# If two numbers are separated by an "or" or a "-" we know that this is a range,
# e.g., 4-5 teaspoons of sugar. So we want to say that this
determine_if_range <- function(ingredients) {
  if (str_detect(ingredients, pattern = to_reg) | 
      str_detect(ingredients, pattern = or_reg) |
      str_detect(ingredients, pattern = dash_reg_1) |
      str_detect(ingredients, pattern = dash_reg_2)) {
    contains_range <- TRUE
  } else {
    contains_range <- FALSE
  }
  return(contains_range)
}


# Logical indicating whether the amount is exact or not
approximate <- c("about", "around", "as desired", "as needed", "optional",  "or so", "to taste") %>% 
  str_c(collapse = "|")


# Change NAs to 0s elementwise; this can also be done with coalesce(), apparenly emo::ji("sad")
nix_nas <- function(x) {
  if (length(x) == 0) {
    x <- ""
  }
  x
}


# Take portion types and add a column for their abbreviations
add_abbrevs <- function(df) {

  out <- vector(length = nrow(df))
  for (i in seq_along(out)) {
    if (df$portion_name[i] %in% abbrev_dict$name) {
      out[i] <- abbrev_dict[which(abbrev_dict$name == df$portion_name[i]), ]$key
      
    } else {
      out[i] <- df$portion_name[i]
    }
  }
  
  out <- df %>% bind_cols(list(portion_abbrev = out) %>% as_tibble())
  return(out)
}


# Putting it together, we get portion names and amounts
get_portion_text <- function(df) {
  
  df <- df %>% 
    mutate(
      raw_portion_num = str_extract_all(ingredients, portions_reg, simplify = FALSE) %>%   # Extract the raw portion numbers,
        map_chr(str_c, collapse = ", ", default = ""),   # separating by comma if multiple
      
      portion_name = str_extract_all(ingredients, measures_collapsed) %>%
        map(nix_nas) %>%
        str_extract_all("[a-z]+") %>% 
        map(nix_nas) %>% # Get rid of numbers
        map_chr(last),       # If there are multiple arguments that match, grab the last one (rather than solution below of comma-separating them)
        # map_chr(str_c, collapse = ", ", default = ""),   # If there are multiple arguments that match, separate them with a ,

      approximate = str_detect(ingredients, approximate)
    )
  return(df)
}


# If we've got a range, (e.g., 3-4 cloves of garlic) take the average of the two, so 3.5                  
get_ranges <- function(e) {
  
  if (determine_if_range(e) == TRUE) {
    out <- str_extract_all(e, portions_reg) %>%  
      
      map(str_split, pattern = " to ", simplify = FALSE) %>%  # Split out numbers
      map(str_split, pattern = " - ", simplify = FALSE) %>%  # See if we can find a more elegant way of doing this, maybe with range_splitters
      map(str_split, pattern = "-", simplify = FALSE) %>%
      
      map(map_frac_to_dec) %>%  # same as modify_depth(2, frac_to_dec)
      map(as.numeric) %>% 
      map_dbl(get_portion_means) %>% round(digits = 2)
    
  } else {
    out <- 0
  }
  return(out)
}


# If we've got something that needs to be multiplied, like "4 (12 oz) hams" or a fraction like "2/3 pound of butter",
# then multiply or add those numbers as appropriate
get_mult_add_portion <- function(e, only_mult_after_paren = FALSE) {
  if ((str_detect(e, multiplier_reg) == TRUE | str_detect(e, multiplier_reg_looser) == TRUE)
      & only_mult_after_paren == FALSE) {  # If either matches and we don't care about where there's a parenthesis there or not
      if (str_detect(e, multiplier_reg) == TRUE) {
        out <- e %>% str_extract_all(portions_reg) %>% 
          map(map_frac_to_dec) %>%   
          map(as.numeric) %>% 
          map_dbl(multiply_or_add_portions) %>%   
          round(digits = 2)
    } else {    # If we do care, and we have a parenthesis
      out <- e %>% str_extract_all(portions_reg) %>% 
        map(map_frac_to_dec) %>%   
        map(as.numeric) %>% 
        map_dbl(multiply_or_add_portions) %>%   
        round(digits = 2)
    }
  } else {
    out <- 0
  }
  return(out)
}


# If we neither need to get a range nor multiply/add portions, we'll just take whatever the first number is in there
get_final_portion <- function(e, range_portion, mult_add_portion, ...) {
  if (range_portion == 0 & mult_add_portion == 0) {
    out <- str_extract_all(e, portions_reg) %>% 
      map(map_frac_to_dec) %>%   
      map(as.numeric) %>% map_dbl(first)

  } else {
    out <- range_portion + mult_add_portion   # One of these should be 0, so the sum should be just whichever one is non-zero
  }
  return(out)
}


# --- Take a recipe dataframe and append the values associated with each portion ---
# range_portion: If we have a range, take the mean of the two numbers in the range; 0 otherwise
# If we need to add complex fractions, add them; 0 otherwise
# If we need to multiply two numbers to get the total portion size, do so
# For the final portion value, if we have taken a range or added/multiplied, use that number; otherwise, the first number that appears
get_portion_values <- function(df, only_mult_after_paren = FALSE) {
  df <- df %>% 
    mutate(
      range_portion = map_dbl(ingredients, get_ranges),
      mult_add_portion = map_dbl(ingredients, get_mult_add_portion, only_mult_after_paren = only_mult_after_paren),
      # TODO: implement this instead of the below
      # portion = pmap_dbl(.l = list(ingredients, range_portion, mult_add_portion), .f = get_final_portion)  
      portion = ifelse(range_portion == 0 & mult_add_portion == 0,
                       str_extract_all(ingredients, portions_reg) %>%
                         map(map_frac_to_dec) %>%
                         map(as.numeric) %>%
                         map_dbl(first),
                       range_portion + mult_add_portion)   # Otherwise, take either the range or the multiplied value
    )
  return(df)
}


# Get portion text and optionally add abbreviations
# If pare_portion_info is TRUE, only keep the portion 
get_portions <- function(df, add_abbrevs = FALSE, pare_portion_info = FALSE) {
  df %<>% get_portion_text() 
  if (add_abbrevs == TRUE) {
    df %<>% add_abbrevs()
  }
  df %<>% get_portion_values()
  if (pare_portion_info == TRUE) {
    df %<>% select(-range_portion, -mult_add_portion)
  }
  return(df)
}





  