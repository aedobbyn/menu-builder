library(tidyverse)
library(rvest)

example_url <- "http://allrecipes.com/recipe/244950/baked-chicken-schnitzel/"
schnitzel <- example_url %>% get_recipes()
example_url %>% try_read() %>% get_recipe_name()

base_url <- "http://allrecipes.com/recipe/"
urls <- grab_urls(base_url, 244940:244950)

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

# Safe reading -- don't error if we've got a bad URL, just tell us
read_url <- function(url) {
  page <- read_html(url)
}
try_read <- possibly(read_url, otherwise = "Bad URL", quiet = TRUE)

# Get recipe content and name it with the recipe title
get_recipes <- function(url, obj) {
  
  recipe_page <- try_read(url)
  
  if(recipe_page == "Bad URL" | 
     (!class(recipe_page) %in% c("xml_document", "xml_node"))) { 
    recipe_df <- recipe_page
    
  } else {
    recipe <- recipe_page %>% 
      get_recipe_content() %>% 
      map(remove_whitespace) %>% as_vector()
    
    recipe_name <- get_recipe_name(recipe_page)
    
    recipe_df <- list(this_name = recipe) %>% as_tibble()   # could do with deparse(recipe_name)?
    names(recipe_df) <- recipe_name
  } 
  
  out <- append(obj, recipe_df)
}

obj <- "x"

foo <- get_recipes(example_url, obj)

some_recipes <- c(urls[1:3], bad_url) %>% map(get_recipes)

# Test that our bad URL doesn't error out
expect_equal(get_recipes(bad_url), "Bad URL")



# Most IDs seem to start with 1 or 2 and be either 5 or 6 digits long
# Some 
more_urls <- grab_urls(base_url, 10000:15000)
more_recipes <- more_urls %>% map(get_recipes)



dfize <- function(lst) {
  df <- NULL
  lst <- lst[!lst == "Bad URL"]
  
  for (i in seq_along(lst)) {
      recipe_name <- names(lst[[i]])
      names(lst[[i]]) <- "ingredients"
      this_df <- lst[[i]] %>% 
        mutate(recipe_name = recipe_name)
      df <- df %>% bind_rows(this_df)
  }
  return(df)
}

some_recipes_df <- dfize(some_recipes)


measures <- c("ounce", "cup", "pound", "teaspoon", "tablespoon")
# measures_plural <- str_c(measures, "s")    #  <--- probably don't need this 
# measures <- c(measures, measures_plural)
measures_collapsed <- str_c(measures, collapse = "|")
  
# Match any number, even if it has a decimal or slash in it
portions_reg <- "[[:digit:]]+\\.*[[:digit:]]*+\\/*[[:digit:]]*"

frac_to_dec <- function(e) {
  e <- parse(text = e) %>% eval() %>% as.character()
  return(e)
}

get_portions <- function(df) {
  df <- df %>% 
    mutate(
      portion_num = str_extract(ingredients, portions_reg) %>% 
        map_chr(frac_to_dec) %>% as.numeric() %>% round(digits = 2),
      portion_name = str_extract(ingredients, measures_collapsed)
    )
  return(df)
}



some_recipes_df_decimal <- some_recipes_df
some_recipes_df_decimal[1, ] <- "1.2 ounces chipotle cooking sauce"

get_portions(some_recipes_df_decimal) %>% 
  select(-recipe_name)


