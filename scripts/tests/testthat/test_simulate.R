

import_scripts(path = "./scripts/simulate")



# ----------------- Solving -------------
expect_type(get_status(), "integer")

expect_type(simulate_menus(), "numeric")




# ------------- Scraping ----------
expect_type(mixed_urls %>% count_bad(percent_to_use = 0.75, seed = NULL), 
            "numeric")
expect_type(mixed_urls %>% count_bad(n_to_use = 2), 
            "numeric")



