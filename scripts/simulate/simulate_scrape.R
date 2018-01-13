
# Test increase in bad URLs as we grab more and more pages
# We try to grab recipe names; if we've got a bad URL, the name is "Bad URL"

source("./scripts/scrape/scrape.R")
source("./scripts/tests/testthat/test_scrape.R")

# percent_to_use is the percent of our URLs we want to sample from
# If return_percent_bad is FALSE, return the whole list of recipe names. Otherwise, just return the percent of URLs that were bad.
count_bad <- function(urls, n_to_use = NULL, percent_to_use = 1, return_percent_bad = TRUE, seed = NULL) {

  set.seed(seed)
  
  urls <- urls[complete.cases(urls)]   # Remove NAs
  if (is.null(n_to_use)) {
    n_to_use <- (length(urls) * percent_to_use) %>% round(digits = 0)   # Get an integer value of URLs to sample
  }
  
  urls <- sample(urls, size = n_to_use, replace = FALSE)
  
  out <- urls %>% map(try_read)
  
  if (return_percent_bad == FALSE) {
    return(out)
    
  } else {
    percent_bad <- length(which(out == "Bad URL")) / length(out)
    return(percent_bad)
  }
  
}

mixed_urls <- c("foo", urls[10:12], "bar")
mixed_urls %>% count_bad(percent_to_use = 0.75, seed = NULL)
mixed_urls %>% count_bad(n_to_use = 2)



simulate_scrape <- function(urls, n_intervals = 4, n_sims = 3, from = 0, to = 1, 
                            verbose = TRUE, v_v_verbose = FALSE,
                            sleep = 3) {
  
  # browser()
  interval <- (to - from) / n_intervals
  
  percents_to_scrape <- seq(from = from, to = to, by = interval) %>% rep(n_sims) %>% sort()
  percents_to_scrape <- percents_to_scrape[!percents_to_scrape == 0]  # Remove 0s
  
  if (v_v_verbose == TRUE) {
    message(paste0("Testing on: ", str_c(percents_to_scrape, collapse = ", ")))   
  }
  
  seeds <- sample(1:length(percents_to_scrape), size = length(percents_to_scrape), replace = FALSE)
  percents_bad <- vector("numeric", length = length(percents_to_scrape))
  
  for (i in seq_along(percents_to_scrape)) {
    if (!is.null(sleep)) { Sys.sleep(sleep) }
    
    this_bad <- urls %>% count_bad(percent_to_use = percents_to_scrape[i], seed = seeds[i])
    if (verbose == TRUE) {
      message(paste0((this_bad*100), "% of URLs were bad out of a pool of ", round((percents_to_scrape[i]*100), digits = 1), "% of all URLs."))
    }
    percents_bad[i] <- this_bad
  }
  
  out <- list(percents_scraped = percents_to_scrape, percents_bad = percents_bad) %>% as_tibble()
  return(out)
}

scrape_sim <- mixed_urls %>% simulate_scrape()

ggplot(data = scrape_sim, aes(percents_scraped, percents_bad)) +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  ggtitle("Curve of percent of URLs tried vs. percent that were bad") +
  labs(x = "Percent Tried", y = "Percent Bad") +
  ylim(0, 1)
  

some_urls <- grab_urls(base_url, sample(100000:200000, size = 100))
some_scrape_sim <- some_urls %>% simulate_scrape(n_intervals = 50, n_sims = 2, sleep = 3)

more_urls <- grab_urls(base_url, sample(100000:200000, size = 1000))
more_scrape_sim <- more_urls %>% simulate_scrape(n_intervals = 500, n_sims = 2, sleep = 3)




