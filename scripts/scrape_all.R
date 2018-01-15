
# # ---------- Get a lot of recipes ---------
# 
# Most IDs seem to start with 1 or 2 and be either 5 or 6 digits long

# more_urls <- grab_urls(base_url, sample(100000:250000, size = 1000))
# 
# more_recipes_raw <- more_urls %>% get_recipes(sleep = 3)
# more_recipes <- more_recipes_raw[!more_recipes_raw == "Bad URL"]
# more_recipes_df <- dfize(more_recipes)
# more_recipes_df <- get_portions(more_recipes_df)
# more_recipes_df <- more_recipes_df %>% add_abbrevs()

# saveRDS(more_recipes_raw, file = "./data/more_recipes_raw.rds")    # load with readRDS()
# write_feather(more_recipes_df, "./data/more_recipes_df.feather")

