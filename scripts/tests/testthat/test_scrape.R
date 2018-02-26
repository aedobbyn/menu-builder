
# Scrape test
source("./scripts/scrape/scrape.R")
source("./scripts/scrape/some_recipes_tester.R")

# Test that our bad URL doesn't error out
expect_equal(get_recipes("foo"), "Bad URL")
expect_silent(get_recipes(c(urls[7], "bar"), verbose = FALSE))

# Get a short list of recipes
some_recipes <- get_recipes(urls[4:5]) 


# -- Check that we're not pulling in duplicate recipes
# If not all URLs are bad
if (length(some_recipes[which(some_recipes == "Bad URL")]) != length(some_recipes)) {    
  some_recipes_df <- dfize(some_recipes)   # Use dfize() to get a list of recipes and form them into a dataframe
  expect_equal(get_recipes(c(urls[4], urls[4:5])), some_recipes)  
# If they're all bad, read in some_recipes_df instead of dfizing our bad URLs
} else {
  some_recipes_df <- read_feather("./data/derived/some_recipes_df.feather")
  expect_equal(length(get_recipes(c(urls[4], urls[4:5]))), length(some_recipes) + 1)  
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



# -------- Conversions ------

# Make sure conv_unit works
expect_equal(396.89, conv_unit(more_recipes_df[3, ]$portion, more_recipes_df[3, ]$portion_abbrev, "g") %>% round(digits = 2))

converted_units <- test_abbrev_dict_conv(abbrev_dict, key)
converted_units_w_accepted <- test_abbrev_dict_conv(abbrev_dict_w_accepted, accepted)

# Pre-processing we can only convert 3/4 of units. Post- it should be 100%.
expect_equal(0.75, length(converted_units$converted[!is.na(converted_units$converted)]) / length(converted_units$converted))
expect_equal(1, length(converted_units_w_accepted$converted[!is.na(converted_units_w_accepted$converted)]) / length(converted_units_w_accepted$converted))




