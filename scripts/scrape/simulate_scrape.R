
# Test increase in bad URLs

which(mixed_2 == "Bad URL")


get_recipe_name(c(urls[5], "bar"))

urls[5] %>% read_url() %>% get_recipe_name()

try_get_recipe_name <- possibly(get_recipe_name, otherwise = "Bad URL", quiet = FALSE)

"foo" %>% read_url() %>% try_get_recipe_name()

"foo" %>% try_read()

mixed_urls <- c(urls[5], "bar")

count_bad <- function(urls) {
  out <- urls %>% map(try_read)
  
  percent_bad <- length(which(out == "Bad URL")) / length(out)
  return(percent_bad)
}

mixed_urls %>% count_bad()

