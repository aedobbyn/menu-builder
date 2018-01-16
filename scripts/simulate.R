
more_recipes_raw <- readRDS(file = "./data/derived/more_recipes_raw.rds")
import_scripts(path = "./scripts/scrape")
import_scripts(path = "./scripts/simulate")


# ----------------------------------- Simulate solving -----------------------------------
# If we build menus randomly and try to solve them given a certain minimum portion size, 
# what percent of them will be solvable?

# --- Build a menu, solve it with some specifications, and get its status back ---
get_status()

# --- Do the above for some number of simulations  ---
simulate_menus()

half_portions <- simulate_menus(n_sims = 10, min_food_amount = 0.5)
full_portions <- simulate_menus(n_sims = 10, min_food_amount = 1)
double_portions <- simulate_menus(n_sims = 10, min_food_amount = 2)


# --- Do the above for a spectrum of portion sizes ---
# Simulate solving 1000 menus (10 each at 100 intervals between minimum portion sizes of -1 to 1)
status_spectrum <- simulate_spectrum(n_intervals = 100, n_sims = 10)
# write_feather(status_spectrum, "./data/derived/status_spectrum.feather")

# Get a summary of the specturm grouped by minimum amount
status_spectrum_summary <- summarise_status_spectrum(status_spectrum)


# Plot the status spectrum curve: as we increase the minimum portion size, what percent of our menus are solvable?
ggplot() +
  geom_smooth(data = status_spectrum, aes(min_amount, 1 - status),
              se = FALSE, span = 0.01) +
  geom_point(data = status_spectrum_summary, aes(min_amount, 1 - sol_prop)) +
  theme_minimal() +
  ggtitle("Curve of portion size vs. solvability") +
  labs(x = "Minimum portion size", y = "Proportion of solutions") +
  ylim(0, 1) 


# ------ 10 simulations w for loop ----
# user  system elapsed 
# 2.612   0.131   2.762 
# ------ 10 w purrr ------
# user  system elapsed 
# 2.654   0.165   2.845





# ----------------------------------- Simulate scraping -----------------------------------
# For all the recipes in a given recipe list that includes bad URLs, if we take samples of those,
# what percent will be bad URLs?
some_scrape_sim <- some_urls %>% simulate_scrape(n_intervals = 50, n_sims = 2, sleep = 3)
more_scrape_sim <- more_urls %>% simulate_scrape(n_intervals = 500, n_sims = 2, sleep = 3)

# The simulate_scrape() function we couldn't actually use this due to being booted
# Instead, we simulate multiple rounds of scraping on the same
# set of 400+ observations using simulate_scrape_on_lst()

# --- Simulate percent that are bad on an existing list of recipes ---
rec_spectrum <- more_recipes_raw %>% simulate_scrape_on_lst(n_intervals = 100, n_sims = 4)
# write_feather(rec_spectrum, "./data/derived/rec_spectrum.feather")


# Plot percent tried vs. percent bad
ggplot(data = rec_spectrum, aes(percents_scraped, percents_bad)) +
  geom_smooth(se = FALSE) +
  geom_point() +
  theme_minimal() +
  ggtitle("Curve of percent of URLs tried vs. percent that were bad") +
  labs(x = "Percent Tried", y = "Percent Bad") 









