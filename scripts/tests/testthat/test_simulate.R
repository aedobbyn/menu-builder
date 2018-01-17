
# Test simulating solving menus and scraping for new ones

import_scripts(path = "./scripts/simulate")
# Import a dataframe of statuses as compared to the minimum portion sizes we assigned
status_spectrum <- read_feather("./data/derived/status_spectrum.feather")
# List of scraped recipes that have not yet been dfize'd
more_recipes_raw <- readRDS(file = "./data/derived/more_recipes_raw.rds")


# ----------------- Solving -------------
# Build a menu, sovle it, and get the status
expect_type(get_status(), "integer")
# Simulate building and solving some menus and get the proportion of them that are solvable
expect_type(simulate_menus(n_sims = 3, min_food_amount = 0), "double")
# Simulate a number of menus across a spectrum of minimum portion sizes
expect_silent(default_spectrum <- simulate_spectrum())
# Summarise the simulated menu
expect_silent(default_spectrum %>% summarise_status_spectrum())

# Simulate some swaps
expect_is(swap_sims <- simulate_swap_spectrum(n_intervals = 3, n_sims = 2, n_swaps = 3), "tbl_df")
# And summarise them
expect_is(swap_sims %>% summarise_status_spectrum(), "tbl_df")


# ------------- Scraping ----------
# This includes an NA because urls (defined in scrape.R) does not include a 12th
expect_type(mixed_urls %>% count_bad(percent_to_use = 0.75, seed = NULL), 
            "double")
expect_type(mixed_urls %>% count_bad(n_to_use = 2), 
            "double")
# Take some urls
expect_message(mixed_urls %>% simulate_scrape(n_sims = 1))

# Take a list of raw recipes and simulate on them
expect_message(more_recipes_raw %>% simulate_scrape_on_lst())


