library(tidyverse)
library(stringr)
library(rvest)
library(hash)
library(testthat)

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


# Get recipe content and name it with the recipe title
get_recipes <- function(urls, sleep = 5, trace = TRUE, append_bad_URLs = TRUE) {
  out <- NULL
  # browser()
  
  for (url in urls) {
    Sys.sleep(sleep)    # Sleep in between requests to avoid 429 (too many requests)
    recipe_page <- try_read(url)
  
    if(recipe_page == "Bad URL" | 
       (!class(recipe_page) %in% c("xml_document", "xml_node"))) { 
      recipe_list <- recipe_page    # If we've got a bad URL, recipe_df will be "Bad URL" because of the otherwise clause
      
      if (append_bad_URLs == TRUE) { out <- append(out, recipe_list) }

    } else {
      recipe_name <- get_recipe_name(recipe_page)
      
      if (!recipe_name %in% names(out)) {
        
        if (trace == TRUE) { message(recipe_name) }
      
        recipe <- recipe_page %>% 
          get_recipe_content() %>% 
          map(remove_whitespace) %>% as_vector()
        
        recipe_list <- list(tmp_name = recipe) %>% as_tibble()   # could do with deparse(recipe_name)?
        names(recipe_list) <- recipe_name
        
        out <- append(out, recipe_list)
        
      } else {
        if (trace == TRUE) {
          message("Skipping recipe we already have")
        }
      }
    }
  }
  return(out)
}


# Take our list of recipes and make them into a dataframe with 
dfize <- function(lst) {
  # browser()
  df <- NULL
  lst <- lst[!lst == "Bad URL"]
  
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


# Get a dictionary of our portion measurements
source("./scripts/scrape/get_measurement_types.R")
measures_collapsed <- get_measurement_types(from_file = TRUE)

# Match any number, even if it has a decimal or slash in it
portions_reg <- "[[:digit:]]+\\.*[[:digit:]]*+\\/*[[:digit:]]*"

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


# --- Attempt to combine these, but lookaheads/behinds don't work
# is_range_reg <- "(?<=[0-9])((-)*\n?)(( - )*\n?)(( to )*\n?)(?=([0-9]))" 
# range_splitters <- c(" to ",  or ", "-", " - ") %>% 
#   str_c(collapse = "|")

# Logical indicating whether the amount is exact or not
approximate <- c("about", "around", "as desired", "as needed", "optional",  "or so", "to taste") %>% 
  str_c(collapse = "|")

# Change NAs to 0s elementwise
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
get_portions <- function(df) {
  
  df <- df %>% 
    mutate(
      raw_portion_num = str_extract_all(ingredients, portions_reg, simplify = FALSE) %>%   # Extract the raw portion numbers,
        map_chr(str_c, collapse = ", ", default = ""),   # separating by comma if multiple
      
      
      portion_num = if_else(str_detect(ingredients, pattern = to_reg | or_reg | dash_reg_1 | dash_reg_2) | 
                              str_detect(ingredients, pattern = or_reg) |
                              str_detect(ingredients, pattern = dash_reg_1) |
                              str_detect(ingredients, pattern = dash_reg_2),  
                            
          # If we've got a range, (e.g., 3-4 cloves of garlic) take the average of the two, so 3.5                  
          str_extract_all(ingredients, portions_reg) %>%  
            
            map(str_split, pattern = " to ", simplify = FALSE) %>%  # Split out numbers
            map(str_split, pattern = " - ", simplify = FALSE) %>%  # See if we can find a more elegant way of doing this, maybe with range_splitters
            map(str_split, pattern = "-", simplify = FALSE) %>%
            
            map(map_frac_to_dec) %>%  # same as modify_depth(2, frac_to_dec)
            map(as.numeric) %>% 
            map_dbl(get_portion_means) %>% round(digits = 2),
          
          # Otherwise, if there are two numbers, we multiply them (i.e., 6 12oz bottles of beer)
          str_extract_all(ingredients, portions_reg) %>%  # Get all numbers in a list
            map(map_frac_to_dec) %>%   # not same as modify_depth(1, frac_to_dec)
            map(as.numeric) %>% 
            map_dbl(multiply_or_add_portions) %>% 
            round(digits = 2)  # Multiply all numbers 
      ),
      
      portion_name = str_extract_all(ingredients, measures_collapsed) %>%
        map(nix_nas) %>%
        str_extract_all("[a-z]+") %>% 
        map(nix_nas) %>% # Get rid of numbers
        map(last) %>% unlist(),       # If there are multiple arguments that match, grab the last one
        # map_chr(str_c, collapse = ", ", default = ""),   # If there are multiple arguments that match, separate them with a ,
      
      # portion_abbrev = ifelse(portion_name %in% abbrev_dict$name,
      #                       abbrev_dict[which(abbrev_dict$name == portion_name), ]$key,
      #                       portion_name),
      
      approximate = str_detect(ingredients, approximate)
    )
  return(df)
}



