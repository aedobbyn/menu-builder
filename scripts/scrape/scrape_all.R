
# example_url <- "http://allrecipes.com/recipe/244950/baked-chicken-schnitzel/"
# schnitzel <- example_url %>% get_recipes()
# example_url %>% try_read() %>% get_recipe_name()
# 
# 
# # ---------- Get a lot of recipes ---------
# 
# # Most IDs seem to start with 1 or 2 and be either 5 or 6 digits long
# # Some
more_urls <- grab_urls(base_url, sample(100000:250000, size = 1000))
more_recipes <- more_urls %>% get_recipes(sleep = 3)
more_recipes <- more_recipes[!more_recipes == "Bad URL"]
more_recipes_df <- dfize(more_recipes)
more_recipes_df <- get_portions(more_recipes_df)
more_recipes_df <- more_recipes_df %>% add_abbrevs()
# more_recipes_df %>% add_abbrevs() %>% View()


