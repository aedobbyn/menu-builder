library(tidyverse)
library(rvest)

example_url <- "http://allrecipes.com/recipe/244950/baked-chicken-schnitzel/?internalSource=streams&referringId=1947&referringContentType=recipe%20hub&clickId=st_trending_b"
schnitzel <- example_url %>% get_recipes()
example_url %>% get_recipe_name()

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
get_recipes <- function(url) {
  
  recipe_page <- try_read(url)
  
  if(recipe_page == "Bad URL" | (!class(recipe_page) %in% c("xml_document", "xml_node"))) { 
    recipe_df <- recipe_page
  } else {
  
    recipe <- recipe_page %>% 
      get_recipe_content() %>% 
      map(remove_whitespace) %>% as_vector()
    
    recipe_name <- get_recipe_name(recipe_page)
    
    
    recipe_df <- list(this_name = recipe) %>% as_tibble()   # could do with deparse(recipe_name)?
    names(recipe_df) <- recipe_name
    
  } 
  
  return(recipe_df)
}

get_recipes(example_url)

some_recipes <- c(urls[1:3], bad_url) %>% map(get_recipes)

# Test that our bad URL doesn't error out
expect_equal(get_recipes(bad_url), "Bad URL")

