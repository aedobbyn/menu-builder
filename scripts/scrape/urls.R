
base_url <- "http://allrecipes.com/recipe/"

grab_urls <- function(base_url, id) {
  id <- as.character(id)
  recipe_url <- str_c(base_url, id)
  return(recipe_url)
}

urls <- grab_urls(base_url, 244940:244950)

some_urls <- grab_urls(base_url, sample(100000:200000, size = 100))
more_urls <- grab_urls(base_url, sample(100000:250000, size = 1000))
mixed_urls <- c("foo", urls[10:12], "bar")

