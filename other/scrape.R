library(tidyverse)
library(rvest)

example_url <- "http://allrecipes.com/recipe/244950/baked-chicken-schnitzel/?internalSource=streams&referringId=1947&referringContentType=recipe%20hub&clickId=st_trending_b"

base_url <- "http://allrecipes.com/recipe/"

grab_urls <- function(base_url, id) {
  id <- as.character(id)
  recipe_url <- str_c(base_url, id)
  return(recipe_url)
}

urls <- grab_urls(base_url, 244940:244950)

remove_whitespace <- function(str) {
  str <- str %>% str_split(" ") %>% as_vector()
  str <- str[!str == ""]
  str <- str_c(str, collapse = " ")
  return(str)
}

get_recipes <- function(url) {
  
  recipe_page <- read_html(url)
  
  recipe <- recipe_page %>% 
    html_nodes(".checkList__line") %>% 
    html_text() %>% 
    str_replace_all("ADVERTISEMENT", "") %>% 
    str_replace_all("\n", "") %>% 
    str_replace_all("\r", "") %>% 
    str_replace_all("Add all ingredients to list", "")
  
  recipe <- recipe %>% 
    map(remove_whitespace) %>% as_vector()
  
  recipe
}

urls[1:3] %>% map(get_recipes)





