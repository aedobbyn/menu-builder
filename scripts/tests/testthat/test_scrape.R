
# Scrape test
source("./scripts/scrape/scrape.R")

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

# Test that our bad URL doesn't error out
expect_equal(get_recipes("foo"), "Bad URL")
expect_silent(get_recipes(c(urls[5], "bar"), verbose = FALSE))

# Get a short list of recipes
some_recipes <- get_recipes(urls[4:7]) 


# -- Check that we're not pulling in duplicate recipes
# If not all URLs are bad
if (length(some_recipes[which(some_recipes == "Bad URL")]) != length(some_recipes)) {    
  some_recipes_df <- dfize(some_recipes)   # Use dfize() to get a list of recipes and form them into a dataframe
  expect_equal(get_recipes(c(urls[4], urls[4:7])), some_recipes)  
# If they're all bad, read in some_recipes_df instead of dfizing our bad URLs
} else {
  some_recipes_df <- read_feather("./data/derived/some_recipes_df.feather")
  expect_equal(length(get_recipes(c(urls[4], urls[4:7]))), length(some_recipes) + 1)  
}

get_portions(some_recipes_df) %>% add_abbrevs()


# Check that our range and multiplier functions are working
expect_true(determine_if_range("4 to 5 things"))
expect_false(determine_if_range("4 5 things"))

expect_equal(get_ranges("3-4"), get_ranges("3 to 4"), mean(3, 4))
expect_equal(get_mult_add_portion("3 (5 ounce cans)"), 3*5)
expect_equal(get_mult_add_portion("3 5 ounce cans)"), 15)


# Test on our tester
tester_w_portions <- get_portions(some_recipes_tester) 
expect_equal(tester_w_portions[1, ]$portion_name, "pound")    # We only grab the last word



# ---------- Portion text and values ---------
# Add abbreviations
expect_silent(some_recipes_tester %>% get_portions() %>% add_abbrevs())
expect_silent(some_recipes_tester %>% get_portion_text() %>% add_abbrevs %>% get_portion_values())
expect_silent(some_recipes_tester %>% get_portions(add_abbrevs = TRUE))

