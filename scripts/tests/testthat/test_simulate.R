
# Test simulating solving menus and scraping for new ones

import_scripts(path = "./scripts/simulate")
# Import a dataframe of statuses as compared to the minimum portion sizes we assigned
status_spectrum <- read_feather("./data/status_spectrum.feather")


# ----------------- Solving -------------
# Get the statusof
expect_type(get_status(), "integer")

expect_type(simulate_menus(), "double")




# ------------- Scraping ----------
# This includes an NA because urls (defined in scrape.R) does not include a 12th
expect_type(mixed_urls %>% count_bad(percent_to_use = 0.75, seed = NULL), 
            "double")
expect_type(mixed_urls %>% count_bad(n_to_use = 2), 
            "double")





