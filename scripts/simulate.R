
import_scripts(path = "./scripts/simulate")


# ----------------------------------- Simulate solving -----------------------------------

# Build a menu, solve it, and get its status back
expect_type(get_status(), "integer")

# simulate_menus()
# half_portions <- simulate_menus(n_sims = 1000)
# full_portions <- simulate_menus(n_sims = 1000, 
#                                 min_food_amount = 1)
# double_portions <- simulate_menus(n_sims = 100,
#                                   min_food_amount = 1)


# Run it with the given spectrum
status_spectrum <- simulate_spectrum(n_intervals = 100, n_sims = 10)
# write_feather(status_spectrum, "./scripts/simulate/status_spectrum.feather")
# status_spectrum <- read_feather("./scripts/simulate/status_spectrum.feather")

# Get a summary by group
status_spectrum_summary <- status_spectrum %>% 
  group_by(min_amount) %>% 
  summarise(
    sol_prop = mean(status)
  )

# Plot the status spectrum
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

mixed_urls <- c("foo", urls[10:12], "bar")
mixed_urls %>% count_bad(percent_to_use = 0.75, seed = NULL)
mixed_urls %>% count_bad(n_to_use = 2)



# We couldn't actually use this due to being booted...so we simulate multiple rounds of scraping on the same
# set of 400+ observations below using simulate_scrape_on_lst
some_urls <- grab_urls(base_url, sample(100000:200000, size = 100))
some_scrape_sim <- some_urls %>% simulate_scrape(n_intervals = 50, n_sims = 2, sleep = 3)

more_scrape_sim <- more_urls %>% simulate_scrape(n_intervals = 500, n_sims = 2, sleep = 3)




# For all the recipes in a given recipe list that includes bad URLs, if we take samples of those,
# what percent will be bad URLs?
rec_spectrum <- more_recipes_raw %>% simulate_scrape_on_lst(n_intervals = 100, n_sims = 4)
# write_feather(rec_spectrum, "./data/rec_spectrum.feather")


# Plot percent tried vs. percent bad
ggplot(data = rec_spectrum, aes(percents_scraped, percents_bad)) +
  geom_smooth(se = FALSE) +
  geom_point() +
  theme_minimal() +
  ggtitle("Curve of percent of URLs tried vs. percent that were bad") +
  labs(x = "Percent Tried", y = "Percent Bad") 









