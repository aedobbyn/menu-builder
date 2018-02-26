
# # ---------- Get a lot of recipes ---------
source("./scripts/scrape/urls.R")
get_measurement_types(from_file = TRUE)

more_recipes_raw <- more_urls %>% get_recipes(sleep = 3)
more_recipes <- more_recipes_raw[!more_recipes_raw == "Bad URL"]
more_recipes_df <- more_recipes %>% 
  dfize() %>% 
  get_portions() %>% 
  add_abbrevs()

# saveRDS(more_recipes_raw, file = "./data/derived/more_recipes_raw.rds")    # load with readRDS()
# write_feather(more_recipes_df, "./data/derived/more_recipes_df.feather")

more_recipes_raw <- read_rds("./data/derived/more_recipes_raw.rds")
more_recipes <- more_recipes_raw[!more_recipes_raw == "Bad URL"]

recipes_df <- more_recipes_df %>% 
  convert_units()