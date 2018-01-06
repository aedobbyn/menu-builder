
# Scrape test
source("./scripts/scrape.R")

# Artifically hard dataframe
some_recipes_tester <- list(ingredients = vector()) %>% as_tibble()
some_recipes_tester[1, ] <- "1.2 ounces or maybe pounds of something with a decimal"
some_recipes_tester[2, ] <- "3 (14 ounce) cans o' beef broth"
some_recipes_tester[3, ] <- "around 4 or 5 eels"
some_recipes_tester[4, ] <- "5-6 cans spam"
some_recipes_tester[5, ] <- "11 - 46 tbsp of sugar"
some_recipes_tester[6, ] <- "1/3 to 1/2 of a ham"
some_recipes_tester[7, ] <- "5 1/2 pounds of apples"
some_recipes_tester[8, ] <- "4g cinnamon"
some_recipes_tester[9, ] <- "about 17 fluid ounces of wine"
some_recipes_tester[10, ] <- "4-5 cans of 1/2 caf coffee"
some_recipes_tester[11, ] <- "3 7oz figs with 1/3 rind"


# Take a few real URLS
base_url <- "http://allrecipes.com/recipe/"
urls <- grab_urls(base_url, 244940:244950)


# Test that our bad URL doesn't error out
expect_equal(get_recipes("foo"), "Bad URL")

# Check that we're not pulling in duplicate recipes
expect_equal(get_recipes(c(urls[2], urls[2:3])), get_recipes(c(urls[2:3])))


# Get a list of recipes and form them into a dataframe
some_recipes <- get_recipes(urls[4:7])
some_recipes_df <- dfize(some_recipes)
get_portions(some_recipes_df) %>% add_abbrevs() %>% View()
# write_feather(some_recipes_df, "./data/some_recipes_df.feather")



# Check that our range determiner is working
expect_true(determine_if_range("4 to 5 things"))
expect_false(determine_if_range("4 5 things"))



# Test on our tester
tester_w_portions <- get_portions(some_recipes_tester) 
expect_equal(tester_w_portions[1, ]$portion_name, "ounce, pound")

# Add abbreviations
get_portions(some_recipes_tester) %>% add_abbrevs() %>% View()



example_url <- "http://allrecipes.com/recipe/244950/baked-chicken-schnitzel/"
schnitzel <- example_url %>% get_recipes()
example_url %>% try_read() %>% get_recipe_name()



# ---------- Get a lot of recipes ---------

# Most IDs seem to start with 1 or 2 and be either 5 or 6 digits long
# Some 
more_urls <- grab_urls(base_url, sample(100000:200000, size = 50))
more_recipes <- more_urls %>% map(get_recipes, sleep = 3)
more_recipes_df <- dfize(more_recipes)
more_recipes_df <- get_portions(more_recipes_df) 
more_recipes_df %>% add_abbrevs() %>% View()

