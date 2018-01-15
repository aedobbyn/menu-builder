

import_scripts(path = "./scripts/simulate")
status_spectrum <- read_feather("./data/status_spectrum.feather")


# ----------------- Solving -------------
expect_type(get_status(), "integer")

expect_type(simulate_menus(), "numeric")




# ------------- Scraping ----------
# This includes an NA because urls (defined in scrape.R) does not include a 12th
expect_type(mixed_urls %>% count_bad(percent_to_use = 0.75, seed = NULL), 
            "numeric")
expect_type(mixed_urls %>% count_bad(n_to_use = 2), 
            "numeric")





